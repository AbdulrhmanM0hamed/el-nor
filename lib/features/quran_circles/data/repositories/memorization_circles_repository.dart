import 'package:beat_elslam/features/quran_circles/data/models/surah_assignment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/memorization_circle_model.dart';
import '../models/student_record.dart';

class MemorizationCirclesRepository {
  final SupabaseClient _supabaseClient;
  final Map<String, DateTime> _lastFetchTime = {};
  final Duration _cacheDuration = const Duration(seconds: 30);

  MemorizationCirclesRepository(this._supabaseClient);

  // Get all circles
  Future<List<MemorizationCircle>> getAllCircles() async {
    try {
      // جلب الحلقات مع بيانات المعلمين والطلاب
      final data = await _supabaseClient.from('memorization_circles')
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

      List<MemorizationCircle> circles = [];

      // معالجة كل حلقة على حدة
      for (var json in data) {
        try {
          // إضافة بيانات المعلم من العلاقة
          if (json['teacher'] != null) {
            json['teacher_name'] = json['teacher']['name'];
          }

          // جلب بيانات الطلاب إذا كان هناك student_ids
          if (json['student_ids'] != null &&
              (json['student_ids'] as List).isNotEmpty) {
            
            // Check if we need to fetch student data
            final circleId = json['id'];
            final lastFetch = _lastFetchTime[circleId];
            final now = DateTime.now();
            
            if (lastFetch == null || now.difference(lastFetch) > _cacheDuration) {
              final studentsData = await _supabaseClient
                  .from('students')
                  .select('id, name, profile_image_url')
                  .filter('id', 'in', json['student_ids']);

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
              _lastFetchTime[circleId] = now;
            }
          } else {
            json['students'] = [];
          }

          final circle = _parseCircleFromJson(json);
          circles.add(circle);
        } catch (e) {
          print('MemorizationCirclesRepository: خطأ في معالجة الحلقة: $e');
        }
      }

      return circles;
    } catch (e) {
      print('MemorizationCirclesRepository: خطأ في جلب الحلقات: $e');
      throw Exception('Failed to load circles: $e');
    }
  }

  // Update student attendance and evaluation with optimistic updates
  Future<void> updateStudentAttendanceAndEvaluation({
    required String circleId,
    required String studentId,
    AttendanceRecord? attendance,
    EvaluationRecord? evaluation,
  }) async {
    try {
      // 1. جلب بيانات الحلقة الحالية
      final circleResponse = await _supabaseClient
          .from('memorization_circles')
          .select('students')
          .eq('id', circleId)
          .single();

      // 2. تحويل البيانات إلى List
      List<Map<String, dynamic>> students =
          (circleResponse['students'] as List?)?.cast<Map<String, dynamic>>() ??
              [];

      // 3. البحث عن الطالب
      int studentIndex = students.indexWhere((s) => s['id'] == studentId);

      if (studentIndex == -1) {
        // إذا لم يكن الطالب موجوداً، نضيفه
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
            (students[studentIndex]['attendance'] as List?)
                    ?.cast<Map<String, dynamic>>() ??
                [];

        attendanceList.add({
          'date': attendance.date.toIso8601String(),
          'is_present': attendance.isPresent,
        });

        students[studentIndex]['attendance'] = attendanceList;
      }

      if (evaluation != null) {
        List<Map<String, dynamic>> evaluationsList =
            (students[studentIndex]['evaluations'] as List?)
                    ?.cast<Map<String, dynamic>>() ??
                [];

        evaluationsList.add({
          'date': evaluation.date.toIso8601String(),
          'rating': evaluation.rating,
        });

        students[studentIndex]['evaluations'] = evaluationsList;
      }

      // 5. تحديث البيانات في قاعدة البيانات
      await _supabaseClient
          .from('memorization_circles')
          .update({
            'students': students,
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', circleId);

      // 6. تحديث وقت آخر تحديث للحلقة
      _lastFetchTime.remove(circleId);
    } catch (e) {
      throw Exception('Failed to update student records: $e');
    }
  }

  // Helper method to parse circle data from JSON
  MemorizationCircle _parseCircleFromJson(Map<String, dynamic> json) {
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
                      ))
                  ?.toList() ??
              [],
          attendance: (studentJson['attendance'] as List?)
                  ?.map((a) => AttendanceRecord(
                        date: DateTime.parse(a['date']),
                        isPresent: a['is_present'],
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
      isExam: json['is_exam'] ?? false,
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      status: json['status'] ?? 'active',
      assignments: json['surah_assignments'] != null
          ? (json['surah_assignments'] as List)
              .map((a) => SurahAssignment.fromJson(a))
              .toList()
          : [],
      students: students,
      studentIds: (json['student_ids'] as List?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
