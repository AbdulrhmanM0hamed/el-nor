import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // No necesitamos hacer nada aquí, ya que el BlocProvider
    // se encargará de proporcionar el AuthCubit y el BlocConsumer
    // reaccionará a los cambios de estado
    
    // Simplemente establecemos el estado de carga
    setState(() {
      _isLoading = true;
    });
    
    // El estado se actualizará en el listener del BlocConsumer
    // cuando se reciba el estado AuthAuthenticated
  }

  @override
  Widget build(BuildContext context) {
    // Usamos directamente BlocConsumer ya que el AuthCubit es proporcionado por MainLayoutScreen
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          setState(() {
            _user = state.user;
            _isLoading = false;
          });
        } else if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, LoginScreen.routeName);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: _isLoading
              ? _buildLoadingState()
              : _user != null
                  ? _buildProfileContent()
                  : _buildErrorState(),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.logoTeal,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            'حدث خطأ في تحميل البيانات',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _loadUserData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.logoTeal,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header con imagen de perfil
          _buildProfileHeader(),
          
          // Información del usuario
          _buildUserInfo(),
          
          // Estadísticas
          _buildStatistics(),
          
          // Botones de acción
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.logoTeal, AppColors.logoTeal.withOpacity(0.7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50.r,
            backgroundColor: Colors.white,
            backgroundImage: _user?.profileImageUrl != null && _user!.profileImageUrl!.isNotEmpty
                ? NetworkImage(_user!.profileImageUrl!)
                : null,
            child: _user?.profileImageUrl == null || _user!.profileImageUrl!.isEmpty
                ? Icon(
                    Icons.person,
                    size: 50.sp,
                    color: AppColors.logoTeal,
                  )
                : null,
          ),
          SizedBox(height: 16.h),
          Text(
            _user?.name ?? 'مستخدم',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _user?.email ?? '',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الحساب',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.logoTeal,
            ),
          ),
          Divider(height: 24.h),
          _buildInfoRow(Icons.phone, 'رقم الهاتف', _user?.phone ?? 'غير متوفر'),
          SizedBox(height: 12.h),
          _buildInfoRow(Icons.cake, 'العمر', _user?.age != null ? '${_user!.age} سنة' : 'غير متوفر'),
          SizedBox(height: 12.h),
          _buildInfoRow(Icons.calendar_today, 'تاريخ الانضمام', _user?.createdAt != null 
              ? '${_user!.createdAt.day}/${_user!.createdAt.month}/${_user!.createdAt.year}'
              : 'غير متوفر'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: AppColors.logoOrange,
        ),
        SizedBox(width: 12.w),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('حلقات الحفظ', '0', Icons.groups),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: _buildStatCard('الاختبارات', '0', Icons.assignment),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: _buildStatCard('الإنجازات', '0', Icons.emoji_events),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32.sp,
            color: AppColors.logoTeal,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.logoOrange,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildActionButton(
            'تعديل الملف الشخصي',
            Icons.edit,
            () {
              // Implementar edición de perfil
            },
          ),
          SizedBox(height: 12.h),
          _buildActionButton(
            'تغيير كلمة المرور',
            Icons.lock,
            () {
              // Implementar cambio de contraseña
            },
          ),
          SizedBox(height: 12.h),
          _buildActionButton(
            'تسجيل الخروج',
            Icons.logout,
            () {
              _showLogoutConfirmationDialog(context);
            },
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: color ?? AppColors.logoTeal,
            ),
            SizedBox(width: 16.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: color ?? Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    // Capturamos el AuthCubit antes de mostrar el diálogo
    final authCubit = context.read<AuthCubit>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Usamos el authCubit capturado en lugar de intentar acceder a él desde el contexto del diálogo
              authCubit.signOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
