import 'package:equatable/equatable.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../memorization_circles/data/models/memorization_circle_model.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminUsersLoaded extends AdminState {
  final List<UserModel> users;

  const AdminUsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
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

class AdminCirclesLoaded extends AdminState {
  final List<MemorizationCircle> circles;

  const AdminCirclesLoaded(this.circles);

  @override
  List<Object?> get props => [circles];
}

class AdminCircleCreated extends AdminState {
  final MemorizationCircle circle;

  const AdminCircleCreated(this.circle);

  @override
  List<Object?> get props => [circle];
}

class AdminCircleUpdated extends AdminState {
  final MemorizationCircle circle;

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

class AdminTeachersLoaded extends AdminState {
  final List<UserModel> teachers;

  const AdminTeachersLoaded(this.teachers);

  @override
  List<Object?> get props => [teachers];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
