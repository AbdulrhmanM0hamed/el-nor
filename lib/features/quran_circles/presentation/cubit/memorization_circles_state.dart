import 'package:noor_quran/features/quran_circles/data/models/memorization_circle_model.dart';
import 'package:equatable/equatable.dart';

abstract class MemorizationCirclesState extends Equatable {
  const MemorizationCirclesState();

  @override
  List<Object?> get props => [];
}

class MemorizationCirclesInitial extends MemorizationCirclesState {}

class MemorizationCirclesLoading extends MemorizationCirclesState {}

class MemorizationCirclesLoaded extends MemorizationCirclesState {
  final List<MemorizationCircle> circles;

  const MemorizationCirclesLoaded(this.circles);

  @override
  List<Object?> get props => [circles];
}

class MemorizationCircleDetailsLoaded extends MemorizationCirclesState {
  final MemorizationCircle circle;

  const MemorizationCircleDetailsLoaded(this.circle);

  @override
  List<Object?> get props => [circle];
}

class MemorizationCirclesError extends MemorizationCirclesState {
  final String message;

  const MemorizationCirclesError(this.message);

  @override
  List<Object?> get props => [message];
}