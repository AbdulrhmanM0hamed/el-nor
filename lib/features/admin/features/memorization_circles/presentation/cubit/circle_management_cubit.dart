import 'package:noor_quran/features/admin/data/models/memorization_circle_model.dart';
import 'package:noor_quran/features/admin/data/models/student_model.dart';
import 'package:noor_quran/features/admin/data/models/surah_assignment.dart';
import 'package:noor_quran/features/admin/features/memorization_circles/data/circle_management_repo.dart';
import 'package:noor_quran/features/admin/features/memorization_circles/presentation/cubit/circle_management_state.dart';
import 'package:noor_quran/features/admin/features/user_management/presentation/cubit/admin_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CircleManagementCubit extends Cubit<AdminState> {
  final CircleManagementRepository _circleManagementRepository;

  CircleManagementCubit(this._circleManagementRepository)
      : super(AdminInitial());

  Future<void> loadAllCircles({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && state is AdminCirclesLoaded) {
        final currentState = state as AdminCirclesLoaded;
        emit(AdminCirclesLoaded(currentState.circles));
        return;
      }

      List<StudentModel> currentTeachers = [];
      if (state is AdminTeachersLoaded) {
        currentTeachers = (state as AdminTeachersLoaded).teachers;
      }

      if (!isClosed && (!(state is AdminCirclesLoaded) || forceRefresh)) {
        emit(AdminLoading());
      }

      final circles = await _circleManagementRepository.getAllCircles();

      if (isClosed) return;

      if (currentTeachers.isNotEmpty) {
        final enhancedCircles = circles.map((circle) {
          if (circle.teacherId != null &&
              circle.teacherId!.isNotEmpty &&
              (circle.teacherName == null || circle.teacherName!.isEmpty)) {
            final matchingTeachers = currentTeachers
                .where((t) => t.id == circle.teacherId && t.isTeacher)
                .toList();

            if (matchingTeachers.isNotEmpty) {
              final teacher = matchingTeachers.first;
              return circle.copyWith(teacherName: teacher.name);
            }
          }
          return circle;
        }).toList();

        if (!isClosed) {
          emit(AdminTeachersLoaded(currentTeachers));
          emit(AdminCirclesLoaded(enhancedCircles));
        }
      } else {
        if (!isClosed) {
          emit(AdminCirclesLoaded(circles));
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(AdminError('حدث خطأ أثناء تحميل حلقات التحفيظ: ${e.toString()}'));
      }
    }
  }

  Future<void> createCircle({
    required String name,
    required String description,
    required DateTime startDate,
    String? teacherId,
    String? teacherName,
    required List<SurahAssignment> surahs,
    List<String>? studentIds,
    bool isExam = false,
    String? learningPlanUrl,
  }) async {
    try {
      emit(AdminLoading());

      // Debug logging for learning plan URL

      // إنشاء كائن حلقة تحفيظ جديد
      final newCircle = MemorizationCircleModel.create(
        name: name,
        description: description,
        teacherId: teacherId,
        teacherName: teacherName,
        isExam: isExam,
        startDate: startDate,
        surahs: surahs,
        studentIds: studentIds,
        learningPlanUrl: learningPlanUrl,
      );

      // Debug logging after creating circle model

      // إضافة الحلقة باستخدام المستودع
      final createdCircle =
          await _circleManagementRepository.addCircle(newCircle);

      // First emit creation success
      emit(AdminCircleCreated(createdCircle));

      // Then refresh the circles list
      await loadAllCircles(forceRefresh: true);
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء إنشاء حلقة التحفيظ: ${e.toString()}'));
    }
  }

  Future<void> updateCircle({
    required String id,
    required String name,
    required String description,
    required DateTime startDate,
    String? teacherId,
    String? teacherName,
    required List<SurahAssignment> surahAssignments,
    List<String>? studentIds,
    bool isExam = false,
    String? learningPlanUrl,
  }) async {
    try {
      emit(AdminLoading());

      // الحصول على الحلقة الحالية
      final circles = await _circleManagementRepository.getAllCircles();
      final circle = circles.firstWhere((c) => c.id == id);

      // تحديث الحلقة بالبيانات الجديدة
      final updatedCircle = circle.copyWith(
        name: name,
        description: description,
        startDate: startDate,
        teacherId: teacherId,
        teacherName: teacherName,
        surahAssignments: surahAssignments,
        studentIds: studentIds,
        isExam: isExam,
        learningPlanUrl: learningPlanUrl,
        updatedAt: DateTime.now(),
      );

      // حفظ التغييرات
      final savedCircle =
          await _circleManagementRepository.updateCircle(updatedCircle);

      // First emit update success
      emit(AdminCircleUpdated(savedCircle));

      // Then refresh the circles list
      await loadAllCircles(forceRefresh: true);
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحديث حلقة التحفيظ: ${e.toString()}'));
    }
  }

  Future<void> deleteCircle(String circleId) async {
    if (isClosed) return;

    try {
      emit(AdminLoading());

      // حذف الحلقة باستخدام المستودع
      await _circleManagementRepository.deleteCircle(circleId);

      if (isClosed) return;

      emit(AdminCircleDeleted(circleId));

      // إعادة تحميل قائمة الحلقات لعكس التغييرات
      await loadAllCircles();
    } catch (e) {
      if (isClosed) return;

      emit(AdminError('حدث خطأ أثناء حذف حلقة التحفيظ: ${e.toString()}'));
    }
  }

  Future<void> assignTeacherToCircle({
    required String circleId,
    required String teacherId,
    required String teacherName,
  }) async {
    try {
      // Store current state to preserve data
      final currentState = state;
      List<StudentModel> currentTeachers = [];

      // Preserve teacher data if available
      if (currentState is AdminTeachersLoaded) {
        currentTeachers = currentState.teachers;
      }

      // Only emit loading if we don't have teacher data to preserve
      if (currentTeachers.isEmpty) {
        emit(AdminLoading());
      }

      // طباعة معلومات للتشخيص

      // تحديث الحلقة بمعلم جديد مباشرة في قاعدة البيانات
      try {
        // تحديث حقل teacher_id فقط في قاعدة البيانات
        await _circleManagementRepository.updateCircleTeacher(
            circleId, teacherId);

        // If we have teacher data, re-emit it first to preserve it
        if (currentTeachers.isNotEmpty) {
          emit(AdminTeachersLoaded(currentTeachers));
        }

        // Then emit the teacher assigned state
        emit(AdminTeacherAssigned(
          circleId: circleId,
          teacherId: teacherId,
          teacherName: teacherName,
        ));

        // إعادة تحميل قائمة الحلقات لعكس التغييرات
        // Use a more targeted approach instead of reloading everything
        final circles = await _circleManagementRepository.getAllCircles();
        emit(AdminCirclesLoaded(circles));
      } catch (e) {
        throw Exception('فشل في تحديث معلم الحلقة: $e');
      }
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تعيين المعلم للحلقة: ${e.toString()}'));
    }
  }

  Future<void> loadCircleStudents(
      String circleId, List<String> studentIds) async {
    try {
      emit(AdminLoading());

      // طباعة معلومات للتصحيح

      if (studentIds.isEmpty) {
        // إذا لم يكن هناك طلاب، نعود إلى الحالة السابقة
        final circles = await _circleManagementRepository.getAllCircles();
        emit(AdminCirclesLoaded(circles));
        return;
      }

      // تحميل جميع الحلقات
      final circles = await _circleManagementRepository.getAllCircles();

      // تحديث الحلقة المحددة بالطلاب المحملين
      final updatedCircles = circles.map((circle) {
        if (circle.id == circleId) {
          // تحديث قائمة معرفات الطلاب فقط
          return circle.copyWith(studentIds: studentIds);
        }
        return circle;
      }).toList();

      // إرسال الحالة المحدثة
      emit(AdminCirclesLoaded(updatedCircles));
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحميل طلاب الحلقة: ${e.toString()}'));
    }
  }

  // جلب سجلات طالب في حلقة معينة
  Future<void> loadStudentRecords(String circleId, String studentId) async {
    try {
      emit(AdminLoading());

      // تحميل بيانات الحلقة المحدثة
      final circles = await _circleManagementRepository.getAllCircles();

      emit(AdminCirclesLoaded(circles));
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحميل سجلات الطالب: ${e.toString()}'));
    }
  }
}
