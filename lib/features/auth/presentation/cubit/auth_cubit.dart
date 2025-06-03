import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthInitial());

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

  Future<void> signIn({required String email, required String password}) async {
    if (isClosed) {
      print('AuthCubit: تم إغلاق الـ Cubit بالفعل، لا يمكن إصدار حالات جديدة');
      return;
    }
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );
      if (isClosed) {
        print('AuthCubit: تم إغلاق الـ Cubit بعد تسجيل الدخول، لا يمكن إصدار حالات جديدة');
        return;
      }
      // إصدار حالة واحدة فقط بعد تسجيل الدخول بنجاح
      emit(AuthAuthenticated(user));
    } catch (e) {
      if (!isClosed) {
        print('AuthCubit: حدث خطأ أثناء تسجيل الدخول: ${e.toString()}');
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
    emit(const AuthLoading());
    try {
      await _authRepository.signOut();
      if (isClosed) {
        print('AuthCubit: تم إغلاق الـ Cubit بعد تسجيل الخروج، لا يمكن إصدار حالات جديدة');
        return;
      }
      emit(const AuthUnauthenticated());
    } catch (e) {
      if (!isClosed) {
        print('AuthCubit: حدث خطأ أثناء تسجيل الخروج: ${e.toString()}');
        emit(AuthError(e.toString()));
      } else {
        print('AuthCubit: تم إغلاق الـ Cubit بعد حدوث خطأ، لا يمكن إصدار حالة الخطأ');
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
}
