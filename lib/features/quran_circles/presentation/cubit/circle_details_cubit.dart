import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/memorization_circle_model.dart';
import '../../data/models/student_record.dart';
import '../../data/repositories/circle_details_repository.dart';
import 'circle_details_state.dart';

class CircleDetailsCubit extends Cubit<CircleDetailsState> {
  final CircleDetailsRepository repository;
  bool _isDisposed = false;

  CircleDetailsCubit({
    required this.repository,
    required MemorizationCircle initialCircle,
    required String userId,
    required UserRole userRole,
  }) : super(CircleDetailsInitial()) {
    loadCircleDetails(initialCircle, userId, userRole);
  }

  Future<void> loadCircleDetails(
      MemorizationCircle circle, String userId, UserRole userRole) async {
    if (_isDisposed) return;

    try {
      emit(CircleDetailsLoading());

      final permissionsResult =
          await repository.getCurrentUserPermissions(circle.teacherId ?? '');

      await permissionsResult.fold(
        (failure) {
          emit(CircleDetailsError(failure.message));
        },
        (permissions) {
          emit(CircleDetailsLoaded(
            circle: circle,
            canManage: permissions['canManage'] ?? false,
            userId: permissions['userId'] ?? '',
            userRole: userRole,
          ));
        },
      );
    } catch (e) {
      emit(const CircleDetailsError('حدث خطأ أثناء تحميل تفاصيل الحلقة'));
    }
  }

  Future<void> updateStudentEvaluation(String studentId, int evaluation) async {
    if (_isDisposed) return;

    final currentState = state;
    if (currentState is CircleDetailsLoaded) {
      try {
        final circle = currentState.circle;
        final updatedStudents = List<StudentRecord>.from(circle.students);
        final studentIndex =
            updatedStudents.indexWhere((s) => s.studentId == studentId);

        if (studentIndex != -1) {
          final student = updatedStudents[studentIndex];
          final now = DateTime.now();

          final evaluations = List<EvaluationRecord>.from(student.evaluations)
            ..add(EvaluationRecord(
              date: now,
              rating: evaluation,
            ));

          updatedStudents[studentIndex] = student.copyWith(
            evaluations: evaluations,
          );

          final updatedCircle = circle.copyWith(
            students: updatedStudents,
            updatedAt: DateTime.now(),
          );

          // Optimistically update UI
          emit(currentState.copyWith(circle: updatedCircle));

          // Update database
          final result = await repository.updateStudentEvaluation(
            circleId: circle.id,
            studentId: studentId,
            evaluation: EvaluationRecord(
              date: now,
              rating: evaluation,
            ),
          );

          result.fold(
            (failure) {
              emit(CircleDetailsError(failure.message));
              // Reload circle details to ensure UI is in sync
              loadCircleDetails(currentState.circle, currentState.userId,
                  currentState.userRole);
            },
            (_) {},
          );
        } else {}
      } catch (e) {
        emit(const CircleDetailsError('حدث خطأ أثناء تحديث تقييم الطالب'));
        // Reload circle details to ensure UI is in sync
        await loadCircleDetails(
            currentState.circle, currentState.userId, currentState.userRole);
      }
    }
  }

  Future<void> updateStudentAttendance(String studentId, bool isPresent) async {
    if (_isDisposed) return;

    final currentState = state;
    if (currentState is CircleDetailsLoaded) {
      try {
        final circle = currentState.circle;
        final updatedStudents = List<StudentRecord>.from(circle.students);
        final studentIndex =
            updatedStudents.indexWhere((s) => s.studentId == studentId);

        if (studentIndex != -1) {
          final student = updatedStudents[studentIndex];
          final now = DateTime.now();

          final attendance = List<AttendanceRecord>.from(student.attendance)
            ..add(AttendanceRecord(
              date: now,
              isPresent: isPresent,
            ));

          updatedStudents[studentIndex] = student.copyWith(
            attendance: attendance,
          );

          final updatedCircle = circle.copyWith(
            students: updatedStudents,
            updatedAt: DateTime.now(),
          );

          // Optimistically update UI
          emit(currentState.copyWith(circle: updatedCircle));

          // Update database
          final result = await repository.updateStudentAttendance(
            circleId: circle.id,
            studentId: studentId,
            attendance: AttendanceRecord(
              date: now,
              isPresent: isPresent,
            ),
          );

          result.fold(
            (failure) {
              emit(CircleDetailsError(failure.message));
              // Reload circle details to ensure UI is in sync
              loadCircleDetails(currentState.circle, currentState.userId,
                  currentState.userRole);
            },
            (_) {},
          );
        } else {}
      } catch (e) {
        emit(const CircleDetailsError('حدث خطأ أثناء تحديث حضور الطالب'));
        // Reload circle details to ensure UI is in sync
        await loadCircleDetails(
            currentState.circle, currentState.userId, currentState.userRole);
      }
    }
  }

  @override
  Future<void> close() {
    _isDisposed = true;
    return super.close();
  }
}
