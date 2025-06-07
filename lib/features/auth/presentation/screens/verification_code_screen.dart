import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../cubit/reset_password/reset_password_cubit.dart';
import '../cubit/reset_password/reset_password_state.dart';
import '../widgets/auth_background.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_overlay.dart';
import 'new_password_screen.dart';

class VerificationCodeScreen extends StatelessWidget {
  static const String routeName = '/verification-code';
  final String email;

  const VerificationCodeScreen({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _VerificationCodeScreenContent(email: email);
  }
}

class _VerificationCodeScreenContent extends StatefulWidget {
  final String email;

  const _VerificationCodeScreenContent({Key? key, required this.email}) : super(key: key);

  @override
  State<_VerificationCodeScreenContent> createState() => _VerificationCodeScreenContentState();
}

class _VerificationCodeScreenContentState extends State<_VerificationCodeScreenContent> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    if (mounted) {
      context.read<ResetPasswordCubit>().close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ResetPasswordCubit, ResetPasswordState>(
      listener: (context, state) {
        if (state is CodeVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(
            context,
            NewPasswordScreen.routeName,
            arguments: widget.email,
          );
        } else if (state is ResetPasswordError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التحقق من البريد الإلكتروني'),
          centerTitle: true,
        ),
        body: LoadingOverlay(
          isLoading: context.watch<ResetPasswordCubit>().state is ResetPasswordLoading,
          child: AuthBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Column(
                  children: [
                    SizedBox(height: 40.h),
                    Text(
                      'أدخل كود التحقق',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'تم إرسال كود التحقق إلى ${widget.email}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: _codeController,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(8),
                          fieldHeight: 50,
                          fieldWidth: 40,
                          activeFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                          selectedFillColor: Colors.white,
                          activeColor: Theme.of(context).primaryColor,
                          inactiveColor: Colors.grey[300],
                          selectedColor: Theme.of(context).primaryColor,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        enableActiveFill: true,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    CustomButton(
                      text: 'تحقق',
                      onPressed: () {
                        if (_codeController.text.length == 6) {
                          if (mounted) {
                            context
                                .read<ResetPasswordCubit>()
                                .verifyCode(_codeController.text);
                          }
                        }
                      },
                      icon: Icons.check_circle,
                    ),
                    SizedBox(height: 16.h),
                    TextButton(
                      onPressed: () {
                        context
                            .read<ResetPasswordCubit>()
                            .sendResetCode(widget.email);
                      },
                      child: Text(
                        'إعادة إرسال الكود',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 