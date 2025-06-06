import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/cubit/global_auth_cubit.dart';
import '../../../admin/presentation/screens/circle_management_screen.dart';
import '../../../admin/presentation/screens/user_management_screen.dart';

class ProfileActionsWidget extends StatelessWidget {
  final UserModel user;

  const ProfileActionsWidget({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.isAdmin) ...[
            _buildSectionTitle('إدارة النظام'),
            _buildActionButton(
              'إدارة المستخدمين',
              Icons.people,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserManagementScreenWrapper(),
                ),
              ),
              color: AppColors.logoTeal,
            ),
            SizedBox(height: 12.h),
            _buildActionButton(
              'إدارة حلقات التحفيظ',
              Icons.group_add,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CircleManagementScreenWrapper(),
                ),
              ),
              color: Colors.amber,
            ),
            SizedBox(height: 12.h),
            _buildActionButton(
              'تعيين معلمين للحلقات',
              Icons.assignment_ind,
              () {},
              color: AppColors.logoOrange,
            ),
            SizedBox(height: 24.h),
          ],

      

          _buildSectionTitle('إعدادات الحساب'),
          _buildActionButton(
            'تعديل الملف الشخصي',
            Icons.edit,
            () {},
          ),
          SizedBox(height: 12.h),
          _buildActionButton(
            'تغيير كلمة المرور',
            Icons.lock,
            () {},
          ),
          SizedBox(height: 12.h),
          _buildActionButton(
            'تسجيل الخروج',
            Icons.logout,
            () => _showLogoutConfirmationDialog(context),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.logoTeal,
          ),
        ),
        Divider(height: 16.h),
      ],
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
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GlobalAuthCubit>().signOut();
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