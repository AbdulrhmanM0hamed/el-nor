import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../cubit/global_auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_background.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_overlay.dart';
import 'register_screen.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';
  
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: GlobalAuthCubit.instance,
      child: const _LoginScreenContent(),
    );
  }
}

class _LoginScreenContent extends StatefulWidget {
  const _LoginScreenContent({Key? key}) : super(key: key);

  @override
  State<_LoginScreenContent> createState() => _LoginScreenContentState();
}

class _LoginScreenContentState extends State<_LoginScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<GlobalAuthCubit>().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GlobalAuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is AuthAuthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: LoadingOverlay(
            isLoading: state is AuthLoading,
            child: AuthBackground(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 60.h),
                      _buildHeader(),
                      SizedBox(height: 40.h),
                      _buildLoginForm(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: Text(
            'النور',
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.logoTeal,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Center(
          child: Text(
            'تسجيل الدخول',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.logoOrange,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            label: 'البريد الإلكتروني',
            hint: 'أدخل بريدك الإلكتروني',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.logoTeal,
            ),
            validator: _validateEmail,
          ),
          SizedBox(height: 20.h),
          CustomTextField(
            label: 'كلمة المرور',
            hint: 'أدخل كلمة المرور',
            controller: _passwordController,
            obscureText: _obscurePassword,
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.logoTeal,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey,
              ),
              onPressed: _togglePasswordVisibility,
            ),
            validator: _validatePassword,
          ),
          SizedBox(height: 16.h),
          _buildForgotPasswordButton(),
          SizedBox(height: 32.h),
          CustomButton(
            text: 'تسجيل الدخول',
            onPressed: _login,
            icon: Icons.login,
          ),
          SizedBox(height: 20.h),
          _buildRegisterLink(),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            ResetPasswordScreen.routeName,
          );
        },
        child: Text(
          'نسيت كلمة المرور؟',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.logoTeal,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ليس لديك حساب؟',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black54,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              RegisterScreen.routeName,
            );
          },
          child: Text(
            'إنشاء حساب جديد',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.logoOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'الرجاء إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }
}
