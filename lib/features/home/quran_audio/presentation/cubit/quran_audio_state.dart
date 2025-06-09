import 'package:equatable/equatable.dart';
import '../../data/models/quran_reciter_model.dart';

abstract class QuranAudioState extends Equatable {
  const QuranAudioState();
  
  @override
  List<Object?> get props => [];
}

class QuranAudioInitial extends QuranAudioState {}

class QuranAudioLoading extends QuranAudioState {}

class QuranAudioLoaded extends QuranAudioState {
  final List<QuranCollection> reciters;
  
  const QuranAudioLoaded(this.reciters);
  
  @override
  List<Object?> get props => [reciters];
}

class QuranAudioError extends QuranAudioState {
  final String message;
  
  const QuranAudioError(this.message);
  
  @override
  List<Object?> get props => [message];
}