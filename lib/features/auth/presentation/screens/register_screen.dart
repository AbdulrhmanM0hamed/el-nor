import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:noor_quran/core/widgets/custom_app_bar.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/input_validator.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../cubit/global_auth_cubit.dart';
import '../widgets/auth_background.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/profile_image_picker.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  static const String routeName = '/register';

  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RegisterScreenContent();
  }
}

class _RegisterScreenContent extends StatefulWidget {
  const _RegisterScreenContent();

  @override
  State<_RegisterScreenContent> createState() => _RegisterScreenContentState();
}

class _RegisterScreenContentState extends State<_RegisterScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  File? _profileImage;
  String _completePhoneNumber = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('كلمات المرور غير متطابقة'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      int? age = int.tryParse(_ageController.text);
      if (age == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الرجاء إدخال عمر صحيح'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final String phoneNumber =
          _completePhoneNumber.isNotEmpty ? _completePhoneNumber : _phoneController.text.trim();

      context.read<AuthCubit>().signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
            phone: phoneNumber,
            age: age,
            profileImage: _profileImage,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء الحساب بنجاح!'),
              backgroundColor: Colors.green,
            ),
          );
          try {
            GlobalAuthCubit.instance.checkAuthState();
          } catch (_) {}
          Navigator.pushReplacementNamed(context, '/main');
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: const CustomAppBar(
            title: 'إنشاء حساب جديد',
            fallbackRoute: LoginScreen.routeName,
          ),
          body: LoadingOverlay(
            isLoading: state is AuthLoading,
            child: AuthBackground(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.02),
                      _buildProfileImage(),
                      SizedBox(height: screenHeight * 0.03),
                      _buildRegistrationForm(context),
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

  Widget _buildProfileImage() {
    return Center(
      child: ProfileImagePicker(
        profileImage: _profileImage,
        onImagePicked: (file) => setState(() => _profileImage = file),
      ),
    );
  }

  Widget _buildRegistrationForm(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            label: 'الاسم',
            hint: 'أدخل اسمك الكامل',
            controller: _nameController,
            icon: Icons.person_outline,
            validator: InputValidator.name,
          ),
          _buildTextField(
            label: 'البريد الإلكتروني',
            hint: 'أدخل بريدك الإلكتروني',
            controller: _emailController,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: InputValidator.email,
          ),
          Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.02),
            child: IntlPhoneField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف',
                hintText: 'أدخل رقم هاتفك',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              initialCountryCode: 'EG',
              onChanged: (phone) {
                _completePhoneNumber = phone.completeNumber;
              },
              onSaved: (phone) {
                if (phone != null) _completePhoneNumber = phone.completeNumber;
              },
              validator: (value) => InputValidator.phone(value?.completeNumber),
            ),
          ),
          _buildTextField(
            label: 'العمر',
            hint: 'أدخل عمرك',
            controller: _ageController,
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
            validator: InputValidator.age,
          ),
          _buildPasswordField(
            label: 'كلمة المرور',
            hint: 'أدخل كلمة المرور',
            controller: _passwordController,
            obscureText: _obscurePassword,
            toggleVisibility: _togglePasswordVisibility,
            validator: InputValidator.password,
          ),
          _buildPasswordField(
            label: 'تأكيد كلمة المرور',
            hint: 'أعد إدخال كلمة المرور',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            toggleVisibility: _toggleConfirmPasswordVisibility,
            validator: (v) => InputValidator.confirmPassword(v, _passwordController.text),
          ),
          SizedBox(height: screenHeight * 0.02),
          CustomButton(
            text: 'إنشاء حساب',
            onPressed: _register,
            icon: Icons.person_add,
          ),
          SizedBox(height: screenHeight * 0.01),
          _buildLoginLink(context),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02),
      child: CustomTextField(
        label: label,
        hint: hint,
        controller: controller,
        keyboardType: keyboardType,
        prefixIcon: Icon(icon, color: AppColors.logoTeal),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02),
      child: CustomTextField(
        label: label,
        hint: hint,
        controller: controller,
        obscureText: obscureText,
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.logoTeal),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey,
          ),
          onPressed: toggleVisibility,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'لديك حساب بالفعل؟',
          style: TextStyle(fontSize: screenWidth * 0.04),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
          },
          child: Text(
            'تسجيل الدخول',
            style: TextStyle(
              color: AppColors.logoOrange,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.04,
            ),
          ),
        ),
      ],
    );
  }
}
