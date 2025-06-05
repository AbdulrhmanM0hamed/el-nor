import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../auth/data/models/user_model.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final UserModel user;

  const ProfileHeaderWidget({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220.h,
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
                backgroundImage: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                    ? NetworkImage(user.profileImageUrl!)
                    : null,
                child: user.profileImageUrl == null || user.profileImageUrl!.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 50.sp,
                        color: AppColors.logoTeal,
                      )
                    : null,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getRoleBadgeColor(),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  _getRoleText(),
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
            user.name,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
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