import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../auth/data/models/user_model.dart';

class ProfileInfoWidget extends StatelessWidget {
  final UserModel user;

  const ProfileInfoWidget({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          _buildInfoRow(Icons.phone, 'رقم الهاتف', user.phoneNumber ?? 'غير متوفر'),
          SizedBox(height: 12.h),
          _buildInfoRow(
            user.isAdmin ? Icons.admin_panel_settings : 
            user.isTeacher ? Icons.school : Icons.person,
            'الدور',
            _getRoleText(),
            valueColor: _getRoleBadgeColor(),
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

  String _getRoleText() {
    if (user.isAdmin) {
      return 'مشرف';
    } else if (user.isTeacher) {
      return 'معلم';
    } else {
      return 'طالب';
    }
  }

  Color _getRoleBadgeColor() {
    if (user.isAdmin) {
      return Colors.red;
    } else if (user.isTeacher) {
      return AppColors.logoOrange;
    } else {
      return Colors.green;
    }
  }
} 