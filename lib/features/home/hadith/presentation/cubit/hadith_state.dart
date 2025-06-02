import 'package:equatable/equatable.dart';
import '../../models/hadith_model.dart';

abstract class HadithState extends Equatable {
  const HadithState();

  @override
  List<Object> get props => [];
}

class HadithInitial extends HadithState {}

class HadithLoading extends HadithState {}

class HadithLoaded extends HadithState {
  final List<HadithCollection> collections;

  const HadithLoaded(this.collections);

  @override
  List<Object> get props => [collections];
}

class HadithError extends HadithState {
  final String message;

  const HadithError(this.message);

  @override
  List<Object> get props => [message];
} 