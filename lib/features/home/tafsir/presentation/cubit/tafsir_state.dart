import 'package:equatable/equatable.dart';
import '../../models/tafsir_model.dart';

abstract class TafsirState extends Equatable {
  const TafsirState();

  @override
  List<Object?> get props => [];
}

class TafsirInitial extends TafsirState {}

class TafsirLoading extends TafsirState {}

class TafsirSurahListLoaded extends TafsirState {
  final List<SurahModel> surahs;

  const TafsirSurahListLoaded(this.surahs);

  @override
  List<Object?> get props => [surahs];
}

class TafsirSurahLoaded extends TafsirState {
  final SurahModel surah;
  
  const TafsirSurahLoaded(this.surah);
  
  @override
  List<Object?> get props => [surah];
}

class TafsirError extends TafsirState {
  final String message;

  const TafsirError(this.message);

  @override
  List<Object?> get props => [message];
} 