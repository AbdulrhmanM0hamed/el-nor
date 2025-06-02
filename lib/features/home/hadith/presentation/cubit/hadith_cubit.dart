import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/hadith_repository.dart';
import 'hadith_state.dart';

class HadithCubit extends Cubit<HadithState> {
  final HadithRepository repository;

  HadithCubit(this.repository) : super(HadithInitial());

  Future<void> loadHadithCollections() async {
    try {
      emit(HadithLoading());
      final collections = await repository.getHadithCollections();
      emit(HadithLoaded(collections));
    } catch (e) {
      emit(HadithError(e.toString()));
    }
  }
} 