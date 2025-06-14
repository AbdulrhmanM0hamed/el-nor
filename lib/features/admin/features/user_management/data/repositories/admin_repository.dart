

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
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

  // حذف خطة التعلم القديمة من نفس الباكيت
  Future<void> saveOldLearningPlan(String oldUrl) async {
    try {
      final filename = oldUrl.split('/').last;
      await _supabaseClient.storage.from('learningplans').remove([filename]);
    } catch (e) {
      // تجاهل الخطأ إذا لم يكن الملف موجوداً
    }
  }

  // رفع خطة التعلم الجديدة (مع استبدال الملف إذا كان موجوداً)
  Future<String?> uploadLearningPlan(String fileName, Uint8List bytes) async {
    try {
      // ارفع الملف مباشرة من الذاكرة، مع تفعيل خيار upsert للاستبدال
      await _supabaseClient.storage.from('learningplans').uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

      // الحصول على الرابط العام
      final url = _supabaseClient.storage.from('learningplans').getPublicUrl(fileName);
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
      debugPrint(
          'AdminRepository: بدء إرسال الإشعارات للطلاب - عدد الطلاب: ${studentIds.length}');
      debugPrint('AdminRepository: معرفات الطلاب: $studentIds');

      // الحصول على tokens الطلاب
      final response = await _supabaseClient
          .from('user_tokens')
          .select('fcm_token, user_id')
          .filter('user_id', 'in', studentIds);

      debugPrint('AdminRepository: تم جلب الـ tokens - البيانات: $response');

      final List<String> tokens = (response as List)
          .map((item) => item['fcm_token'].toString())
          .toList();

      if (tokens.isEmpty) {
        debugPrint('AdminRepository: لا يوجد tokens للطلاب المحددين');
        return;
      }

      debugPrint(
          'AdminRepository: عدد الـ tokens التي تم العثور عليها: ${tokens.length}');

      // تحضير محتوى الإشعار
      final title = isExam
          ? 'تم إضافتك إلى حلقة اختبار جديدة'
          : 'تم إضافتك إلى حلقة تحفيظ جديدة';
      final body = 'تم إضافتك إلى حلقة: $circleName';

      debugPrint('AdminRepository: محتوى الإشعار:');
      debugPrint('- العنوان: $title');
      debugPrint('- المحتوى: $body');

      // إرسال الإشعار لكل token
      for (final token in tokens) {
        debugPrint(
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
          debugPrint(
              'AdminRepository: تم إرسال الإشعار بنجاح للـ token: ${token.substring(0, 10)}...');
        } catch (e) {
          debugPrint(
              'AdminRepository: فشل في إرسال الإشعار للـ token: ${token.substring(0, 10)}... - الخطأ: $e');
        }
      }

      debugPrint('AdminRepository: تم الانتهاء من إرسال الإشعارات للطلاب');
    } catch (e) {
      debugPrint('AdminRepository: خطأ في إرسال الإشعارات للطلاب: $e');
      debugPrint('AdminRepository: تفاصيل الخطأ الكامل:');
      debugPrint(e.toString());
    }
  }

  // تحديث معلم الحلقة فقط

  // تحديث حضور وتقييم الطالب في الحلقة

  // الحصول على سجلات حضور وتقييم طالب في حلقة معينة
}
