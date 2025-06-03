import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/models/memorization_circle_model.dart';
import '../../data/models/surah_assignment.dart';
import '../../data/models/teacher_model.dart';
import '../../data/models/student_model.dart';
import '../../../auth/data/models/user_model.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _adminRepository;

  AdminCubit(this._adminRepository) : super(AdminInitial());

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

      // إعادة تحميل قائمة المستخدمين
      await loadAllUsers();
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحديث دور المستخدم: ${e.toString()}'));
    }
  }
  
  // إضافة مستخدم كمعلم في جدول المعلمين
  Future<void> addTeacher(UserModel user) async {
    try {
      // تحويل UserModel إلى TeacherModel
      final now = DateTime.now();
      final teacherModel = TeacherModel(
        id: user.id,
        name: user.name ?? user.email.split('@').first, // استخدام جزء من البريد الإلكتروني إذا كان الاسم فارغًا
        email: user.email,
        phone: user.phone,
        profileImageUrl: user.profileImageUrl,
        createdAt: now, // Usar la fecha actual para createdAt
        updatedAt: now,
      );
      
      // التحقق مما إذا كان المعلم موجودًا بالفعل في جدول المعلمين
      try {
        // محاولة إضافة المعلم إلى جدول المعلمين
        await _adminRepository.addTeacher(teacherModel);
        
        // إعادة تحميل قائمة المعلمين
        await loadTeachers();
        
        emit(AdminTeacherAdded(teacherModel));
      } catch (e) {
        // إذا كان المعلم موجودًا بالفعل، نتجاهل الخطأ
        if (e.toString().contains('duplicate key')) {
          // المعلم موجود بالفعل، لا نفعل شيئًا
          return;
        } else {
          // خطأ آخر، نعيد رميه
          throw e;
        }
      }
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء إضافة المعلم: ${e.toString()}'));
    }
  }
  
  // طرق إدارة حلقات التحفيظ
  
  Future<List<MemorizationCircleModel>> loadAllCircles({bool forceRefresh = false}) async {
    try {
      // Check if we already have circles loaded and this is not a forced refresh
      if (!forceRefresh && state is AdminCirclesLoaded) {
        final currentState = state as AdminCirclesLoaded;
        
        // If we already have circles, just return them without emitting a new state
        print('AdminCubit: Circles already loaded, returning existing data');
        return currentState.circles;
      }
      
      // Preserve teacher data if available
      List<TeacherModel> currentTeachers = [];
      if (state is AdminTeachersLoaded) {
        currentTeachers = (state as AdminTeachersLoaded).teachers;
        print('AdminCubit: Preserving ${currentTeachers.length} teachers during circle load');
      }
      
      // Only emit loading if we don't already have data or this is a forced refresh
      if (!(state is AdminCirclesLoaded) || forceRefresh) {
        emit(AdminLoading());
      }
      
      // Fetch all circles
      final circles = await _adminRepository.getAllCircles();
      
      // If we have teacher data, try to enhance the circles with teacher names
      if (currentTeachers.isNotEmpty) {
        final enhancedCircles = circles.map((circle) {
          // If the circle has a teacherId but no teacherName, try to find the teacher
          if (circle.teacherId != null && 
              circle.teacherId!.isNotEmpty && 
              (circle.teacherName == null || circle.teacherName!.isEmpty)) {
            
            // Find the matching teacher
            final matchingTeachers = currentTeachers.where((t) => t.id == circle.teacherId).toList();
            if (matchingTeachers.isNotEmpty) {
              final teacher = matchingTeachers.first;
              print('AdminCubit: Enhanced circle ${circle.id} with teacher name: ${teacher.name}');
              // Create a new circle with the teacher name
              return circle.copyWith(teacherName: teacher.name);
            }
          }
          return circle;
        }).toList();
        
        // Re-emit teacher data first to avoid losing it
        emit(AdminTeachersLoaded(currentTeachers));
        
        // Then emit enhanced circles loaded
        emit(AdminCirclesLoaded(enhancedCircles));
        return enhancedCircles;
      } else {
        // Just emit circles loaded without enhancement
        emit(AdminCirclesLoaded(circles));
        return circles;
      }
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحميل حلقات التحفيظ: ${e.toString()}'));
      return [];
    }
  }
  
  Future<List<TeacherModel>> loadTeachers() async {
    try {
      // جلب جميع المعلمين
      final teachers = await _adminRepository.getAllTeachers();
      emit(AdminTeachersLoaded(teachers));
      return teachers;
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحميل المعلمين: ${e.toString()}'));
      return [];
    }
  }
  
  Future<List<StudentModel>> loadStudents() async {
    try {
      // جلب جميع المستخدمين وتحويلهم إلى طلاب
      final users = await _adminRepository.getAllUsers();
      final now = DateTime.now();
      
      // تحويل المستخدمين إلى طلاب
      final students = users.map((user) => StudentModel(
        id: user.id,
        name: user.name ?? '',  // name puede ser nulo en UserModel
        email: user.email,      // email no es nulo en UserModel
        createdAt: now,
        updatedAt: now,
        phoneNumber: user.phone,
      )).toList();
      
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
      List<TeacherModel> currentTeachers = [];
      
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
  
  // طريقة لاستدعاء تحميل المعلمين من المستودع
  Future<void> reloadTeachers() async {
    try {
      // استدعاء الطريقة المعرفة مسبقًا
      await loadTeachers();
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحميل المعلمين: ${e.toString()}'));
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
