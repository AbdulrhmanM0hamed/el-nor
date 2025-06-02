// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter/material.dart';
// import '../../services/service_locator.dart';
// import '../../services/cache/cache_service.dart';
// import 'theme_state.dart';

// class ThemeCubit extends Cubit<ThemeState> {
//   ThemeCubit() : super(ThemeInitial()) {
//     loadTheme();
//   }

//   ThemeMode _themeMode = ThemeMode.light;
//   ThemeMode get themeMode => _themeMode;

//   Future<void> loadTheme() async {
//     final isDark = await sl<CacheService>().getDarkMode();
//     _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
//     emit(ThemeChanged(_themeMode));
//   }

//   Future<void> setTheme(ThemeMode mode) async {
//     _themeMode = mode;
//     await sl<CacheService>().setDarkMode(mode == ThemeMode.dark);
//     emit(ThemeChanged(_themeMode));
//   }
// } 