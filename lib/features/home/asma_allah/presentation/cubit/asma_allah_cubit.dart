import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/allah_names_repository.dart';
import '../../models/allah_name_model.dart';
import 'asma_allah_states.dart';

class AsmaAllahCubit extends Cubit<AsmaAllahState> {
  final AllahNamesRepository _repository;

  AsmaAllahCubit(this._repository) : super(AsmaAllahInitial());

  Future<void> loadAllahNames() async {
    emit(AsmaAllahLoading());
    try {
      final names = await _repository.getAllahNames();
      if (names.isEmpty) {
        emit(AsmaAllahError('لا يمكن تحميل أسماء الله الحسنى'));
        return;
      }
      emit(AsmaAllahLoaded(allNames: names));
    } catch (e) {
      emit(AsmaAllahError('حدث خطأ: $e'));
    }
  }

  void selectName(int index) {
    final currentState = state;
    if (currentState is AsmaAllahLoaded) {
      emit(currentState.copyWith(selectedNameIndex: index));
    }
  }

  AllahName? getSelectedName() {
    final currentState = state;
    if (currentState is AsmaAllahLoaded && currentState.selectedNameIndex != null) {
      return currentState.allNames[currentState.selectedNameIndex!];
    }
    return null;
  }
} 