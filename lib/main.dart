import 'package:beat_elslam/core/utils/theme/app_theme.dart';
import 'package:beat_elslam/features/auth/presentation/screens/auth_check_screen.dart';
import 'package:beat_elslam/core/services/service_locator.dart' as di;
import 'package:beat_elslam/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/cubit/global_auth_cubit.dart';
import 'core/helper/on_genrated_routes.dart';
import 'core/services/notification_service.dart';

import 'features/home/quran/data/models/surah_model.dart';
import 'features/home/asma_allah/models/allah_name_model.dart';

// معالج الرسائل في الخلفية
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('تم استلام رسالة في الخلفية: ${message.messageId}');
}

Future<void> _initializeApp() async {
  // Initialize Firebase first since it's critical
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

  // Initialize service locator
    await di.init();
    
  // Initialize GlobalAuthCubit
    await GlobalAuthCubit.initialize(authRepository: di.sl());

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize notifications in parallel with other operations
  NotificationService().initNotifications();

  // Initialize timezone data for scheduling notifications
  tz.initializeTimeZones();
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

  // Start preloading data in parallel
    SurahList.preInitialize();
    AllahNamesList.preInitialize();
}

void main() async {  
  try {
    // Ensure Flutter bindings are initialized first
    WidgetsFlutterBinding.ensureInitialized();
    
    // Wait for critical initializations to complete
    await _initializeApp();

    // Run the app after critical initializations
    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error in main: $e');
    runApp(const ErrorApp(error: 'Failed to initialize app'));
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'خطأ في تهيئة التطبيق\n$error',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
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
