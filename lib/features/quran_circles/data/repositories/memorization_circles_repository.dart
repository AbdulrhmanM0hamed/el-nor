import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/memorization_circle_model.dart';
import '../models/student_record.dart';

class MemorizationCirclesRepository {
  final SupabaseClient _supabaseClient;

  MemorizationCirclesRepository(this._supabaseClient);

  // Get all circles
  Future<List<MemorizationCircle>> getAllCircles() async {
    try {
      print('MemorizationCirclesRepository: بدء تحميل الحلقات');
      
      // جلب الحلقات مع بيانات المعلمين والطلاب
      final data = await _supabaseClient
          .from('memorization_circles')
          .select('''
            *,
            teacher:teacher_id (
              id,
              name,
              email,
              profile_image_url
            )
          ''')
          .order('created_at', ascending: false);

      print('MemorizationCirclesRepository: تم جلب البيانات الأولية: $data');

      List<MemorizationCircle> circles = [];

      // معالجة كل حلقة على حدة
      for (var json in data) {
        try {
          // إضافة بيانات المعلم من العلاقة
          if (json['teacher'] != null) {
            json['teacher_name'] = json['teacher']['name'];
          }

          // جلب بيانات الطلاب إذا كان هناك student_ids
          if (json['student_ids'] != null && (json['student_ids'] as List).isNotEmpty) {
            print('MemorizationCirclesRepository: جلب بيانات الطلاب للحلقة ${json['id']}');
            print('MemorizationCirclesRepository: معرفات الطلاب: ${json['student_ids']}');

            final studentsData = await _supabaseClient
                .from('students')
                .select('id, name, profile_image_url')
                .filter('id', 'in', json['student_ids']);

            print('MemorizationCirclesRepository: تم جلب بيانات الطلاب: $studentsData');

            // تحويل بيانات الطلاب إلى الشكل المطلوب مع الحفاظ على بيانات التقييم والحضور
            final List<Map<String, dynamic>> studentsFormatted = [];
            
            for (var student in studentsData) {
              // البحث عن بيانات الطالب في الـ students column
              var existingStudentData = json['students'] != null 
                ? (json['students'] as List).firstWhere(
                    (s) => s['id'] == student['id'],
                    orElse: () => null)
                : null;

              studentsFormatted.add({
                'id': student['id'],
                'name': student['name'],
                'profile_image_url': student['profile_image_url'],
                'evaluations': existingStudentData?['evaluations'] ?? [],
                'attendance': existingStudentData?['attendance'] ?? []
              });
            }

            json['students'] = studentsFormatted;
            print('MemorizationCirclesRepository: تم إضافة ${studentsFormatted.length} طالب للحلقة ${json['id']}');
            print('MemorizationCirclesRepository: بيانات الطلاب المحدثة: ${json['students']}');
          } else {
            json['students'] = [];
            print('MemorizationCirclesRepository: لا يوجد طلاب للحلقة ${json['id']}');
          }

          final circle = _parseCircleFromJson(json);
          circles.add(circle);
          print('MemorizationCirclesRepository: تم إضافة الحلقة ${circle.id} بنجاح');
          print('MemorizationCirclesRepository: عدد الطلاب في الحلقة: ${circle.students.length}');
          if (circle.students.isNotEmpty) {
            print('MemorizationCirclesRepository: نموذج من بيانات الطلاب:');
            print('عدد التقييمات للطالب الأول: ${circle.students[0].evaluations.length}');
            print('عدد سجلات الحضور للطالب الأول: ${circle.students[0].attendance.length}');
          }

        } catch (e) {
          print('MemorizationCirclesRepository: خطأ في معالجة الحلقة: $e');
        }
      }

      print('MemorizationCirclesRepository: تم معالجة ${circles.length} حلقة بنجاح');
      return circles;
    } catch (e) {
      print('MemorizationCirclesRepository: خطأ في جلب الحلقات: $e');
      throw Exception('Failed to load circles: $e');
    }
  }

