import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_background.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/profile_image_picker.dart';

class RegisterScreen extends StatelessWidget {
  static const String routeName = '/register';

  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _RegisterScreenContent();
  }
}

class _RegisterScreenContent extends StatefulWidget {
  const _RegisterScreenContent({Key? key}) : super(key: key);

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

      context.read<AuthCubit>().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        age: age,
        profileImage: _profileImage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Navigator.pushReplacementNamed(context, '/main');
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: LoadingOverlay(
            isLoading: state is AuthLoading,
            child: AuthBackground(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBackButton(),
                      SizedBox(height: 20.h),
                      _buildHeader(),
                      SizedBox(height: 30.h),
                      _buildProfileImage(),
                      SizedBox(height: 24.h),
                      _buildRegistrationForm(),
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

  Widget _buildBackButton() {
    return IconButton(
      onPressed: () => Navigator.pop(context),
      icon: Icon(
        Icons.arrow_back_ios,
        color: AppColors.logoTeal,
        size: 24.sp,
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Text(
        'إنشاء حساب جديد',
        style: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.logoTeal,
        ),
      ),
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

  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'الاسم',
            hint: 'أدخل اسمك الكامل',
            controller: _nameController,
            icon: Icons.person_outline,
            validator: _validateName,
          ),
          _buildTextField(
            label: 'البريد الإلكتروني',
            hint: 'أدخل بريدك الإلكتروني',
            controller: _emailController,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          _buildTextField(
            label: 'رقم الهاتف',
            hint: 'أدخل رقم هاتفك',
            controller: _phoneController,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: _validatePhone,
          ),
          _buildTextField(
            label: 'العمر',
            hint: 'أدخل عمرك',
            controller: _ageController,
            icon: Icons.calendar_today_outlined,
            keyboardType: TextInputType.number,
            validator: _validateAge,
          ),
          _buildPasswordField(
            label: 'كلمة المرور',
            hint: 'أدخل كلمة المرور',
            controller: _passwordController,
            obscureText: _obscurePassword,
            toggleVisibility: _togglePasswordVisibility,
            validator: _validatePassword,
          ),
          _buildPasswordField(
            label: 'تأكيد كلمة المرور',
            hint: 'أعد إدخال كلمة المرور',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            toggleVisibility: _toggleConfirmPasswordVisibility,
            validator: _validateConfirmPassword,
          ),
          SizedBox(height: 32.h),
          CustomButton(
            text: 'إنشاء حساب',
            onPressed: _register,
            icon: Icons.person_add,
          ),
          SizedBox(height: 20.h),
          _buildLoginLink(),
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
      padding: EdgeInsets.only(bottom: 16.h),
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
      padding: EdgeInsets.only(bottom: 16.h),
      child: CustomTextField(
        label: label,
        hint: hint,
        controller: controller,
        obscureText: obscureText,
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.logoTeal),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.grey,
          ),
          onPressed: toggleVisibility,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'لديك حساب بالفعل؟',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black54,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'تسجيل الدخول',
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

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال الاسم';
    }
    return null;
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

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال العمر';
    }
    if (int.tryParse(value) == null) {
      return 'الرجاء إدخال رقم صحيح';
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء تأكيد كلمة المرور';
    }
    if (value != _passwordController.text) {
      return 'كلمات المرور غير متطابقة';
    }
    return null;
  }
}
