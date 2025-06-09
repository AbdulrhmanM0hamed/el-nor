import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/quran_repository.dart';
import 'quran_audio_state.dart';

class QuranAudioCubit extends Cubit<QuranAudioState> {
  final QuranRepository repository;
  
  QuranAudioCubit({required this.repository}) : super(QuranAudioInitial());
  
  Future<void> getReciters() async {
    emit(QuranAudioLoading());
    
    final result = await repository.getReciters();
    
    result.fold(
      (failure) => emit(QuranAudioError(failure.message)),
      (reciters) => emit(QuranAudioLoaded(reciters)),
    );
  }
}