import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/memorization_circles_repository.dart';
import '../../data/models/memorization_circle_model.dart';
import '../../data/models/student_record.dart';

// Estados para el Cubit
abstract class MemorizationCirclesState extends Equatable {
  const MemorizationCirclesState();

  @override
  List<Object?> get props => [];
}

class MemorizationCirclesInitial extends MemorizationCirclesState {}

class MemorizationCirclesLoading extends MemorizationCirclesState {}

class MemorizationCirclesLoaded extends MemorizationCirclesState {
  final List<MemorizationCircle> circles;

  const MemorizationCirclesLoaded(this.circles);

  @override
  List<Object?> get props => [circles];
}

class MemorizationCircleDetailsLoaded extends MemorizationCirclesState {
  final MemorizationCircle circle;

  const MemorizationCircleDetailsLoaded(this.circle);

  @override
  List<Object?> get props => [circle];
}

class MemorizationCirclesError extends MemorizationCirclesState {
  final String message;

  const MemorizationCirclesError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit para gestionar los círculos de memorización
class MemorizationCirclesCubit extends Cubit<MemorizationCirclesState> {
  final MemorizationCirclesRepository repository;

  MemorizationCirclesCubit({required this.repository}) : super(MemorizationCirclesInitial());

  // Cargar todos los círculos de memorización
  Future<void> loadMemorizationCircles() async {
    print('MemorizationCirclesCubit: بدء تحميل حلقات التحفيظ');
    emit(MemorizationCirclesLoading());
    try {
      final circles = await repository.getAllCircles();

      print('MemorizationCirclesCubit: تم تحميل ${circles.length} حلقة');
      if(circles.isNotEmpty) {
        print('MemorizationCirclesCubit: الحلقات المحملة: ${circles.map((c) => c.name).toList()}');
      }
      
      if (circles.isEmpty) {
        print('MemorizationCirclesCubit: لا توجد حلقات للعرض');
      }
      
      emit(MemorizationCirclesLoaded(circles));
    } catch (e) {
      print('MemorizationCirclesCubit: حدث خطأ أثناء تحميل الحلقات: $e');
      emit(MemorizationCirclesError('حدث خطأ أثناء تحميل حلقات الحفظ'));
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
