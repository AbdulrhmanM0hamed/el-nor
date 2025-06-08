import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/services/permissions_manager.dart';
import 'auth_state.dart';

class GlobalAuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final SessionService _sessionService;
  final PermissionsManager _permissionsManager;
  static GlobalAuthCubit? _instance;

  GlobalAuthCubit._({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository,
       _sessionService = SessionService(),
       _permissionsManager = PermissionsManager(),
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
        
        // Validate session and permissions
        final isValid = await _permissionsManager.validatePermissions(user.id);
        if (!isValid) {
          print('GlobalAuthCubit: الجلسة غير صالحة، إعادة تعيين الصلاحيات');
          await _permissionsManager.setPermissions(user.id, user.role);
        }
        
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
      
      // Set up session and permissions
      await _permissionsManager.setPermissions(user.id, user.role);
      
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

      // Clear permissions and session first
      await _permissionsManager.clearPermissions();
      print('GlobalAuthCubit: تم مسح الصلاحيات والجلسة');
      
      // Then clear user data and sign out
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
      
      // Update permissions if role changed
      if (currentUser?.role != updatedUser.role) {
        await _permissionsManager.setPermissions(updatedUser.id, updatedUser.role);
      }
      
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