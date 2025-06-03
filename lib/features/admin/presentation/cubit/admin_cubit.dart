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
  
  Future<void> loadAllCircles() async {
    try {
      emit(AdminLoading());

      // جلب جميع حلقات التحفيظ باستخدام المستودع
      final circles = await _adminRepository.getAllMemorizationCircles();
      
      // جلب المعلمين والطلاب أيضًا
      await loadTeachers();
      await loadStudents();
      
      emit(AdminCirclesLoaded(circles));
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحميل حلقات التحفيظ: ${e.toString()}'));
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
      emit(AdminLoading());

      // طباعة معلومات للتشخيص
      print('محاولة تعيين المعلم $teacherName (المعرف: $teacherId) للحلقة $circleId');

      // تحديث الحلقة بمعلم جديد مباشرة في قاعدة البيانات
      try {
        // تحديث حقل teacher_id فقط في قاعدة البيانات
        await _adminRepository.updateCircleTeacher(circleId, teacherId);
        
        emit(AdminTeacherAssigned(
          circleId: circleId,
          teacherId: teacherId,
          teacherName: teacherName,
        ));

        // إعادة تحميل قائمة الحلقات لعكس التغييرات
        await loadAllCircles();
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
