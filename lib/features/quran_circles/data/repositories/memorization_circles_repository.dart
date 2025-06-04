import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/memorization_circle_model.dart';
import '../models/student_record.dart';

class MemorizationCirclesRepository {
  final SupabaseClient _supabaseClient;

  MemorizationCirclesRepository(this._supabaseClient);

  // Get all circles
  Future<List<MemorizationCircle>> getAllCircles() async {
    try {
      final data = await _supabaseClient
          .from('memorization_circles')
          .select()
          .order('created_at', ascending: false);

      return data.map((json) => _parseCircleFromJson(json)).toList();
    } catch (e) {
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
      // Get current circle data
      final circleData = await _supabaseClient
          .from('memorization_circles')
          .select()
          .eq('id', circleId)
          .single();

      // Get current students array
      final List<dynamic> currentStudents = circleData['students'] ?? [];
      
      // Find and update the student
      final studentIndex = currentStudents.indexWhere((s) => s['id'] == studentId);
      if (studentIndex == -1) {
        throw Exception('Student not found in circle');
      }

      // Update student data
      final studentData = Map<String, dynamic>.from(currentStudents[studentIndex]);
      
      if (attendance != null) {
        final attendanceList = List<Map<String, dynamic>>.from(studentData['attendance'] ?? []);
        attendanceList.add({
          'date': attendance.date.toIso8601String().split('T')[0],
          'is_present': attendance.isPresent,
          'notes': attendance.notes ?? '',
        });
        studentData['attendance'] = attendanceList;
      }

      if (evaluation != null) {
        final evaluationsList = List<Map<String, dynamic>>.from(studentData['evaluations'] ?? []);
        evaluationsList.add({
          'date': evaluation.date.toIso8601String().split('T')[0],
          'rating': evaluation.rating,
          'notes': evaluation.notes ?? '',
        });
        studentData['evaluations'] = evaluationsList;
      }

      currentStudents[studentIndex] = studentData;

      // Update the circle with new students data
      await _supabaseClient
          .from('memorization_circles')
          .update({
            'students': currentStudents,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', circleId);

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