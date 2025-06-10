import 'package:beat_elslam/features/quran_circles/presentation/cubit/memorization_circles_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/memorization_circles_repository.dart';
import '../../data/models/student_record.dart';

// Estados para el Cubit


// Cubit para gestionar los círculos de memorización
class MemorizationCirclesCubit extends Cubit<MemorizationCirclesState> {
  final MemorizationCirclesRepository repository;

  MemorizationCirclesCubit({required this.repository}) : super(MemorizationCirclesInitial());

  // Cargar todos los círculos de memorización
  Future<void> loadMemorizationCircles() async {
   if(!isClosed) emit(MemorizationCirclesLoading());
    try {
      final circles = await repository.getAllCircles();
      emit(MemorizationCirclesLoaded(circles));
    } catch (e) {
      emit(const MemorizationCirclesError('حدث خطأ أثناء تحميل حلقات الحفظ'));
    }
  }

  // Cargar detalles de un círculo específico
  Future<void> loadCircleDetails(String circleId) async {
    emit(MemorizationCirclesLoading());
    try {
      final circles = await repository.getAllCircles();
      final circle = circles.firstWhere((c) => c.id == circleId);
      emit(MemorizationCircleDetailsLoaded(circle));
    } catch (e) {
      emit(MemorizationCirclesError('حدث خطأ أثناء تحميل تفاصيل الحلقة'));
    }
  }

  // Actualizar la evaluación de un estudiante
  Future<void> updateStudentEvaluation(String circleId, String studentId, int evaluation) async {
    emit(MemorizationCirclesLoading());
    try {
      final evalRecord = EvaluationRecord(
        date: DateTime.now(),
        rating: evaluation,
      );
      
      await repository.updateStudentAttendanceAndEvaluation(
        circleId: circleId,
        studentId: studentId,
        evaluation: evalRecord,
      );
      await loadCircleDetails(circleId);
    } catch (e) {
      emit(MemorizationCirclesError('حدث خطأ أثناء تحديث تقييم الطالب'));
    }
  }

  // Actualizar la asistencia de un estudiante
  Future<void> updateStudentAttendance(String circleId, String studentId, bool isPresent) async {
    emit(MemorizationCirclesLoading());
    try {
      final attendanceRecord = AttendanceRecord(
        date: DateTime.now(),
        isPresent: isPresent,
      );
      
      await repository.updateStudentAttendanceAndEvaluation(
        circleId: circleId,
        studentId: studentId,
        attendance: attendanceRecord,
      );
      await loadCircleDetails(circleId);
    } catch (e) {
      emit(MemorizationCirclesError('حدث خطأ أثناء تحديث حضور الطالب'));
    }
  }
}
