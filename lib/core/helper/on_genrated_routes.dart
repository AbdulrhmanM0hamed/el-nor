import 'package:beat_elslam/features/auth/presentation/screens/auth_check_screen.dart';
import 'package:beat_elslam/features/auth/presentation/screens/login_screen.dart';
import 'package:beat_elslam/features/auth/presentation/screens/register_screen.dart';
import 'package:beat_elslam/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:beat_elslam/features/auth/presentation/cubit/reset_password/reset_password_cubit.dart';
import 'package:beat_elslam/features/home/asma_allah/presentation/screens/asma_allah_screen.dart';
import 'package:beat_elslam/features/home/view/home_View.dart';
import 'package:beat_elslam/features/main_layout/main_layout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../services/service_locator.dart' as di;
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/home/azkar/presentation/screens/azkar_screen.dart';
import '../../features/home/azkar/presentation/screens/azkar_details_screen.dart';
import '../../features/home/azkar/models/azkar_model.dart';
import '../../features/home/prayer_times/presentation/screens/prayer_times_screen.dart';
import '../../features/home/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import '../../features/home/prayer_times/data/repositories/prayer_times_repository.dart';
import '../../features/home/qupla/presentation/screens/qupla_screen.dart';
import '../../features/home/masbaha/presentation/screens/masbaha_screen.dart';
import '../../features/home/quran/presentation/screens/quran_optimized_screen.dart';
import '../../features/home/asma_allah/data/repositories/allah_names_repository.dart';
import '../../features/home/asma_allah/presentation/cubit/asma_allah_cubit.dart';
import '../../features/home/hadith/presentation/screens/hadith_sections_screen.dart';
import '../../features/home/hadith/data/repositories/hadith_repository.dart';
import '../../features/home/hadith/presentation/cubit/hadith_cubit.dart';
import '../../features/home/tafsir/presentation/screens/tafsir_surah_list_screen.dart';
import '../../features/home/tafsir/data/repositories/tafsir_repository.dart';
import '../../features/home/tafsir/presentation/cubit/tafsir_cubit.dart';
import '../../features/auth/presentation/screens/forget_password_screen.dart';
import '../../features/auth/presentation/screens/verification_code_screen.dart';
import '../../features/auth/presentation/screens/new_password_screen.dart';

final _logger = Logger();

