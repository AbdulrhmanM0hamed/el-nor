import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/memorization_circle_model.dart';
import '../../data/repositories/memorization_circles_repository.dart';
import 'memorization_circles_state.dart';
import '../../data/models/student_record.dart';

// Estados para el Cubit


// Cubit para gestionar los círculos de memorización
class MemorizationCirclesCubit extends Cubit<MemorizationCirclesState> {
  final MemorizationCirclesRepository repository;
  Map<String, MemorizationCircle> _circlesCache = {};
  bool _isClosed = false;

  MemorizationCirclesCubit(this.repository) : super(MemorizationCirclesInitial());

  Future<void> loadMemorizationCircles({bool forceRefresh = false}) async {
    if (_isClosed) return;
    
    if (state is MemorizationCirclesLoaded && !forceRefresh) {
      // Return cached data if available and no force refresh
      return;
    }

    emit(MemorizationCirclesLoading());
    try {
      final circles = await repository.getAllCircles();
      _updateCache(circles);
      if (!_isClosed) {
      emit(MemorizationCirclesLoaded(circles));
      }
    } catch (e) {
      if (!_isClosed) {
        emit(MemorizationCirclesError('حدث خطأ أثناء تحميل الحلقات'));
      }
    }
  }

  Future<void> loadCircleDetails(String circleId) async {
    if (_isClosed) return;
    
    try {
      final circles = await repository.getAllCircles();
      final updatedCircle = circles.firstWhere((c) => c.id == circleId);
      
      // Update only the specific circle in cache
      _circlesCache[circleId] = updatedCircle;
      
      // If we're in a loaded state, update the state with the new circle data
      if (state is MemorizationCirclesLoaded && !_isClosed) {
        final currentCircles = (state as MemorizationCirclesLoaded).circles;
        final updatedCircles = currentCircles.map((c) => 
          c.id == circleId ? updatedCircle : c
        ).toList();
        
        emit(MemorizationCirclesLoaded(updatedCircles));
      }
    } catch (e) {
      // Don't emit error state here to prevent UI disruption
      print('Error loading circle details: $e');
    }
  }

  Future<void> updateStudentEvaluation(String circleId, String studentId, int evaluation) async {
    if (_isClosed) return;
    
    try {
      // Optimistically update the UI first
      if (state is MemorizationCirclesLoaded) {
        final currentState = state as MemorizationCirclesLoaded;
        final circles = List<MemorizationCircle>.from(currentState.circles);
        final circleIndex = circles.indexWhere((c) => c.id == circleId);
        
        if (circleIndex != -1) {
          final circle = circles[circleIndex];
          final updatedStudents = List<StudentRecord>.from(circle.students);
          final studentIndex = updatedStudents.indexWhere((s) => s.studentId == studentId);
          
          if (studentIndex != -1) {
            final student = updatedStudents[studentIndex];
            final evaluations = List<EvaluationRecord>.from(student.evaluations)
              ..add(EvaluationRecord(
                date: DateTime.now(),
                rating: evaluation,
              ));
            
            updatedStudents[studentIndex] = student.copyWith(
              evaluations: evaluations,
            );
            
            circles[circleIndex] = circle.copyWith(
              students: updatedStudents,
              updatedAt: DateTime.now(),
            );
            
            emit(MemorizationCirclesLoaded(circles));
          }
        }
      }
      
      // Then update the backend
      final evalRecord = EvaluationRecord(
        date: DateTime.now(),
        rating: evaluation,
      );
      
      await repository.updateStudentAttendanceAndEvaluation(
        circleId: circleId,
        studentId: studentId,
        evaluation: evalRecord,
      );
      
      // Refresh the data to ensure consistency
      await loadCircleDetails(circleId);
    } catch (e) {
      if (!_isClosed) {
      emit(MemorizationCirclesError('حدث خطأ أثناء تحديث تقييم الطالب'));
        // Reload the circle to ensure UI is in sync
        await loadCircleDetails(circleId);
      }
    }
  }

  Future<void> updateStudentAttendance(String circleId, String studentId, bool isPresent) async {
    if (_isClosed) return;
    
    try {
      // Optimistically update the UI first
      if (state is MemorizationCirclesLoaded) {
        final currentState = state as MemorizationCirclesLoaded;
        final circles = List<MemorizationCircle>.from(currentState.circles);
        final circleIndex = circles.indexWhere((c) => c.id == circleId);
        
        if (circleIndex != -1) {
          final circle = circles[circleIndex];
          final updatedStudents = List<StudentRecord>.from(circle.students);
          final studentIndex = updatedStudents.indexWhere((s) => s.studentId == studentId);
          
          if (studentIndex != -1) {
            final student = updatedStudents[studentIndex];
            final attendance = List<AttendanceRecord>.from(student.attendance)
              ..add(AttendanceRecord(
                date: DateTime.now(),
                isPresent: isPresent,
              ));
            
            updatedStudents[studentIndex] = student.copyWith(
              attendance: attendance,
            );
            
            circles[circleIndex] = circle.copyWith(
              students: updatedStudents,
              updatedAt: DateTime.now(),
            );
            
            emit(MemorizationCirclesLoaded(circles));
          }
        }
      }
      
      // Then update the backend
      final attendanceRecord = AttendanceRecord(
        date: DateTime.now(),
        isPresent: isPresent,
      );
      
      await repository.updateStudentAttendanceAndEvaluation(
        circleId: circleId,
        studentId: studentId,
        attendance: attendanceRecord,
      );
      
      // Refresh the data to ensure consistency
      await loadCircleDetails(circleId);
    } catch (e) {
      if (!_isClosed) {
      emit(MemorizationCirclesError('حدث خطأ أثناء تحديث حضور الطالب'));
        // Reload the circle to ensure UI is in sync
        await loadCircleDetails(circleId);
      }
    }
  }

  void _updateCache(List<MemorizationCircle> circles) {
    for (var circle in circles) {
      _circlesCache[circle.id] = circle;
    }
  }

  // Replace a single circle in current state without fetching from backend
  void replaceCircle(MemorizationCircle updatedCircle) {
    _circlesCache[updatedCircle.id] = updatedCircle;

    if (state is MemorizationCirclesLoaded && !_isClosed) {
      final currentCircles = (state as MemorizationCirclesLoaded).circles;
      final updatedCircles = currentCircles.map((c) => c.id == updatedCircle.id ? updatedCircle : c).toList();
      emit(MemorizationCirclesLoaded(updatedCircles));
    }
  }

  @override
  Future<void> close() {
    _isClosed = true;
    _circlesCache.clear();
    return super.close();
  }
}
