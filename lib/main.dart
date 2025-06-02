import 'package:beat_elslam/core/utils/theme/app_theme.dart';
import 'package:beat_elslam/features/home/view/home_View.dart';
import 'package:beat_elslam/features/prayer_times/services/prayer_reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/helper/on_genrated_routes.dart';
import 'features/prayer_times/data/repositories/prayer_times_repository.dart';
import 'features/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import 'features/quran/data/models/surah_model.dart';
import 'features/asma_allah/models/allah_name_model.dart';

void main() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize timezone data for scheduling notifications
    tz.initializeTimeZones();

    

    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Start preloading Quran data in the background
    SurahList.preInitialize();
    
    // Start preloading Allah Names data in the background
    AllahNamesList.preInitialize();

    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error in main: $e');
    // Run the app anyway to avoid blank screen
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard iPhone X size as a baseline
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<PrayerTimesCubit>(
              create: (context) => PrayerTimesCubit(PrayerTimesRepositoryImpl()),
            ),
          ],
          child: MaterialApp(
            useInheritedMediaQuery: true,
            debugShowCheckedModeBanner: false,
            title: 'بيت الاسلام',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            //  themeMode: themeMode,
            supportedLocales: const [Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            onGenerateRoute: onGenratedRoutes,
            home: const HomeView(),
          ),
        );
      },
    );
  }
}
