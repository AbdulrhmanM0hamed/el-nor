import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/admin_repository.dart';

import '../../../../data/models/student_model.dart';
import 'admin_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _adminRepository;

  AdminCubit(this._adminRepository) : super(AdminInitial());

  Future<String?> uploadLearningPlan(PlatformFile file) async {
    try {
      emit(AdminLoading());
      final fileName = path.basename(file.name);
      if (file.bytes != null) {
        return await _adminRepository.uploadLearningPlan(fileName, file.bytes!);
      }
      emit(AdminError('الملف فارغ'));
      return null;
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء رفع خطة التعلم: ${e.toString()}'));
      return null;
    }
  }

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

      // Get updated users list
      final updatedUsers = await _adminRepository.getAllUsers();

      // Emit success with updated users list
      emit(AdminUsersLoaded(updatedUsers));
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحديث دور المستخدم: ${e.toString()}'));
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

  Future<void> saveOldLearningPlan(String oldUrl) async {
    try {
      emit(AdminLoading());
      await _adminRepository.saveOldLearningPlan(oldUrl);
      emit(AdminLearningPlanSaved(oldUrl));
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء حفظ خطة التعلم القديمة: ${e.toString()}'));
    }
  }

  // تحميل طلاب حلقة محددة

  // تحديث حضور وتقييم الطالب

  // جلب سجلات طالب في حلقة معينة
}
