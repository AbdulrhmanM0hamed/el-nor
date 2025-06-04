import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_model.dart';
import '../models/memorization_circle_model.dart';
import '../models/surah_assignment.dart';
import '../../../../features/auth/data/models/user_model.dart';

class AdminRepository {
  final SupabaseClient _supabaseClient;

  AdminRepository(this._supabaseClient);
  
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
      
      print('تم العثور على ${data.length} معلم');
      for (var teacher in data) {
        print('معلومات المعلم: معرف=${teacher['id']}, اسم=${teacher['name']}, ايميل=${teacher['email']}, هاتف=${teacher['phone']}, صورة=${teacher['profile_image_url']}');
      }
      
      return data.map((json) => StudentModel.fromJson(json)).toList();
    } catch (e) {
      print('فشل في جلب المعلمين مع تفاصيلهم: $e');
      throw Exception('فشل في جلب المعلمين: $e');
    }
  }

  // جلب جميع حلقات التحفيظ
  Future<List<MemorizationCircleModel>> getAllCircles() async {
    try {
      final data = await _supabaseClient
          .from('memorization_circles')
          .select('*, teachers:teacher_id(id, name, email, phone, profile_image_url)')
          .order('created_at', ascending: false);
      
      print('تم العثور على ${data.length} حلقة');
      
      final List<MemorizationCircleModel> circles = [];
      
      for (final json in data) {
        // إضافة بيانات المعلم من الجدول المرتبط
        if (json['teachers'] != null) {
          final teacher = json['teachers'];
          json['teacher_id'] = teacher['id'];
          json['teacher_name'] = teacher['name'];
          json['teacher_email'] = teacher['email'];
          json['teacher_phone'] = teacher['phone'];
          json['teacher_image_url'] = teacher['profile_image_url'];
          print('معلومات المعلم للحلقة ${json['id']}: الاسم=${teacher['name']}, البريد=${teacher['email']}, الهاتف=${teacher['phone']}, الصورة=${teacher['profile_image_url']}');
        }
        
        List<String> studentIds = [];
        if (json['student_ids'] != null) {
          studentIds = (json['student_ids'] as List).map((id) => id.toString()).toList();
        }
        
        // تحميل تفاصيل الطلاب
        List<CircleStudent> students = [];
        if (studentIds.isNotEmpty) {
          try {
            final studentsData = await _supabaseClient
                .from('students')
                .select('*, profile_image_url')
                .filter('id', 'in', studentIds);
                
            students = studentsData.map((studentJson) => CircleStudent(
              id: studentJson['id'],
              name: studentJson['name'] ?? '',
              profileImageUrl: studentJson['profile_image_url'],
              attendance: [],
              evaluations: [],
            )).toList();
          } catch (e) {
            print('خطأ في تحميل تفاصيل الطلاب: $e');
          }
        }
        
        try {
          final circle = MemorizationCircleModel.fromJson(json);
          final updatedCircle = circle.copyWith(
            studentIds: studentIds,
            students: students,
          );
          circles.add(updatedCircle);
        } catch (e) {
          print('خطأ في تحويل بيانات الحلقة: $e');
          print('البيانات الخام للحلقة: $json');
        }
      }
      
      return circles;
    } catch (e) {
      print('خطأ في جلب حلقات التحفيظ: $e');
      throw Exception('فشل في جلب حلقات التحفيظ: $e');
    }
  }

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
      
      await _supabaseClient
          .from('students')
          .update({
            'is_admin': isAdmin,
            'is_teacher': isTeacher,
          })
          .eq('id', userId);
    } catch (e) {
      throw Exception('فشل في تحديث دور المستخدم: $e');
    }
  }

  // إضافة حلقة تحفيظ جديدة
  Future<MemorizationCircleModel> addCircle(MemorizationCircleModel circle) async {
    try {
      // إعداد البيانات للإدخال
      final Map<String, dynamic> circleData = {
        'id': circle.id,
        'name': circle.name,
        'description': circle.description,
        'teacher_id': circle.teacherId,
        'is_exam': circle.isExam,
        'start_date': circle.startDate.toIso8601String(),
        'end_date': circle.endDate?.toIso8601String(),
        'status': circle.status,
        'surah_assignments': circle.surahAssignments.map((s) => s.toJson()).toList(),
        'student_ids': circle.studentIds.isEmpty ? [] : circle.studentIds,
        'created_at': circle.createdAt.toIso8601String(),
        'updated_at': circle.updatedAt.toIso8601String(),
      };
      
      print('بيانات الحلقة المراد إضافتها: $circleData');
      
      final response = await _supabaseClient
          .from('memorization_circles')
          .insert(circleData)
          .select('*, teacher:teacher_id(*)')
          .single();
      
      print('تم إضافة الحلقة بنجاح. البيانات المرجعة: $response');
      
      return MemorizationCircleModel.fromJson(response);
    } catch (e) {
      print('خطأ في إضافة حلقة التحفيظ: $e');
      throw Exception('فشل في إضافة حلقة التحفيظ: $e');
    }
  }

  // تحديث بيانات حلقة تحفيظ
  Future<MemorizationCircleModel> updateCircle(MemorizationCircleModel circle) async {
    try {
      final Map<String, dynamic> circleData = {
        'id': circle.id,
        'name': circle.name,
        'description': circle.description,
        'teacher_id': circle.teacherId,
        'is_exam': circle.isExam,
        'start_date': circle.startDate.toIso8601String(),
        'end_date': circle.endDate?.toIso8601String(),
        'status': circle.status,
        'surah_assignments': circle.surahAssignments.map((s) => s.toJson()).toList(),
        'student_ids': circle.studentIds.isEmpty ? [] : circle.studentIds,
        'updated_at': circle.updatedAt.toIso8601String(),
      };
      
      final response = await _supabaseClient
          .from('memorization_circles')
          .update(circleData)
          .eq('id', circle.id)
          .select('*, teacher:teacher_id(*)')
          .single();
      
      return MemorizationCircleModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل في تحديث بيانات حلقة التحفيظ: $e');
    }
  }
  
  // تحديث معلم الحلقة فقط
  Future<void> updateCircleTeacher(String circleId, String teacherId) async {
    try {
      print('تحديث معلم الحلقة: الحلقة $circleId, المعلم $teacherId');
      
      await _supabaseClient
          .from('memorization_circles')
          .update({
            'teacher_id': teacherId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', circleId);
      
      print('تم تحديث معلم الحلقة بنجاح');
    } catch (e) {
      print('خطأ في تحديث معلم الحلقة: $e');
      throw Exception('فشل في تحديث معلم الحلقة: $e');
    }
  }

  // حذف حلقة تحفيظ
  Future<void> deleteCircle(String circleId) async {
    try {
      await _supabaseClient
          .from('memorization_circles')
          .delete()
          .eq('id', circleId);
    } catch (e) {
      throw Exception('فشل في حذف حلقة التحفيظ: $e');
    }
  }
}
