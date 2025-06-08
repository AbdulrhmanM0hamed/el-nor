import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import 'auth_state.dart';

class GlobalAuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  static GlobalAuthCubit? _instance;

  GlobalAuthCubit._({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial());

  static GlobalAuthCubit get instance {
    if (_instance == null) {
      throw Exception('GlobalAuthCubit not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<void> initialize({required AuthRepository authRepository}) async {
    if (_instance == null) {
      _instance = GlobalAuthCubit._(authRepository: authRepository);
      await _instance!.checkAuthState();
    }
  }

  UserModel? get currentUser => state is AuthAuthenticated 
      ? (state as AuthAuthenticated).user 
      : null;

  bool get isGuest => state is AuthGuest;

  Future<void> checkAuthState() async {
    print('GlobalAuthCubit: بدء التحقق من حالة المصادقة');
    emit(const AuthLoading());
    
    try {
      final user = await _authRepository.getCurrentUser();
      
      if (user != null) {
        print('GlobalAuthCubit: تم العثور على مستخدم مسجل');
        emit(AuthAuthenticated(user));
      } else {
        print('GlobalAuthCubit: لا يوجد مستخدم مسجل');
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      print('GlobalAuthCubit: حدث خطأ أثناء التحقق من حالة المصادقة: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    print('GlobalAuthCubit: بدء عملية تسجيل الدخول');
    emit(const AuthLoading());
    
    try {
      final user = await _authRepository.signIn(
        email,
        password,
      );
      
      print('GlobalAuthCubit: تم تسجيل الدخول بنجاح');
      emit(AuthAuthenticated(user));
    } catch (e) {
      print('GlobalAuthCubit: حدث خطأ أثناء تسجيل الدخول: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    print('GlobalAuthCubit: بدء عملية تسجيل الخروج');
    emit(const AuthLoading());
    
    try {
      if (state is AuthGuest) {
        emit(const AuthUnauthenticated());
        return;
      }

      await _authRepository.clearUserData();
      print('GlobalAuthCubit: تم مسح بيانات المستخدم');
      
      await _authRepository.signOut();
      print('GlobalAuthCubit: تم تسجيل الخروج بنجاح');
      
      emit(const AuthUnauthenticated());
    } catch (e) {
      print('GlobalAuthCubit: حدث خطأ أثناء تسجيل الخروج: $e');
      emit(AuthError(e.toString()));
    }
  }

  void enterAsGuest() {
    emit(const AuthGuest());
  }

  Future<void> updateProfile({
    required UserModel user,
    File? profileImage,
  }) async {
    try {
      final updatedUser = await _authRepository.updateProfile(
        user: user,
        profileImage: profileImage,
      );
      emit(AuthAuthenticated(updatedUser));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      rethrow;
    }
  }
} 