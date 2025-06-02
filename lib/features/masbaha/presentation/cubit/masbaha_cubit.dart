import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'masbaha_state.dart';

class MasbahaCubit extends Cubit<MasbahaState> {
  static const String _counterKey = 'masbaha_counter';
  static const String _savedCountsKey = 'masbaha_saved_counts';
  static const int maxCount = 1000; // Maximum count limit
  
  MasbahaCubit() : super(const MasbahaState()) {
    _loadSavedData();
  }
  
  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final counter = prefs.getInt(_counterKey) ?? 0;
      final savedCountsList = prefs.getStringList(_savedCountsKey);
      
      final savedCounts = savedCountsList != null 
          ? savedCountsList.map((e) => int.parse(e)).toList() 
          : <int>[];
          
      emit(state.copyWith(counter: counter, savedCounts: savedCounts));
    } catch (e) {
      // Handle any errors silently
    }
  }
  
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_counterKey, state.counter);
      await prefs.setStringList(
        _savedCountsKey, 
        state.savedCounts.map((e) => e.toString()).toList()
      );
    } catch (e) {
      // Handle any errors silently
    }
  }

  void increment() {
    // Only increment if counter is less than the maximum limit
    if (state.counter < maxCount) {
      final newState = state.copyWith(counter: state.counter + 1);
      emit(newState);
      _saveData();
    }
  }

  void reset() {
    final newState = state.copyWith(counter: 0);
    emit(newState);
    _saveData();
  }

  void setToOne() {
    // Only set to one if counter is currently zero
    if (state.counter == 0) {
      final newState = state.copyWith(counter: 1);
      emit(newState);
      _saveData();
    }
  }

  void saveCount() {
    if (state.counter > 0) {
      final updatedSavedCounts = List<int>.from(state.savedCounts)..add(state.counter);
      final newState = state.copyWith(savedCounts: updatedSavedCounts);
      emit(newState);
      _saveData();
    }
  }
} 