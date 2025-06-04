import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/models/memorization_circle_model.dart';
import '../../data/models/surah_assignment.dart';
import '../../data/models/student_model.dart';
import '../../../auth/data/models/user_model.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _adminRepository;

  AdminCubit(this._adminRepository) : super(AdminInitial());

  Future<List<StudentModel>> loadTeachers() async {
    try {
      // جلب جميع المستخدمين الذين لديهم صلاحية معلم
      final teachers = await _adminRepository.getAllTeachers();
      emit(AdminTeachersLoaded(teachers));
      return teachers;
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحميل المعلمين: ${e.toString()}'));
      return [];
    }
  }

  Future<void> reloadTeachers() async {
    try {
      await loadTeachers();
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحميل المعلمين: ${e.toString()}'));
    }
  }

  Future<void> loadAllUsers() async {
    try {
      emit(AdminLoading());

      // التحقق من صلاحيات المشرف
      final isAdmin = await _adminRepository.checkAdminPermission();
      if (!isAdmin) {
        emit(const AdminError('ليس لديك صلاحية للوصول إلى هذه الصفحة'));
        return;
      }

      // الحصول على جميع المستخدمين
      final data = await _adminRepository.getAllUsers();
      emit(AdminUsersLoaded(data));
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحميل المستخدمين: ${e.toString()}'));
    }
  }

  Future<void> updateUserRole({
    required String userId,
    required bool isAdmin,
    required bool isTeacher,
  }) async {
    try {
      emit(AdminLoading());

      // تحديث دور المستخدم باستخدام المستودع
      await _adminRepository.updateUserRole(
        userId: userId,
        isAdmin: isAdmin,
        isTeacher: isTeacher,
      );
      
      // إرسال حالة تحديث دور المستخدم
      emit(AdminUserRoleUpdated(
        userId: userId,
        isAdmin: isAdmin,
        isTeacher: isTeacher,
      ));

      // إعادة تحميل قائمة المستخدمين والمعلمين
      await loadAllUsers();
      await loadTeachers();
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحديث دور المستخدم: ${e.toString()}'));
    }
  }

  Future<List<MemorizationCircleModel>> loadAllCircles({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && state is AdminCirclesLoaded) {
        final currentState = state as AdminCirclesLoaded;
        return currentState.circles;
      }

      List<StudentModel> currentTeachers = [];
      if (state is AdminTeachersLoaded) {
        currentTeachers = (state as AdminTeachersLoaded).teachers;
      }

      if (!(state is AdminCirclesLoaded) || forceRefresh) {
        emit(AdminLoading());
      }

      final circles = await _adminRepository.getAllCircles();

      if (currentTeachers.isNotEmpty) {
        final enhancedCircles = circles.map((circle) {
          if (circle.teacherId != null && 
              circle.teacherId!.isNotEmpty && 
              (circle.teacherName == null || circle.teacherName!.isEmpty)) {
            
            final matchingTeachers = currentTeachers.where(
              (t) => t.id == circle.teacherId && t.isTeacher
            ).toList();

            if (matchingTeachers.isNotEmpty) {
              final teacher = matchingTeachers.first;
              return circle.copyWith(teacherName: teacher.name);
            }
          }
          return circle;
        }).toList();

        emit(AdminTeachersLoaded(currentTeachers));
        emit(AdminCirclesLoaded(enhancedCircles));
        return enhancedCircles;
      } else {
        emit(AdminCirclesLoaded(circles));
        return circles;
      }
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحميل حلقات التحفيظ: ${e.toString()}'));
      return [];
    }
  }

  Future<List<StudentModel>> loadStudents() async {
    try {
      final students = await _adminRepository.getAllUsers();
      emit(AdminStudentsLoaded(students));
      return students;
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحميل الطلاب: ${e.toString()}'));
      return [];
    }
  }

  Future<void> createCircle({
    required String name,
    required String description,
    required DateTime startDate,
    String? teacherId,
    String? teacherName,
    List<SurahAssignment>? surahs,
    List<String>? studentIds,
  }) async {
    try {
      emit(AdminLoading());

      // إنشاء كائن حلقة تحفيظ جديد
      final newCircle = MemorizationCircleModel.create(
        name: name,
        description: description,
        teacherId: teacherId,
        teacherName: teacherName,
        isExam: false,
        startDate: startDate,
        surahs: surahs,
        studentIds: studentIds,
      );

      // إضافة الحلقة باستخدام المستودع
      final createdCircle = await _adminRepository.addCircle(newCircle);

      emit(AdminCircleCreated(createdCircle));

      // إعادة تحميل قائمة الحلقات لعكس التغييرات
      await loadAllCircles();
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
    List<SurahAssignment>? surahs,
    List<String>? studentIds,
  }) async {
    try {
      emit(AdminLoading());

      // الحصول على الحلقة الحالية
      final circles = await _adminRepository.getAllMemorizationCircles();
      final circle = circles.firstWhere((c) => c.id == id);
      
      // تحديث الحلقة بالبيانات الجديدة
      final updatedCircle = circle.copyWith(
        name: name,
        description: description,
        startDate: startDate,
        teacherId: teacherId,
        teacherName: teacherName,
        surahAssignments: surahs,
        studentIds: studentIds,
        updatedAt: DateTime.now(),
      );
      
      // حفظ التغييرات
      final savedCircle = await _adminRepository.updateCircle(updatedCircle);

      emit(AdminCircleUpdated(savedCircle));

      // إعادة تحميل قائمة الحلقات لعكس التغييرات
      await loadAllCircles();
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحديث حلقة التحفيظ: ${e.toString()}'));
    }
  }

  Future<void> deleteCircle(String circleId) async {
    try {
      emit(AdminLoading());

      // حذف الحلقة باستخدام المستودع
      await _adminRepository.deleteCircle(circleId);

      emit(AdminCircleDeleted(circleId));

      // إعادة تحميل قائمة الحلقات لعكس التغييرات
      await loadAllCircles();
    } catch (e) {
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
      print('محاولة تعيين المعلم $teacherName (المعرف: $teacherId) للحلقة $circleId');

      // تحديث الحلقة بمعلم جديد مباشرة في قاعدة البيانات
      try {
        // تحديث حقل teacher_id فقط في قاعدة البيانات
        await _adminRepository.updateCircleTeacher(circleId, teacherId);
        
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
        final circles = await _adminRepository.getAllMemorizationCircles();
        emit(AdminCirclesLoaded(circles));
      } catch (e) {
        print('خطأ في تحديث معلم الحلقة: $e');
        throw Exception('فشل في تحديث معلم الحلقة: $e');
      }
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تعيين المعلم للحلقة: ${e.toString()}'));
    }
  }
  
  // تحميل طلاب حلقة محددة
  Future<void> loadCircleStudents(String circleId, List<String> studentIds) async {
    try {
      emit(AdminLoading());
      
      // طباعة معلومات للتصحيح
      print('تحميل بيانات ${studentIds.length} طالب للحلقة $circleId');
      
      if (studentIds.isEmpty) {
        // إذا لم يكن هناك طلاب، نعود إلى الحالة السابقة
        final circles = await _adminRepository.getAllCircles();
        emit(AdminCirclesLoaded(circles));
        return;
      }
      
      // تحميل بيانات الطلاب من المستودع
      final students = await _adminRepository.getStudentsByIds(studentIds);
      print('تم تحميل ${students.length} طالب من أصل ${studentIds.length}');
      
      // تحميل جميع الحلقات
      final circles = await _adminRepository.getAllCircles();
      
      // تحديث الحلقة المحددة بالطلاب المحملين
      final updatedCircles = circles.map((circle) {
        if (circle.id == circleId) {
          // تحديث الحلقة بالطلاب الجدد
          return circle.copyWith(students: students);
        }
        return circle;
      }).toList();
      
      // إرسال الحالة المحدثة
      emit(AdminCirclesLoaded(updatedCircles));
    } catch (e) {
      print('خطأ في تحميل طلاب الحلقة: $e');
      emit(AdminError('حدث خطأ أثناء تحميل طلاب الحلقة: ${e.toString()}'));
    }
  }
}
