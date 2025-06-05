import 'package:beat_elslam/core/utils/theme/app_theme.dart';
import 'package:beat_elslam/features/auth/presentation/cubit/auth_state.dart';
import 'package:beat_elslam/features/auth/presentation/screens/auth_check_screen.dart';
import 'package:beat_elslam/core/services/service_locator.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/cubit/global_auth_cubit.dart';
import 'core/helper/on_genrated_routes.dart';

import 'features/home/quran/data/models/surah_model.dart';
import 'features/home/asma_allah/models/allah_name_model.dart';

void main() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize timezone data for scheduling notifications
    tz.initializeTimeZones();

    // Initialize service locator (incluye inicialización de Supabase)
    await di.init();
    
    // تهيئة GlobalAuthCubit
    await GlobalAuthCubit.initialize(authRepository: di.sl());
    
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: GlobalAuthCubit.instance,
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'النور',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            supportedLocales: const [Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            onGenerateRoute: onGenratedRoutes,
            initialRoute: AuthCheckScreen.routeName,
          );
        },
      ),
    );
  }
}
