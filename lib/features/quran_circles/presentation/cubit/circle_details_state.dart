import 'package:equatable/equatable.dart';
import '../../data/models/memorization_circle_model.dart';

abstract class CircleDetailsState extends Equatable {
  const CircleDetailsState();

  @override
  List<Object?> get props => [];
}

class CircleDetailsInitial extends CircleDetailsState {}

class CircleDetailsLoading extends CircleDetailsState {}

class CircleDetailsLoaded extends CircleDetailsState {
  final MemorizationCircle circle;
  final bool canManage;
  final String userId;
  final UserRole userRole;

  const CircleDetailsLoaded({
    required this.circle,
    required this.canManage,
    required this.userId,
    required this.userRole,
  });

  @override
  List<Object?> get props => [circle, canManage, userId, userRole];

  CircleDetailsLoaded copyWith({
    MemorizationCircle? circle,
    bool? canManage,
    String? userId,
    UserRole? userRole,
  }) {
    return CircleDetailsLoaded(
      circle: circle ?? this.circle,
      canManage: canManage ?? this.canManage,
      userId: userId ?? this.userId,
      userRole: userRole ?? this.userRole,
    );
  }
}

class CircleDetailsError extends CircleDetailsState {
  final String message;

  const CircleDetailsError(this.message);

  @override
  List<Object> get props => [message];
}

enum UserRole {
  admin,
  teacher,
  student,
} 