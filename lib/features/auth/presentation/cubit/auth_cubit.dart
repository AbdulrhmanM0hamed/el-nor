import 'dart:io';
import 'package:beat_elslam/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(AuthInitial());

  UserModel? get currentUser => state is AuthAuthenticated 
      ? (state as AuthAuthenticated).user 
      : null;

  Future<void> checkAuthState() async {
    print('AuthCubit: بدء التحقق من حالة المصادقة');
    if (isClosed) {
      print('AuthCubit: تم إغلاق الـ Cubit بالفعل، لا يمكن إصدار حالات جديدة');
      return;
    }
    
    emit(const AuthLoading());
    
    try {
      final user = await _authRepository.getCurrentUser();
      
      if (isClosed) {
        print('AuthCubit: تم إغلاق الـ Cubit بعد التحقق، لا يمكن إصدار حالات جديدة');
        return;
      }
      
      if (user != null) {
        print('AuthCubit: تم العثور على مستخدم مسجل');
        emit(AuthAuthenticated(user));
      } else {
        print('AuthCubit: لا يوجد مستخدم مسجل');
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      print('AuthCubit: حدث خطأ أثناء التحقق من حالة المصادقة: $e');
      if (!isClosed) {
        emit(AuthError(e.toString()));
      }
    }
  }

  Future<void> checkCurrentUser() async {
    print('AuthCubit: بدء التحقق من المستخدم الحالي');
    if (isClosed) {
      print('AuthCubit: تم إغلاق الـ Cubit بالفعل، لا يمكن إصدار حالات جديدة');
      return;
    }
    emit(const AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (isClosed) {
        print('AuthCubit: تم إغلاق الـ Cubit بعد الحصول على المستخدم، لا يمكن إصدار حالات جديدة');
        return;
      }
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      if (!isClosed) {
        print('AuthCubit: حدث خطأ: ${e.toString()}');
        emit(AuthError(e.toString()));
      } else {
        print('AuthCubit: تم إغلاق الـ Cubit بعد حدوث خطأ، لا يمكن إصدار حالة الخطأ');
      }
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required int age,
    File? profileImage,
  }) async {
    if (isClosed) {
      print('AuthCubit: تم إغلاق الـ Cubit بالفعل، لا يمكن إصدار حالات جديدة');
      return;
    }
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
        age: age,
        profileImage: profileImage,
      );
      if (isClosed) {
        print('AuthCubit: تم إغلاق الـ Cubit بعد إنشاء الحساب، لا يمكن إصدار حالات جديدة');
        return;
      }
      // إصدار حالة واحدة فقط بعد إنشاء الحساب بنجاح
      emit(AuthAuthenticated(user));
    } catch (e) {
      if (!isClosed) {
        print('AuthCubit: حدث خطأ أثناء إنشاء الحساب: ${e.toString()}');
        emit(AuthError(e.toString()));
      } else {
        print('AuthCubit: تم إغلاق الـ Cubit بعد حدوث خطأ، لا يمكن إصدار حالة الخطأ');
      }
    }
  }

  Future<void> signOut() async {
    if (isClosed) {
      print('AuthCubit: تم إغلاق الـ Cubit بالفعل، لا يمكن إصدار حالات جديدة');
      return;
    }
    
    print('AuthCubit: بدء عملية تسجيل الخروج');
    emit(const AuthLoading());
    
    try {
      // مسح بيانات المستخدم أولاً
      await _authRepository.clearUserData();
      print('AuthCubit: تم مسح بيانات المستخدم');
      
      // ثم تسجيل الخروج
      await _authRepository.signOut();
      
      if (!isClosed) {
        print('AuthCubit: تم تسجيل الخروج بنجاح');
        emit(const AuthUnauthenticated());
      } else {
        print('AuthCubit: تم إغلاق الـ Cubit بعد تسجيل الخروج، لا يمكن إصدار حالات جديدة');
      }
    } catch (e) {
      print('AuthCubit: حدث خطأ أثناء تسجيل الخروج: $e');
      if (!isClosed) {
        emit(AuthError(e.toString()));
      }
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    if (isClosed) {
      print('AuthCubit: تم إغلاق الـ Cubit بالفعل، لا يمكن إصدار حالات جديدة');
      return;
    }
    
    print('AuthCubit: بدء عملية تسجيل الدخول');
    emit(const AuthLoading());
    
    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );
      
      if (!isClosed) {
        print('AuthCubit: تم تسجيل الدخول بنجاح');
        emit(AuthAuthenticated(user));
      } else {
        print('AuthCubit: تم إغلاق الـ Cubit بعد تسجيل الدخول، لا يمكن إصدار حالات جديدة');
      }
    } catch (e) {
      print('AuthCubit: حدث خطأ أثناء تسجيل الدخول: $e');
      if (!isClosed) {
        emit(AuthError(e.toString()));
      }
    }
  }

  Future<void> resetPassword(String email) async {
    if (isClosed) {
      print('AuthCubit: تم إغلاق الـ Cubit بالفعل، لا يمكن إصدار حالات جديدة');
      return;
    }
    emit(const AuthLoading());
    try {
      await _authRepository.resetPassword(email);
      if (isClosed) {
        print('AuthCubit: تم إغلاق الـ Cubit بعد إعادة تعيين كلمة المرور، لا يمكن إصدار حالات جديدة');
        return;
      }
      emit(const AuthResetPasswordSuccess());
    } catch (e) {
      if (!isClosed) {
        print('AuthCubit: حدث خطأ أثناء إعادة تعيين كلمة المرور: ${e.toString()}');
        emit(AuthError(e.toString()));
      } else {
        print('AuthCubit: تم إغلاق الـ Cubit بعد حدوث خطأ، لا يمكن إصدار حالة الخطأ');
      }
    }
  }

  @override
  Future<void> close() async {
    print('AuthCubit: إغلاق الـ Cubit');
    return super.close();
  }
}
