import 'package:equatable/equatable.dart';
import '../../data/models/memorization_circle_model.dart';
import '../../data/models/student_model.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminUsersLoaded extends AdminState {
  final List<StudentModel> users;

  const AdminUsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class AdminTeachersLoaded extends AdminState {
  final List<StudentModel> teachers;

  const AdminTeachersLoaded(this.teachers);

  @override
  List<Object?> get props => [teachers];
}

class AdminCirclesLoaded extends AdminState {
  final List<MemorizationCircleModel> circles;

  const AdminCirclesLoaded(this.circles);

  @override
  List<Object?> get props => [circles];
}

class AdminStudentsLoaded extends AdminState {
  final List<StudentModel> students;

  const AdminStudentsLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

class AdminUserRoleUpdated extends AdminState {
  final String userId;
  final bool isAdmin;
  final bool isTeacher;

  const AdminUserRoleUpdated({
    required this.userId,
    required this.isAdmin,
    required this.isTeacher,
  });

  @override
  List<Object?> get props => [userId, isAdmin, isTeacher];
}

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

class AdminCircleStudentsLoaded extends AdminState {
  final String circleId;
  final List<StudentModel> students;
  const AdminCircleStudentsLoaded({
    required this.circleId,
    required this.students,
  });

  @override
  List<Object?> get props => [circleId, students];
}

class AdminTeacherAdded extends AdminState {
  final StudentModel teacher;

  const AdminTeacherAdded(this.teacher);

  @override
  List<Object?> get props => [teacher];
}

class AdminCircleCreated extends AdminState {
  final MemorizationCircleModel circle;

  const AdminCircleCreated(this.circle);

  @override
  List<Object?> get props => [circle];
}

class AdminCircleUpdated extends AdminState {
  final MemorizationCircleModel circle;

  const AdminCircleUpdated(this.circle);

  @override
  List<Object?> get props => [circle];
}

class AdminCircleDeleted extends AdminState {
  final String circleId;

  const AdminCircleDeleted(this.circleId);

  @override
  List<Object?> get props => [circleId];
}

class AdminTeacherRemoved extends AdminState {
  final String teacherId;

  const AdminTeacherRemoved(this.teacherId);

  @override
  List<Object?> get props => [teacherId];
}