// Función principal para manejar las rutas de la aplicación
Route<dynamic> onGenratedRoutes(RouteSettings settings) {
  _logger.i('Navigating to: ${settings.name}');
  
  // Determinar qué ruta mostrar basado en el nombre de la ruta
  final routeName = settings.name;
  
  // Rutas de autenticación
  if (routeName == AuthCheckScreen.routeName) {
    _logger.i('Navigating to AuthCheckScreen');
    return MaterialPageRoute(
      builder: (context) => BlocProvider<AuthCubit>(
        create: (context) => di.sl<AuthCubit>(),
        child: const AuthCheckScreen(),
      ),
    );
  }
  
  if (routeName == LoginScreen.routeName) {
    _logger.i('Navigating to LoginScreen');
    return MaterialPageRoute(
      builder: (context) => BlocProvider<AuthCubit>(
        create: (context) => di.sl<AuthCubit>(),
        child: const LoginScreen(),
      ),
    );
  }
  
  if (routeName == RegisterScreen.routeName) {
    _logger.i('Navigating to RegisterScreen');
    return MaterialPageRoute(
      builder: (context) => BlocProvider<AuthCubit>(
        create: (context) => di.sl<AuthCubit>(),
        child: const RegisterScreen(),
      ),
    );
  }
  
  if (routeName == '/main') {
    _logger.i('Navigating to MainLayoutScreen');
    return MaterialPageRoute(
      builder: (context) => const MainLayoutScreen(),
    );
  }
  
  if (routeName == ResetPasswordScreen.routeName) {
    _logger.i('Navigating to ResetPasswordScreen');
    return MaterialPageRoute(
      builder: (context) => BlocProvider<AuthCubit>(
        create: (context) => di.sl<AuthCubit>(),
        child: const ResetPasswordScreen(),
      ),
    );
  }
  
  if (routeName == ForgetPasswordScreen.routeName) {
    _logger.i('Navigating to ForgetPasswordScreen');
    return MaterialPageRoute(
      builder: (context) => BlocProvider<ResetPasswordCubit>(
        create: (context) => ResetPasswordCubit(authRepository: di.sl(), email: ''),
        child: const ForgetPasswordScreen(),
      ),
    );
  }

  if (routeName == VerificationCodeScreen.routeName) {
    _logger.i('Navigating to VerificationCodeScreen');
    final email = settings.arguments as String;
    return MaterialPageRoute(
      builder: (context) => BlocProvider<ResetPasswordCubit>(
        create: (context) => ResetPasswordCubit(authRepository: di.sl(), email: email),
        child: VerificationCodeScreen(email: email),
      ),
    );
  }

  if (routeName == NewPasswordScreen.routeName) {
    _logger.i('Navigating to NewPasswordScreen');
    final email = settings.arguments as String;
    return MaterialPageRoute(
      builder: (context) => BlocProvider<ResetPasswordCubit>(
        create: (context) => ResetPasswordCubit(authRepository: di.sl(), email: email),
        child: NewPasswordScreen(email: email),
      ),
    );
  }
  
  // Rutas de funcionalidades principales
  if (routeName == '/athkar') {
    _logger.i('Navigating to AzkarScreen');
    return MaterialPageRoute(builder: (context) => const AzkarScreen());
  }

  if (routeName == '/azkar-details') {
    final category = settings.arguments as AzkarCategory;
    _logger.i('Navigating to AzkarDetailsScreen with category: ${category.name}');
    return MaterialPageRoute(
      builder: (context) => AzkarDetailsScreen(category: category),
    );
  }

  if (routeName == '/prayer-times') {
    _logger.i('Navigating to PrayerTimesScreen');
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => PrayerTimesCubit(
          PrayerTimesRepositoryImpl(),
        ),
        child: const PrayerTimesScreen(),
      ),
    );
  }

  if (routeName == '/qibla') {
    _logger.i('Navigating to QuplaScreen');
    return MaterialPageRoute(
      builder: (context) => const QuplaScreen(),
    );
  }
  
  if (routeName == '/masabha') {
    _logger.i('Navigating to MasbahaScreen');
    return MaterialPageRoute(
      builder: (context) => const MasbahaScreen(),
    );
  }
  
  if (routeName == '/quran') {
    _logger.i('Navigating to QuranOptimizedScreen');
    return MaterialPageRoute(
      builder: (context) => const QuranOptimizedScreen(),
    );
  }

  if (routeName == '/asma-allah') {
    _logger.i('Navigating to AsmaAllahScreen');
    try {
      return MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => AsmaAllahCubit(
            AllahNamesRepositoryImpl(),
          ),
          child: const AsmaAllahScreen(),
        ),
      );
    } catch (e, stackTrace) {
      _logger.e('Error creating AsmaAllahScreen route', error: e, stackTrace: stackTrace);
      return MaterialPageRoute(builder: (context) => const HomeView());
    }
  }

  if (routeName == '/hadith') {
    _logger.i('Navigating to HadithSectionsScreen');
    try {
      return MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => HadithCubit(
            HadithRepositoryImpl(),
          ),
          child: const HadithSectionsScreen(),
        ),
      );
    } catch (e, stackTrace) {
      _logger.e('Error creating HadithSectionsScreen route', error: e, stackTrace: stackTrace);
      return MaterialPageRoute(builder: (context) => const HomeView());
    }
  }

  if (routeName == '/tafsir' || routeName == TafsirSurahListScreen.routeName) {
    _logger.i('Navigating to TafsirSurahListScreen');
    try {
      return MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => TafsirCubit(
            TafsirRepositoryImpl(),
          ),
          child: const TafsirSurahListScreen(),
        ),
      );
    } catch (e, stackTrace) {
      _logger.e('Error creating TafsirSurahListScreen route', error: e, stackTrace: stackTrace);
      return MaterialPageRoute(builder: (context) => const HomeView());
    }
  }

  // Ruta por defecto
  _logger.w('Route not found: ${settings.name}');
  return MaterialPageRoute(
    builder: (context) => const HomeView(),
  );
}