  // Update student attendance and evaluation
  Future<void> updateStudentAttendanceAndEvaluation({
    required String circleId,
    required String studentId,
    AttendanceRecord? attendance,
    EvaluationRecord? evaluation,
  }) async {
    try {
      print('MemorizationCirclesRepository: بدء تحديث سجلات الطالب');
      print('Circle ID: $circleId');
      print('Student ID: $studentId');
      print('Attendance: ${attendance?.toJson()}');
      print('Evaluation: ${evaluation?.toJson()}');

      // 1. جلب بيانات الحلقة الحالية
      final circleResponse = await _supabaseClient
          .from('memorization_circles')
          .select('students')
          .eq('id', circleId)
          .single();
      
      print('MemorizationCirclesRepository: البيانات الحالية: $circleResponse');

      // 2. تحويل البيانات إلى List
      List<Map<String, dynamic>> students = 
          (circleResponse['students'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      // 3. البحث عن الطالب
      int studentIndex = students.indexWhere((s) => s['id'] == studentId);
      
      if (studentIndex == -1) {
        // إذا لم يكن الطالب موجوداً، نضيفه
        print('MemorizationCirclesRepository: إضافة طالب جديد');
        final studentData = await _supabaseClient
            .from('students')
            .select('id, name, profile_image_url')
            .eq('id', studentId)
            .single();
            
        students.add({
          'id': studentData['id'],
          'name': studentData['name'],
          'profile_image_url': studentData['profile_image_url'],
          'evaluations': [],
          'attendance': []
        });
        studentIndex = students.length - 1;
      }

      // 4. تحديث بيانات الطالب
      if (attendance != null) {
        List<Map<String, dynamic>> attendanceList = 
            (students[studentIndex]['attendance'] as List?)?.cast<Map<String, dynamic>>() ?? [];
            
        attendanceList.add({
          'date': attendance.date.toIso8601String(),
          'is_present': attendance.isPresent,
          'notes': attendance.notes
        });
        
        students[studentIndex]['attendance'] = attendanceList;
        print('MemorizationCirclesRepository: تم تحديث الحضور');
      }

      if (evaluation != null) {
        List<Map<String, dynamic>> evaluationsList = 
            (students[studentIndex]['evaluations'] as List?)?.cast<Map<String, dynamic>>() ?? [];
            
        evaluationsList.add({
          'date': evaluation.date.toIso8601String(),
          'rating': evaluation.rating,
          'notes': evaluation.notes
        });
        
        students[studentIndex]['evaluations'] = evaluationsList;
        print('MemorizationCirclesRepository: تم تحديث التقييم');
      }

      // 5. تحديث البيانات في قاعدة البيانات
      print('MemorizationCirclesRepository: تحديث البيانات في قاعدة البيانات');
      print('Updated students data: $students');
      
      final response = await _supabaseClient
          .from('memorization_circles')
          .update({
            'students': students,
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', circleId);
          
      print('MemorizationCirclesRepository: تم التحديث بنجاح');
      print('Response: $response');

    } catch (e, stackTrace) {
      print('MemorizationCirclesRepository: خطأ في تحديث سجلات الطالب');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to update student records: $e');
    }
  }

  // Helper method to parse circle data from JSON
  MemorizationCircle _parseCircleFromJson(Map<String, dynamic> json) {
    print('MemorizationCirclesRepository: تحليل بيانات الحلقة: $json');
    final List<StudentRecord> students = [];
    
    if (json['students'] != null) {
      for (final studentJson in json['students']) {
        students.add(StudentRecord(
          studentId: studentJson['id'],
          name: studentJson['name'],
          profileImageUrl: studentJson['profile_image_url'],
          evaluations: (studentJson['evaluations'] as List?)
              ?.map((e) => EvaluationRecord(
                    date: DateTime.parse(e['date']),
                    rating: e['rating'],
                    notes: e['notes'],
                  ))
              ?.toList() ??
              [],
          attendance: (studentJson['attendance'] as List?)
              ?.map((a) => AttendanceRecord(
                    date: DateTime.parse(a['date']),
                    isPresent: a['is_present'],
                    notes: a['notes'],
                  ))
              ?.toList() ??
              [],
        ));
      }
    }

    return MemorizationCircle(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      teacherId: json['teacher_id'] ?? '',
      teacherName: json['teacher_name'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      isExam: json['is_exam'] ?? false,
      status: json['status'] ?? 'active',
      assignments: (json['surah_assignments'] as List?)
          ?.map((a) => SurahAssignment(
                id: a['id'],
                surahName: a['surah_name'],
                startVerse: a['start_verse'],
                endVerse: a['end_verse'],
              ))
          ?.toList() ??
          [],
      students: students,
      studentIds: (json['student_ids'] as List?)?.map((id) => id.toString()).toList() ?? [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
} 