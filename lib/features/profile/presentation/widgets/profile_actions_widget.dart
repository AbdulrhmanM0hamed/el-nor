import 'package:beat_elslam/features/admin/presentation/screens/user_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/cubit/global_auth_cubit.dart';
import '../../../admin/presentation/screens/circle_management_screen.dart';
import '../../../profile/presentation/screens/edit_profile_screen.dart';
import '../../../profile/presentation/screens/change_password_screen.dart';

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
            _buildSectionTitle(context, 'إدارة النظام'),
            _buildActionButton(
              context,
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
              context,
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
              context,
              'خطة التعلم',
              Icons.picture_as_pdf,
              () => Navigator.pushNamed(context, '/learning-plan', arguments: user),
              color: Colors.orange,
            ),
            SizedBox(height: 24.h),
          ],

          _buildSectionTitle(context, 'إعدادات الحساب'),
          _buildActionButton(
            context,
            'تعديل الملف الشخصي',
            Icons.edit,
            () => Navigator.pushNamed(
              context,
              EditProfileScreen.routeName,
              arguments: user,
            ),
          ),
          SizedBox(height: 12.h),
          _buildActionButton(
            context,
            'تغيير كلمة المرور',
            Icons.lock,
            () => Navigator.pushNamed(
              context,
              ChangePasswordScreen.routeName,
            ),
          ),
          SizedBox(height: 12.h),
          _buildActionButton(
            context,
            'خطة التعلم',
            Icons.picture_as_pdf,
            () => Navigator.pushNamed(context, '/learning-plan', arguments: user),
          ),
          SizedBox(height: 12.h),
          _buildActionButton(
            context,
            'تسجيل الخروج',
            Icons.logout,
            () => _showLogoutConfirmationDialog(context),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Divider(
          height: 16.h,
          color: Theme.of(context).dividerColor,
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
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
              color: color ?? Theme.of(context).primaryColor,
            ),
            SizedBox(width: 16.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: Theme.of(context).textTheme.bodySmall?.color,
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