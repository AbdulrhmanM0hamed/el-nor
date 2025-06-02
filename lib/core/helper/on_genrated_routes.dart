import 'package:beat_elslam/features/asma_allah/presentation/screens/asma_allah_screen.dart';
import 'package:beat_elslam/features/home/view/home_View.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../features/azkar/presentation/screens/azkar_screen.dart';
import '../../features/azkar/presentation/screens/azkar_details_screen.dart';
import '../../features/azkar/models/azkar_model.dart';
import '../../features/prayer_times/presentation/screens/prayer_times_screen.dart';
import '../../features/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import '../../features/prayer_times/data/repositories/prayer_times_repository.dart';
import '../../features/qupla/presentation/screens/qupla_screen.dart';
import '../../features/masbaha/presentation/screens/masbaha_screen.dart';
import '../../features/quran/presentation/screens/quran_optimized_screen.dart';
import '../../features/asma_allah/data/repositories/allah_names_repository.dart';
import '../../features/asma_allah/presentation/cubit/asma_allah_cubit.dart';
import '../../features/hadith/presentation/screens/hadith_sections_screen.dart';
import '../../features/hadith/data/repositories/hadith_repository.dart';
import '../../features/hadith/presentation/cubit/hadith_cubit.dart';
import '../../features/tafsir/presentation/screens/tafsir_surah_list_screen.dart';
import '../../features/tafsir/data/repositories/tafsir_repository.dart';
import '../../features/tafsir/presentation/cubit/tafsir_cubit.dart';

final _logger = Logger();

Route<dynamic> onGenratedRoutes(RouteSettings settings) {
  _logger.i('Navigating to: ${settings.name}');
  
  switch (settings.name) {
    case HomeView.routeName:
      _logger.i('Navigating to HomeView');
      return MaterialPageRoute(builder: (context) => const HomeView());

    case '/azkar':
    case '/athkar':
      _logger.i('Navigating to AzkarScreen');
      return MaterialPageRoute(builder: (context) => const AzkarScreen());

    case '/azkar-details':
      final category = settings.arguments as AzkarCategory;
      _logger.i('Navigating to AzkarDetailsScreen with category: ${category.name}');
      return MaterialPageRoute(
        builder: (context) => AzkarDetailsScreen(category: category),
      );

    case '/prayer-times':
      _logger.i('Navigating to PrayerTimesScreen');
      return MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => PrayerTimesCubit(
            PrayerTimesRepositoryImpl(),
          ),
          child: const PrayerTimesScreen(),
        ),
      );

    case '/qibla':
    case '/qupla':
    case QuplaScreen.routeName:
      _logger.i('Navigating to QuplaScreen');
      return MaterialPageRoute(
        builder: (context) => const QuplaScreen(),
      );
      
    case '/masabha':
      _logger.i('Navigating to MasbahaScreen');
      return MaterialPageRoute(
        builder: (context) => const MasbahaScreen(),
      );
      
    case '/quran':
    case QuranOptimizedScreen.routeName:
      _logger.i('Navigating to QuranOptimizedScreen');
      return MaterialPageRoute(
        builder: (context) => const QuranOptimizedScreen(),
      );

    case '/asma-allah':
    case AsmaAllahScreen.routeName:
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

    case '/hadith':
    case HadithSectionsScreen.routeName:
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

    case '/tafsir':
    case TafsirSurahListScreen.routeName:
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

    default:
      _logger.w('Route not found: ${settings.name}, defaulting to HomeView');
      return MaterialPageRoute(builder: (context) => const HomeView());
  }
}
