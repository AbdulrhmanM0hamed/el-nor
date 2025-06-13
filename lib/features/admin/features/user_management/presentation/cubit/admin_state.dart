import 'package:equatable/equatable.dart';
import '../../../../data/models/student_model.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

// ==================== Base States ====================
// Initial state when the app starts
// حالة البداية عند بدء التطبيق
class AdminInitial extends AdminState {}

// Loading state for all operations
// حالة التحميل لجميع العمليات
class AdminLoading extends AdminState {}

// Error state with error message
// حالة الخطأ مع رسالة الخطأ
class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object> get props => [message];
}

// ==================== User Management States ====================
// State for loaded users list
// حالة قائمة المستخدمين المحمولة
class AdminUsersLoaded extends AdminState {
  final List<StudentModel> users;

  const AdminUsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

// State for loaded teachers list
// حالة قائمة المعلمين المحمولة
class AdminTeachersLoaded extends AdminState {
  final List<StudentModel> teachers;

  const AdminTeachersLoaded(this.teachers);

  @override
  List<Object?> get props => [teachers];
}

// State for loaded students list
// حالة قائمة الطلاب المحمولة
class AdminStudentsLoaded extends AdminState {
  final List<StudentModel> students;

  const AdminStudentsLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

// State for updated user role
// حالة تحديث دور المستخدم
// class AdminUserRoleUpdated extends AdminState {
//   final String userId;
//   final bool isAdmin;
//   final bool isTeacher;

//   const AdminUserRoleUpdated({
//     required this.userId,
//     required this.isAdmin,
//     required this.isTeacher,
//   });

//   @override
//   List<Object?> get props => [userId, isAdmin, isTeacher];
// }

// ==================== Teacher Assignment States ====================
// State for teacher assignment
// حالة تعيين المعلم
class AdminTeacherAssigned extends AdminState {
  final String circleId;
  final String teacherId;
  final String teacherName;

  const AdminTeacherAssigned({
    required this.circleId,
    required this.teacherId,
    required this.teacherName,
  });

  @override
  List<Object?> get props => [circleId, teacherId, teacherName];
}

// ==================== Learning Plan States ====================
// State for uploaded learning plan
// حالة رفع خطة التعلم
class AdminLearningPlanUploaded extends AdminState {
  final String circleId;
  final String? url;

  const AdminLearningPlanUploaded(this.circleId, this.url);

  @override
  List<Object?> get props => [circleId, url];
}

// State for deleted learning plan
// حالة حذف خطة التعلم
class AdminLearningPlanDeleted extends AdminState {
  final String circleId;

  const AdminLearningPlanDeleted(this.circleId);

  @override
  List<Object> get props => [circleId];
}

// State for saved learning plan URL
// حالة حفظ رابط خطة التعلم
class AdminLearningPlanSaved extends AdminState {
  final String oldUrl;

  const AdminLearningPlanSaved(this.oldUrl);

  @override
  List<Object?> get props => [oldUrl];
}
