part of 'learning_plan_cubit.dart';

abstract class LearningPlanState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LearningPlanInitial extends LearningPlanState {}

class LearningPlanLoading extends LearningPlanState {}

class LearningPlanEmpty extends LearningPlanState {}

class LearningPlanLoaded extends LearningPlanState {
  final String url;
  LearningPlanLoaded(this.url);

  @override
  List<Object?> get props => [url];
}

class LearningPlanUploading extends LearningPlanState {}

class LearningPlanUploadSuccess extends LearningPlanState {}

class LearningPlanError extends LearningPlanState {
  final String message;
  LearningPlanError(this.message);

  @override
  List<Object?> get props => [message];
}
