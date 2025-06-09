import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_model.dart';
import '../models/memorization_circle_model.dart';
import '../../../../core/services/notification_service.dart';

class AdminRepository {
  final SupabaseClient _supabaseClient;
  final NotificationService _notificationService;

  AdminRepository(this._supabaseClient) : _notificationService = NotificationService();
  
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
      
      for (var teacher in data) {
      }
      
      return data.map((json) => StudentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('فشل في جلب المعلمين: $e');
    }
  }

  // جلب جميع حلقات التحفيظ
  Future<List<MemorizationCircleModel>> getAllCircles() async {
    try {
      
      // جلب الحلقات
      final data = await _supabaseClient
          .from('memorization_circles')
          .select()
          .order('created_at', ascending: false);
      
      
      final List<MemorizationCircleModel> circles = [];
      
      for (final json in data) {
        try {
        
          // جلب بيانات المعلم من جدول students إذا كان موجوداً
          if (json['teacher_id'] != null) {
            try {
              print('AdminRepository: Fetching teacher data for teacher_id: ${json['teacher_id']}');
              
              final teacherData = await _supabaseClient
                  .from('students')
                  .select()
                  .eq('id', json['teacher_id'])
                  .eq('is_teacher', true)
                  .maybeSingle();
                  
              if (teacherData != null) {
                json['teacher_name'] = teacherData['name'];
                json['teacher_email'] = teacherData['email'];
                json['teacher_phone'] = teacherData['phone'];
                json['teacher_image_url'] = teacherData['profile_image_url'];
                
              } else {
                json['teacher_name'] = null;
                json['teacher_email'] = null;
                json['teacher_phone'] = null;
                json['teacher_image_url'] = null;
              }
            } catch (e) {
              json['teacher_name'] = null;
              json['teacher_email'] = null;
              json['teacher_phone'] = null;
              json['teacher_image_url'] = null;
            }
          }
          
          List<String> studentIds = [];
          if (json['student_ids'] != null) {
            studentIds = (json['student_ids'] as List).map((id) => id.toString()).toList();
          } else {
          }
          
          // تحميل تفاصيل الطلاب من جدول students
          List<CircleStudent> students = [];
          if (studentIds.isNotEmpty) {
            try {
              
              final studentsData = await _supabaseClient
                  .from('students')
                  .select()
                  .filter('id', 'in', studentIds);
                  
              
              students = studentsData.map((studentJson) => CircleStudent(
                id: studentJson['id'],
                name: studentJson['name'] ?? '',
                profileImageUrl: studentJson['profile_image_url'],
                attendance: [],
                evaluations: [],
              )).toList();
              
            } catch (e) {
            }
          }
          
          final circle = MemorizationCircleModel.fromJson(json);
          final updatedCircle = circle.copyWith(
            studentIds: studentIds,
            students: students,
          );
          circles.add(updatedCircle);
          
        } catch (e) {
        }
      }
    
      return circles;
    } catch (e) {
      throw Exception('Failed to load circles: $e');
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
      // التحقق من وجود المعلم في جدول students قبل إضافة الحلقة
      if (circle.teacherId != null && circle.teacherId!.isNotEmpty) {
        final teacherExists = await _supabaseClient
            .from('students')
            .select()
            .eq('id', circle.teacherId!)
            .eq('is_teacher', true)
            .maybeSingle();
            
        if (teacherExists == null) {
          throw Exception('المعلم غير موجود أو ليس لديه صلاحيات معلم');
        }
      }

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
      
      
      // إضافة الحلقة في قاعدة البيانات
      final insertedData = await _supabaseClient
          .from('memorization_circles')
          .insert(circleData)
          .select()
          .single();
      
      // جلب بيانات المعلم من جدول students
      if (insertedData['teacher_id'] != null) {
        final teacherData = await _supabaseClient
            .from('students')
            .select()
            .eq('id', insertedData['teacher_id'])
            .eq('is_teacher', true)
            .single();
            
        insertedData['teacher_name'] = teacherData['name'];
        insertedData['teacher_email'] = teacherData['email'];
        insertedData['teacher_phone'] = teacherData['phone'];
        insertedData['teacher_image_url'] = teacherData['profile_image_url'];
      }
      
      // إرسال إشعارات للطلاب المضافين
      if (circle.studentIds.isNotEmpty) {
        await _sendNotificationToStudents(
          studentIds: circle.studentIds,
          circleName: circle.name,
          isExam: circle.isExam,
        );
      }
      
      print('تم إضافة الحلقة بنجاح. البيانات المرجعة: $insertedData');
      
      return MemorizationCircleModel.fromJson(insertedData);
    } catch (e) {
      print('خطأ في إضافة حلقة التحفيظ: $e');
      throw Exception('فشل في إضافة حلقة التحفيظ: $e');
    }
  }

  // إرسال إشعارات للطلاب
  Future<void> _sendNotificationToStudents({
    required List<String> studentIds,
    required String circleName,
    required bool isExam,
  }) async {
    try {
      print('AdminRepository: بدء إرسال الإشعارات للطلاب - عدد الطلاب: ${studentIds.length}');
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

      print('AdminRepository: عدد الـ tokens التي تم العثور عليها: ${tokens.length}');

      // تحضير محتوى الإشعار
      final title = isExam ? 'تم إضافتك إلى حلقة اختبار جديدة' : 'تم إضافتك إلى حلقة تحفيظ جديدة';
      final body = 'تم إضافتك إلى حلقة: $circleName';

      print('AdminRepository: محتوى الإشعار:');
      print('- العنوان: $title');
      print('- المحتوى: $body');

      // إرسال الإشعار لكل token
      for (final token in tokens) {
        print('AdminRepository: جاري إرسال الإشعار للـ token: ${token.substring(0, 10)}...');
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
          print('AdminRepository: تم إرسال الإشعار بنجاح للـ token: ${token.substring(0, 10)}...');
        } catch (e) {
          print('AdminRepository: فشل في إرسال الإشعار للـ token: ${token.substring(0, 10)}... - الخطأ: $e');
        }
      }

      print('AdminRepository: تم الانتهاء من إرسال الإشعارات للطلاب');
    } catch (e) {
      print('AdminRepository: خطأ في إرسال الإشعارات للطلاب: $e');
      print('AdminRepository: تفاصيل الخطأ الكامل:');
      print(e.toString());
    }
  }

  // تحديث بيانات حلقة تحفيظ
  Future<MemorizationCircleModel> updateCircle(MemorizationCircleModel circle) async {
    try {
      // التحقق من وجود المعلم في جدول students قبل التحديث
      if (circle.teacherId != null && circle.teacherId!.isNotEmpty) {
        final teacherExists = await _supabaseClient
            .from('students')
            .select()
            .eq('id', circle.teacherId!)
            .eq('is_teacher', true)
            .maybeSingle();
            
        if (teacherExists == null) {
          throw Exception('المعلم غير موجود أو ليس لديه صلاحيات معلم');
        }
      }

      final Map<String, dynamic> circleData = {
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
      
      // تحديث بيانات الحلقة
      final updatedData = await _supabaseClient
          .from('memorization_circles')
          .update(circleData)
          .eq('id', circle.id)
          .select()
          .single();
      
      // جلب بيانات المعلم من جدول students
      if (updatedData['teacher_id'] != null) {
        final teacherData = await _supabaseClient
            .from('students')
            .select()
            .eq('id', updatedData['teacher_id'])
            .eq('is_teacher', true)
            .single();
            
        updatedData['teacher_name'] = teacherData['name'];
        updatedData['teacher_email'] = teacherData['email'];
        updatedData['teacher_phone'] = teacherData['phone'];
        updatedData['teacher_image_url'] = teacherData['profile_image_url'];
      }
      
      return MemorizationCircleModel.fromJson(updatedData);
    } catch (e) {
      throw Exception('فشل في تحديث بيانات حلقة التحفيظ: $e');
    }
  }
  
  // تحديث معلم الحلقة فقط
  Future<void> updateCircleTeacher(String circleId, String teacherId) async {
    try {
      
      await _supabaseClient
          .from('memorization_circles')
          .update({
            'teacher_id': teacherId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', circleId);
      
    } catch (e) {
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

  // تحديث حضور وتقييم الطالب في الحلقة
  Future<void> updateStudentAttendanceAndEvaluation({
    required String circleId,
    required String studentId,
    AttendanceRecord? attendance,
    EvaluationRecord? evaluation,
  }) async {
    try {
      // الحصول على بيانات الحلقة الحالية
      final circleData = await _supabaseClient
          .from('memorization_circles')
          .select()
          .eq('id', circleId)
          .single();

      // تحويل البيانات إلى نموذج
      final circle = MemorizationCircleModel.fromJson(circleData);

      // البحث عن الطالب في قائمة الطلاب
      final studentIndex = circle.students.indexWhere((s) => s.id == studentId);
      if (studentIndex == -1) {
        throw Exception('الطالب غير موجود في هذه الحلقة');
      }

      // تحديث بيانات الطالب
      final student = circle.students[studentIndex];
      List<AttendanceRecord> updatedAttendance = List.from(student.attendance);
      List<EvaluationRecord> updatedEvaluations = List.from(student.evaluations);

      // إضافة سجل الحضور الجديد إذا وجد
      if (attendance != null) {
        updatedAttendance.add(attendance);
      }

      // إضافة سجل التقييم الجديد إذا وجد
      if (evaluation != null) {
        updatedEvaluations.add(evaluation);
      }

      // تحديث الطالب بالبيانات الجديدة
      final updatedStudent = student.copyWith(
        attendance: updatedAttendance,
        evaluations: updatedEvaluations,
      );

      // تحديث قائمة الطلاب في الحلقة
      final updatedStudents = List<CircleStudent>.from(circle.students);
      updatedStudents[studentIndex] = updatedStudent;

      // تحديث الحلقة في قاعدة البيانات
      await _supabaseClient
          .from('memorization_circles')
          .update({
            'students': updatedStudents.map((s) => s.toJson()).toList(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', circleId);

    } catch (e) {
      throw Exception('فشل في تحديث حضور وتقييم الطالب: $e');
    }
  }

  // الحصول على سجلات حضور وتقييم طالب في حلقة معينة
  Future<CircleStudent> getStudentRecords(String circleId, String studentId) async {
    try {
      final circleData = await _supabaseClient
          .from('memorization_circles')
          .select()
          .eq('id', circleId)
          .single();

      final circle = MemorizationCircleModel.fromJson(circleData);
      final student = circle.students.firstWhere(
        (s) => s.id == studentId,
        orElse: () => throw Exception('الطالب غير موجود في هذه الحلقة'),
      );

      return student;
    } catch (e) {
      throw Exception('فشل في جلب سجلات الطالب: $e');
    }
  }
}
