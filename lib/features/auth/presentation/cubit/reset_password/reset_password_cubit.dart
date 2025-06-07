import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthRepository _authRepository;
  String? _email;
  
  ResetPasswordCubit({
    required AuthRepository authRepository,
    String? email,
  }) : 
    _authRepository = authRepository,
    _email = email,
    super(const ResetPasswordInitial());

  Future<void> sendResetCode(String email) async {
    emit(const ResetPasswordLoading());
    try {
      // التحقق من وجود البريد
      final exists = await _authRepository.isEmailRegistered(email);
      if (!exists) {
        emit(const ResetPasswordError('البريد الإلكتروني غير مسجل'));
        return;
      }

      _email = email;
      await _authRepository.sendResetCode(email);
      emit(const ResetCodeSent('تم إرسال كود التحقق بنجاح'));
    } catch (e) {
      emit(ResetPasswordError(e.toString()));
    }
  }

  Future<void> verifyCode(String code) async {
    if (_email == null) {
      emit(const ResetPasswordError('حدث خطأ، يرجى المحاولة مرة أخرى'));
      return;
    }

    emit(const ResetPasswordLoading());
    try {
      await _authRepository.verifyResetCode(_email!, code);
      emit(const CodeVerified('تم التحقق من الكود بنجاح'));
    } catch (e) {
      emit(ResetPasswordError(e.toString()));
    }
  }

  Future<void> resetPassword(String newPassword) async {
    if (_email == null) {
      emit(const ResetPasswordError('حدث خطأ، يرجى المحاولة مرة أخرى'));
      return;
    }

    emit(const ResetPasswordLoading());
    try {
      await _authRepository.resetPasswordWithCode(_email!, newPassword);
      emit(const PasswordResetSuccess('تم تغيير كلمة المرور بنجاح'));
    } catch (e) {
      emit(ResetPasswordError(e.toString()));
    }
  }
} 