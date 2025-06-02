import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/memorization_circle_model.dart';

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
  MemorizationCirclesCubit() : super(MemorizationCirclesInitial());

  // Cargar todos los círculos de memorización
  Future<void> loadMemorizationCircles() async {
    emit(MemorizationCirclesLoading());
    try {
      // En una aplicación real, esto cargaría datos desde una API o base de datos
      await Future.delayed(const Duration(seconds: 1)); // Simular carga
      final circles = MemorizationCircle.getSampleCircles();
      emit(MemorizationCirclesLoaded(circles));
    } catch (e) {
      emit(MemorizationCirclesError('حدث خطأ أثناء تحميل حلقات الحفظ'));
    }
  }

  // Cargar detalles de un círculo específico
  Future<void> loadCircleDetails(int circleId) async {
    emit(MemorizationCirclesLoading());
    try {
      // En una aplicación real, esto cargaría datos desde una API o base de datos
      await Future.delayed(const Duration(milliseconds: 800)); // Simular carga
      final circles = MemorizationCircle.getSampleCircles();
      final circle = circles.firstWhere((c) => c.id == circleId);
      emit(MemorizationCircleDetailsLoaded(circle));
    } catch (e) {
      emit(MemorizationCirclesError('حدث خطأ أثناء تحميل تفاصيل الحلقة'));
    }
  }

  // Actualizar la evaluación de un estudiante
  Future<void> updateStudentEvaluation(int circleId, int studentId, int evaluation) async {
    final currentState = state;
    if (currentState is MemorizationCircleDetailsLoaded) {
      final circle = currentState.circle;
      final studentIndex = circle.students.indexWhere((s) => s.id == studentId);
      
      if (studentIndex != -1) {
        final updatedStudent = circle.students[studentIndex].copyWith(evaluation: evaluation);
        final updatedStudents = List<MemorizationStudent>.from(circle.students);
        updatedStudents[studentIndex] = updatedStudent;
        
        final updatedCircle = MemorizationCircle(
          id: circle.id,
          name: circle.name,
          teacherName: circle.teacherName,
          description: circle.description,
          date: circle.date,
          students: updatedStudents,
          assignments: circle.assignments,
          isExam: circle.isExam,
        );
        
        emit(MemorizationCircleDetailsLoaded(updatedCircle));
      }
    }
  }

  // Actualizar la asistencia de un estudiante
  Future<void> updateStudentAttendance(int circleId, int studentId, bool isPresent) async {
    final currentState = state;
    if (currentState is MemorizationCircleDetailsLoaded) {
      final circle = currentState.circle;
      final studentIndex = circle.students.indexWhere((s) => s.id == studentId);
      
      if (studentIndex != -1) {
        final updatedStudent = circle.students[studentIndex].copyWith(isPresent: isPresent);
        final updatedStudents = List<MemorizationStudent>.from(circle.students);
        updatedStudents[studentIndex] = updatedStudent;
        
        final updatedCircle = MemorizationCircle(
          id: circle.id,
          name: circle.name,
          teacherName: circle.teacherName,
          description: circle.description,
          date: circle.date,
          students: updatedStudents,
          assignments: circle.assignments,
          isExam: circle.isExam,
        );
        
        emit(MemorizationCircleDetailsLoaded(updatedCircle));
      }
    }
  }
}
