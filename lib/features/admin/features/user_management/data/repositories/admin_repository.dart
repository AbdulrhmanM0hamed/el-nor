import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../data/models/student_model.dart';
import '../../../../../../core/services/notification_service.dart';

class AdminRepository {
  final SupabaseClient _supabaseClient;
  final NotificationService _notificationService;

  AdminRepository(this._supabaseClient)
      : _notificationService = NotificationService();

  // التحقق من صلاحيات المشرف
  Future<bool> checkAdminPermission() async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return false;
      }

      final userData = await _supabaseClient
          .from('students')
          .select()
          .eq('id', currentUser.id)
          .single();

      return userData['is_admin'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // حفظ خطة التعلم القديمة
  Future<void> saveOldLearningPlan(String oldUrl) async {
    try {
      // Extract filename from URL
      final filename = oldUrl.split('/').last;

      // First delete the existing file if it exists
      try {
        await _supabaseClient.storage
            .from('learning-plans-archive')
            .remove([filename]);
      } catch (e) {
        // If file doesn't exist, continue without error
      }

      // Download the file as bytes
      final bytes =
          await _supabaseClient.storage.from('learning-plans').download(oldUrl);

      // Create a temporary file from bytes
      final tempFile = await File('temp_${filename}').create();
      await tempFile.writeAsBytes(bytes);

      // Upload the temporary file
      await _supabaseClient.storage
          .from('learning-plans-archive')
          .upload(filename, tempFile);

      // Clean up the temporary file
      await tempFile.delete();
    } catch (e) {
      throw Exception('فشل في حفظ خطة التعلم القديمة: $e');
    }
  }

  // رفع خطة التعلم الجديدة
  Future<String?> uploadLearningPlan(String fileName, List<int> bytes) async {
    try {
      // First delete the existing file if it exists
      try {
        await _supabaseClient.storage.from('learning-plans').remove([fileName]);
      } catch (e) {
        // If file doesn't exist, continue without error
      }

      // Create a temporary file from bytes
      final tempFile = await File(fileName).writeAsBytes(bytes);

      // Upload the file to Supabase
      final response = await _supabaseClient.storage
          .from('learning-plans')
          .upload(fileName, tempFile);

      // Get the public URL of the file
      final url = await _supabaseClient.storage
          .from('learning-plans')
          .getPublicUrl(fileName);

      // Clean up temporary file
      await tempFile.delete();

      return url;
    } catch (e) {
      throw Exception('فشل في رفع خطة التعلم: $e');
    }
  }

  // جلب جميع المستخدمين
  Future<List<StudentModel>> getAllUsers() async {
    try {
      final data = await _supabaseClient.from('students').select();
      return data.map((user) => StudentModel.fromJson(user)).toList();
    } catch (e) {
      throw Exception('فشل في جلب المستخدمين: $e');
    }
  }

  // جلب جميع المعلمين
  Future<List<StudentModel>> getAllTeachers() async {
    try {
      final data = await _supabaseClient
          .from('students')
          .select('*, profile_image_url, email, phone')
          .eq('is_teacher', true)
          .order('name');

      return data.map((json) => StudentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('فشل في جلب المعلمين: $e');
    }
  }

  // جلب جميع حلقات التحفيظ

  // تحديث دور المستخدم
  Future<void> updateUserRole({
    required String userId,
    required bool isAdmin,
    required bool isTeacher,
  }) async {
    try {
      // التحقق من صلاحيات المشرف
      final hasPermission = await checkAdminPermission();
      if (!hasPermission) {
        throw Exception('ليس لديك صلاحية لتعديل أدوار المستخدمين');
      }

      await _supabaseClient.from('students').update({
        'is_admin': isAdmin,
        'is_teacher': isTeacher,
      }).eq('id', userId);
    } catch (e) {
      throw Exception('فشل في تحديث دور المستخدم: $e');
    }
  }

  // إضافة حلقة تحفيظ جديدة

  // إرسال إشعارات للطلاب
  Future<void> _sendNotificationToStudents({
    required List<String> studentIds,
    required String circleName,
    required bool isExam,
  }) async {
    try {
      print(
          'AdminRepository: بدء إرسال الإشعارات للطلاب - عدد الطلاب: ${studentIds.length}');
      print('AdminRepository: معرفات الطلاب: $studentIds');

      // الحصول على tokens الطلاب
      final response = await _supabaseClient
          .from('user_tokens')
          .select('fcm_token, user_id')
          .filter('user_id', 'in', studentIds);

      print('AdminRepository: تم جلب الـ tokens - البيانات: $response');

      final List<String> tokens = (response as List)
          .map((item) => item['fcm_token'].toString())
          .toList();

      if (tokens.isEmpty) {
        print('AdminRepository: لا يوجد tokens للطلاب المحددين');
        return;
      }

      print(
          'AdminRepository: عدد الـ tokens التي تم العثور عليها: ${tokens.length}');

      // تحضير محتوى الإشعار
      final title = isExam
          ? 'تم إضافتك إلى حلقة اختبار جديدة'
          : 'تم إضافتك إلى حلقة تحفيظ جديدة';
      final body = 'تم إضافتك إلى حلقة: $circleName';

      print('AdminRepository: محتوى الإشعار:');
      print('- العنوان: $title');
      print('- المحتوى: $body');

      // إرسال الإشعار لكل token
      for (final token in tokens) {
        print(
            'AdminRepository: جاري إرسال الإشعار للـ token: ${token.substring(0, 10)}...');
        try {
          await _notificationService.sendNotification(
            token: token,
            title: title,
            body: body,
            data: {
              'type': 'circle_assignment',
              'circle_name': circleName,
              'is_exam': isExam.toString(),
            },
          );
          print(
              'AdminRepository: تم إرسال الإشعار بنجاح للـ token: ${token.substring(0, 10)}...');
        } catch (e) {
          print(
              'AdminRepository: فشل في إرسال الإشعار للـ token: ${token.substring(0, 10)}... - الخطأ: $e');
        }
      }

      print('AdminRepository: تم الانتهاء من إرسال الإشعارات للطلاب');
    } catch (e) {
      print('AdminRepository: خطأ في إرسال الإشعارات للطلاب: $e');
      print('AdminRepository: تفاصيل الخطأ الكامل:');
      print(e.toString());
    }
  }

  // تحديث معلم الحلقة فقط

  // تحديث حضور وتقييم الطالب في الحلقة

  // الحصول على سجلات حضور وتقييم طالب في حلقة معينة
}
