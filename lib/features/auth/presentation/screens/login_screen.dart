import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../cubit/global_auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_background.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_overlay.dart';
import 'register_screen.dart';
import 'forget_password_screen.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: GlobalAuthCubit.instance,
      child: const _LoginScreenContent(),
    );
  }
}

class _LoginScreenContent extends StatefulWidget {
  const _LoginScreenContent();

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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'الرجاء إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/main', (route) => false);
        } else if (state is AuthGuest) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: LoadingOverlay(
            isLoading: state is AuthLoading,
            child: AuthBackground(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.1),
                      _buildHeader(),
                      SizedBox(height: screenHeight * 0.05),
                      _buildLoginForm(),
                      SizedBox(height: screenHeight * 0.05),
                      _buildRegisterLink(),
                      SizedBox(height: screenHeight * 0.1),
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
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Text(
          'ملتقى النّور القرآني',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screenWidth * 0.075,
            fontWeight: FontWeight.bold,
            color: AppColors.logoTeal,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Text(
          'تسجيل الدخول',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screenWidth * 0.065,
            fontWeight: FontWeight.bold,
            color: AppColors.logoOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            label: 'البريد الإلكتروني',
            hint: 'أدخل بريدك الإلكتروني',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.logoTeal),
            validator: _validateEmail,
          ),
          SizedBox(height: screenHeight * 0.025),
          CustomTextField(
            label: 'كلمة المرور',
            hint: 'أدخل كلمة المرور',
            controller: _passwordController,
            obscureText: _obscurePassword,
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.logoTeal),
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
          _buildForgotPasswordButton(),
          SizedBox(height: screenHeight * 0.01),
          CustomButton(
            text: 'تسجيل الدخول',
            onPressed: _login,
            widthFactor: 0.9,
            icon: Icons.login,
          ),
          SizedBox(height: screenHeight * 0.02),
          CustomButton(
            text: 'الدخول كزائر',
            onPressed: () {
              context.read<GlobalAuthCubit>().enterAsGuest();
            },
            widthFactor: 0.9,
            isOutlined: true,
            icon: Icons.person_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: TextButton(
        onPressed: () {
          Navigator.of(context).pushNamed(ForgetPasswordScreen.routeName);
        },
        child: Text(
          'نسيت كلمة المرور؟',
          style: TextStyle(
            color: AppColors.logoTeal,
            fontSize: MediaQuery.of(context).size.width * 0.035,
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
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(RegisterScreen.routeName);
          },
          child: Text(
            'أنشئ حساباً',
            style: TextStyle(
              color: AppColors.logoOrange,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.width * 0.04,
            ),
          ),
        ),
      ],
    );
  }
}
