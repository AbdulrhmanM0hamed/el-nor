import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../auth/presentation/cubit/global_auth_cubit.dart';

part 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final GlobalAuthCubit _authCubit;

  ChangePasswordCubit(this._authCubit) : super(const ChangePasswordInitial());

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword == newPassword) {
      emit(const ChangePasswordError('كلمة المرور الجديدة يجب أن تكون مختلفة عن كلمة المرور الحالية'));
      return;
    }

    emit(const ChangePasswordLoading());

    try {
      print('ChangePasswordCubit: محاولة تغيير كلمة المرور');
      await _authCubit.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      print('ChangePasswordCubit: تم تغيير كلمة المرور بنجاح');
      
      emit(const ChangePasswordSuccess());
    } catch (e) {
      print('ChangePasswordCubit: حدث خطأ في تغيير كلمة المرور');
      print('ChangePasswordCubit: نوع الخطأ: ${e.runtimeType}');
      print('ChangePasswordCubit: رسالة الخطأ: $e');

      final errorString = e.toString().toLowerCase();
      String errorMessage;
      
      print('ChangePasswordCubit: تحليل رسالة الخطأ: $errorString');
      
      if (errorString.contains('invalid login credentials') || 
          errorString.contains('كلمة المرور الحالية غير صحيحة')) {
        errorMessage = 'كلمة المرور الحالية غير صحيحة';
      } else if (errorString.contains('password should be at least 6 characters')) {
        errorMessage = 'كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل';
      } else if (errorString.contains('token has expired')) {
        errorMessage = 'انتهت صلاحية الجلسة، الرجاء إعادة تسجيل الدخول';
      } else {
        errorMessage = 'حدث خطأ غير متوقع، الرجاء المحاولة مرة أخرى';
      }
      
      print('ChangePasswordCubit: الرسالة التي سيتم عرضها: $errorMessage');
      emit(ChangePasswordError(errorMessage));
    }
  }
} 