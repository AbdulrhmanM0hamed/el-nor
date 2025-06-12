import 'package:beat_elslam/features/admin/data/repositories/admin_repository.dart';
import 'package:beat_elslam/features/quran_circles/data/datasources/circle_details_remote_datasource.dart';
import 'package:beat_elslam/features/quran_circles/data/repositories/circle_details_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/reset_password/reset_password_cubit.dart';
import '../../features/admin/presentation/cubit/admin_cubit.dart';
import '../../features/home/quran/presentation/cubit/quran_cubit.dart';
import '../../features/quran_circles/presentation/cubit/memorization_circles_cubit.dart';
import '../config/supabase_config.dart';
import '../../features/quran_circles/data/repositories/memorization_circles_repository.dart';
import 'session_service.dart';
import 'permissions_manager.dart';
import '../../features/quran_circles/presentation/cubit/circle_details_cubit.dart';
import '../../features/quran_circles/data/models/memorization_circle_model.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialize Supabase first since it's critical
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Register services and repositories lazily
  _registerServices();
  _registerRepositories();
}

void _registerServices() {
  // Register the Supabase client
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Register core services
  sl.registerLazySingleton(() => SessionService());
  sl.registerLazySingleton(() => PermissionsManager());
}

void _registerRepositories() {
  // Register repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<CircleDetailsRemoteDataSource>(
    () => CircleDetailsRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<CircleDetailsRepository>(
    () => CircleDetailsRepositoryImpl(
        remoteDataSource: sl<CircleDetailsRemoteDataSource>()),
  );

  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepository(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<MemorizationCirclesRepository>(
    () => MemorizationCirclesRepository(sl<SupabaseClient>()),
  );

  // Cubits
  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(authRepository: sl<AuthRepository>()),
  );

  // Register ResetPasswordCubit
  sl.registerFactory<ResetPasswordCubit>(
    () => ResetPasswordCubit(authRepository: sl<AuthRepository>()),
  );

  // Cubits adicionales para la aplicación
  sl.registerFactory<QuranCubit>(
    () => QuranCubit(),
  );

  // Registrar MemorizationCirclesCubit
  sl.registerFactory<MemorizationCirclesCubit>(
    () => MemorizationCirclesCubit(sl<MemorizationCirclesRepository>()),
  );

  // Registrar AdminCubit para la gestión de usuarios y círculos
  sl.registerFactory<AdminCubit>(
    () => AdminCubit(sl<AdminRepository>()),
  );

  // Circle Details
  sl.registerFactoryParam<CircleDetailsCubit, MemorizationCircle,
      Map<String, dynamic>>(
    (circle, params) => CircleDetailsCubit(
      repository: sl(),
      initialCircle: circle,
      userId: params['userId'] as String,
      userRole: params['userRole'],
    ),
  );
}
