import 'package:beat_elslam/features/admin/data/repositories/admin_repository.dart';
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

final sl = GetIt.instance;

Future<void> init() async {
  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Registrar el cliente de Supabase
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(supabaseClient: sl<SupabaseClient>()),
  );
  
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepository(sl<SupabaseClient>()),
  );

  // Registrar MemorizationCirclesRepository
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
    () => MemorizationCirclesCubit(repository: sl<MemorizationCirclesRepository>()),
  );
  
  // Registrar AdminCubit para la gestión de usuarios y círculos
  sl.registerFactory<AdminCubit>(
    () => AdminCubit(sl<AdminRepository>()),
  );
}
