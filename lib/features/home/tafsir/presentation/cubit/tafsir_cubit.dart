import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/tafsir_repository.dart';
import 'tafsir_state.dart';

class TafsirCubit extends Cubit<TafsirState> {
  final TafsirRepository repository;

  TafsirCubit(this.repository) : super(TafsirInitial());

  Future<void> loadAllSurahs() async {
    try {
      emit(TafsirLoading());
      final surahs = await repository.getAllSurahsWithTafsir();
      emit(TafsirSurahListLoaded(surahs));
    } catch (e) {
      emit(TafsirError(e.toString()));
    }
  }

  Future<void> loadSurah(int surahId) async {
    try {
      emit(TafsirLoading());
      final surah = await repository.getSurahWithTafsir(surahId);
      if (surah != null) {
        emit(TafsirSurahLoaded(surah));
      } else {
        emit(const TafsirError('السورة غير موجودة'));
      }
    } catch (e) {
      emit(TafsirError(e.toString()));
    }
  }
} 