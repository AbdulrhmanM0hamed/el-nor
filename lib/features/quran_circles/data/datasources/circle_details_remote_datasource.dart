import 'package:beat_elslam/core/error/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_record.dart';

abstract class CircleDetailsRemoteDataSource {
  Future<Map<String, dynamic>> getCurrentUserPermissions(
      String circleTeacherId);
  Future<void> updateStudentEvaluation({
    required String circleId,
    required String studentId,
    required EvaluationRecord evaluation,
  });
  Future<void> updateStudentAttendance({
    required String circleId,
    required String studentId,
    required AttendanceRecord attendance,
  });
  Future<void> deleteStudentEvaluation({
    required String circleId,
    required String studentId,
    required int evaluationIndex,
  });
}

class CircleDetailsRemoteDataSourceImpl
    implements CircleDetailsRemoteDataSource {
  final SupabaseClient supabaseClient;

  CircleDetailsRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<Map<String, dynamic>> getCurrentUserPermissions(
      String circleTeacherId) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw const UnauthorizedException('المستخدم غير مسجل دخول');
      }

      final userData = await supabaseClient
          .from('students')
          .select('id, is_admin, is_teacher')
          .eq('id', currentUser.id)
          .single();

      if (userData == null) {
        throw const NotFoundException('لم يتم العثور على بيانات المستخدم');
      }

      final bool isAdmin = userData['is_admin'] ?? false;
      final bool isTeacher = userData['is_teacher'] ?? false;
      final bool canManage = isAdmin || (circleTeacherId == currentUser.id);

      return {
        'isAdmin': isAdmin,
        'isTeacher': isTeacher,
        'userId': currentUser.id,
        'canManage': canManage,
      };
    } catch (e) {
      if (e is PostgrestException) {
        throw DatabaseException(e.message);
      }
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateStudentEvaluation({
    required String circleId,
    required String studentId,
    required EvaluationRecord evaluation,
  }) async {
    try {
      final circleData = await supabaseClient
          .from('memorization_circles')
          .select()
          .eq('id', circleId)
          .single();

      if (circleData == null) {
        throw const NotFoundException('لم يتم العثور على الحلقة');
      }

      List<Map<String, dynamic>> students = [];
      if (circleData['students'] != null) {
        students = List<Map<String, dynamic>>.from(circleData['students']);
      }

      final studentIndex = students.indexWhere((s) => s['id'] == studentId);

      if (studentIndex == -1) {
        final studentData = await supabaseClient
            .from('students')
            .select('id, name, profile_image_url')
            .eq('id', studentId)
            .single();

        final newStudent = {
          'id': studentData['id'],
          'name': studentData['name'],
          'profile_image_url': studentData['profile_image_url'],
          'evaluations': [evaluation.toJson()],
          'attendance': []
        };
        students.add(newStudent);
      } else {
        if (!students[studentIndex].containsKey('evaluations')) {
          students[studentIndex]['evaluations'] = [];
        }

        List<Map<String, dynamic>> evaluations =
            List<Map<String, dynamic>>.from(
                students[studentIndex]['evaluations'] ?? []);

        evaluations.add(evaluation.toJson());
        students[studentIndex]['evaluations'] = evaluations;
      }

      await supabaseClient.from('memorization_circles').update({
        'students': students,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', circleId);
    } catch (e) {
      if (e is PostgrestException) {
        throw DatabaseException(e.message);
      }
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateStudentAttendance({
    required String circleId,
    required String studentId,
    required AttendanceRecord attendance,
  }) async {
    try {
      final circleData = await supabaseClient
          .from('memorization_circles')
          .select()
          .eq('id', circleId)
          .single();

      if (circleData == null) {
        throw const NotFoundException('لم يتم العثور على الحلقة');
      }

      List<Map<String, dynamic>> students = [];
      if (circleData['students'] != null) {
        students = List<Map<String, dynamic>>.from(circleData['students']);
      }

      final studentIndex = students.indexWhere((s) => s['id'] == studentId);

      if (studentIndex == -1) {
        final studentData = await supabaseClient
            .from('students')
            .select('id, name, profile_image_url')
            .eq('id', studentId)
            .single();

        final newStudent = {
          'id': studentData['id'],
          'name': studentData['name'],
          'profile_image_url': studentData['profile_image_url'],
          'evaluations': [],
          'attendance': [attendance.toJson()]
        };
        students.add(newStudent);
      } else {
        if (!students[studentIndex].containsKey('attendance')) {
          students[studentIndex]['attendance'] = [];
        }

        List<Map<String, dynamic>> attendanceList =
            List<Map<String, dynamic>>.from(
                students[studentIndex]['attendance'] ?? []);

        attendanceList.add(attendance.toJson());
        students[studentIndex]['attendance'] = attendanceList;
      }

      await supabaseClient.from('memorization_circles').update({
        'students': students,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', circleId);
    } catch (e) {
      if (e is PostgrestException) {
        throw DatabaseException(e.message);
      }
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteStudentEvaluation({
    required String circleId,
    required String studentId,
    required int evaluationIndex,
  }) async {
    try {
      final circleData = await supabaseClient
          .from('memorization_circles')
          .select('students')
          .eq('id', circleId)
          .single();

      if (circleData == null) {
        throw const NotFoundException('لم يتم العثور على الحلقة');
      }

      List<Map<String, dynamic>> students = [];
      if (circleData['students'] != null) {
        students = List<Map<String, dynamic>>.from(circleData['students']);
      }

      final studentIndex = students.indexWhere((s) => s['id'] == studentId);
      if (studentIndex == -1) {
        throw const NotFoundException('الطالب غير موجود');
      }

      List<Map<String, dynamic>> evals = List<Map<String, dynamic>>.from(
          students[studentIndex]['evaluations'] ?? []);

      if (evaluationIndex < 0 || evaluationIndex >= evals.length) {
        throw const ServerException('مؤشر تقييم غير صالح');
      }

      evals.removeAt(evaluationIndex);
      students[studentIndex]['evaluations'] = evals;

      await supabaseClient.from('memorization_circles').update({
        'students': students,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', circleId);
    } catch (e) {
      if (e is PostgrestException) {
        throw DatabaseException(e.message);
      }
      throw ServerException(e.toString());
    }
  }
}
