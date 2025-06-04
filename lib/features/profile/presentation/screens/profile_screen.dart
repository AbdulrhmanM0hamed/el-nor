import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../admin/presentation/screens/circle_management_screen.dart';
import '../../../admin/presentation/screens/user_management_screen.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/cubit/global_auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart' show AuthAuthenticated, AuthError, AuthLoading, AuthState, AuthUnauthenticated;
import '../../../auth/presentation/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    print('ProfileScreen: تهيئة الشاشة');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    print('ProfileScreen: بدء تحميل بيانات المستخدم');
    if (!mounted) return;

    try {
      // التحقق من وجود مستخدم حالي في الـ GlobalAuthCubit
      final currentUser = GlobalAuthCubit.instance.currentUser;
      if (currentUser != null) {
        print('ProfileScreen: تم العثور على بيانات المستخدم');
        setState(() {
          _user = currentUser;
        });
      } else {
        print('ProfileScreen: لا يوجد مستخدم حالي، جاري التحقق من حالة المصادقة');
        await GlobalAuthCubit.instance.checkAuthState();
      }
    } catch (e) {
      print('ProfileScreen: خطأ في تحميل بيانات المستخدم: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('ProfileScreen: بناء الواجهة');
    return BlocConsumer<GlobalAuthCubit, AuthState>(
      bloc: GlobalAuthCubit.instance,
      listener: (context, state) {
        print('ProfileScreen: تغيير في حالة المصادقة - ${state.runtimeType}');
        if (state is AuthAuthenticated) {
          print('ProfileScreen: تم استلام بيانات المستخدم المصادق عليه');
          setState(() {
            _user = state.user;
          });
        } else if (state is AuthUnauthenticated) {
          print('ProfileScreen: المستخدم غير مصرح له، التوجيه إلى شاشة تسجيل الدخول');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        print('ProfileScreen: حالة المصادقة الحالية - ${state.runtimeType}');
        
        // إذا كان لدينا بيانات المستخدم، نعرضها حتى لو كانت الحالة loading
        if (_user != null) {
          return Scaffold(
            body: _buildProfileContent(),
          );
        }
        
        // إذا كانت الحالة loading ولا يوجد بيانات مستخدم، نعرض مؤشر التحميل
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.logoTeal,
              ),
            ),
          );
        }
        
        if (state is AuthError) {
          return Scaffold(
            body: Center(
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
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: _loadUserData,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        // في حالة عدم وجود بيانات مستخدم ولا حالة loading، نحاول تحميل البيانات
        _loadUserData();
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: AppColors.logoTeal,
            ),
          ),
        );
      },
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
      height: 220.h, // زيادة الارتفاع قليلاً لإضافة شارة الدور
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
          Stack(
            alignment: Alignment.bottomRight,
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
              // شارة لدور المستخدم
              if (_user != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getUserRoleBadgeColor(),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    _getUserRoleText(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
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
  
  // دالة للحصول على نص دور المستخدم
  String _getUserRoleText() {
    if (_user?.isAdmin == true) {
      return 'مشرف'; // مشرف
    } else if (_user?.isTeacher == true) {
      return 'معلم'; // معلم
    } else {
      return 'طالب'; // طالب
    }
  }
  
  // دالة للحصول على لون شارة دور المستخدم
  Color _getUserRoleBadgeColor() {
    if (_user?.isAdmin == true) {
      return Colors.red; // لون للمشرف
    } else if (_user?.isTeacher == true) {
      return AppColors.logoOrange; // لون للمعلم
    } else {
      return Colors.green; // لون للطالب
    }
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
          _buildInfoRow(Icons.phone, 'رقم الهاتف', _user?.phoneNumber ?? 'غير متوفر'),
          SizedBox(height: 12.h),
          _buildInfoRow(
            _user?.isAdmin == true ? Icons.admin_panel_settings : 
            _user?.isTeacher == true ? Icons.school : Icons.person,
            'الدور',
            _getUserRoleText(),
            valueColor: _getUserRoleBadgeColor(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
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
            color: valueColor ?? Colors.black87,
            fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أزرار للمشرفين فقط
          if (_user?.isAdmin == true) ...[  
            Text(
              'إدارة النظام',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.logoTeal,
              ),
            ),
            Divider(height: 16.h),
            _buildActionButton(
              'إدارة المستخدمين',
              Icons.people,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserManagementScreenWrapper(),
                  ),
                );
              },
              color: AppColors.logoTeal,
            ),
            SizedBox(height: 12.h),
            _buildActionButton(
              'إدارة حلقات التحفيظ',
              Icons.group_add,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CircleManagementScreenWrapper(),
                  ),
                );
              },
              color: Colors.amber,
            ),
            SizedBox(height: 12.h),
            _buildActionButton(
              'تعيين معلمين للحلقات',
              Icons.assignment_ind,
              () {
                // فتح شاشة تعيين المعلمين
              },
              color: AppColors.logoOrange,
            ),
            SizedBox(height: 24.h),
          ],
          
          // أزرار للمعلمين فقط
          if (_user?.isTeacher == true && _user?.isAdmin != true) ...[  
            Text(
              'إدارة الحلقات',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.logoTeal,
              ),
            ),
            Divider(height: 16.h),
            SizedBox(height: 24.h),
          ],
          
          // أزرار لجميع المستخدمين
          Text(
            'إعدادات الحساب',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.logoTeal,
            ),
          ),
          Divider(height: 16.h),
          _buildActionButton(
            'تعديل الملف الشخصي',
            Icons.edit,
            () {
              // تنفيذ تعديل الملف الشخصي
            },
          ),
          SizedBox(height: 12.h),
          _buildActionButton(
            'تغيير كلمة المرور',
            Icons.lock,
            () {
              // تنفيذ تغيير كلمة المرور
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
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await GlobalAuthCubit.instance.signOut();
              } catch (e) {
                print('ProfileScreen: خطأ في تسجيل الخروج: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ في تسجيل الخروج: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
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
