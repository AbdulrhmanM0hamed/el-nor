import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/student_model.dart';
import '../../../../core/utils/theme/app_colors.dart';

// Define role enum for clearer selection
enum UserRole { admin, teacher, student }

class UserRoleDialog extends StatefulWidget {
  final StudentModel user;
  final Function(bool isAdmin, bool isTeacher) onRoleChanged;

  const UserRoleDialog({
    Key? key,
    required this.user,
    required this.onRoleChanged,
  }) : super(key: key);

  @override
  State<UserRoleDialog> createState() => _UserRoleDialogState();
}

class _UserRoleDialogState extends State<UserRoleDialog> {
  late UserRole _selectedRole;

  @override
  void initState() {
    super.initState();
    // Set initial role based on user's current role
    if (widget.user.isAdmin) {
      _selectedRole = UserRole.admin;
    } else if (widget.user.isTeacher) {
      _selectedRole = UserRole.teacher;
    } else {
      _selectedRole = UserRole.student;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'تعديل دور المستخدم',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.logoTeal,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info section
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المستخدم: ${widget.user.name}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'البريد الإلكتروني: ${widget.user.email}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'اختر الدور:',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          // Role selection with radio buttons and descriptions
          _buildRoleOption(
            title: 'مشرف',
            description: 'صلاحيات كاملة للنظام وإدارة المستخدمين',
            icon: Icons.admin_panel_settings,
            color: Colors.red[700]!,
            role: UserRole.admin,
          ),
          SizedBox(height: 12.h),
          _buildRoleOption(
            title: 'معلم',
            description: 'يمكنه إدارة الحلقات وتقييم الطلاب',
            icon: Icons.school,
            color: Colors.blue[700]!,
            role: UserRole.teacher,
          ),
          SizedBox(height: 12.h),
          _buildRoleOption(
            title: 'طالب',
            description: 'مستخدم عادي بدون صلاحيات خاصة',
            icon: Icons.person,
            color: Colors.green[700]!,
            role: UserRole.student,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'إلغاء',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.sp,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Convert selected role to isAdmin and isTeacher flags
            final isAdmin = _selectedRole == UserRole.admin;
            final isTeacher = _selectedRole == UserRole.admin ||
                _selectedRole == UserRole.teacher;

            widget.onRoleChanged(isAdmin, isTeacher);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.logoTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            'حفظ',
            style: TextStyle(
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }

  // Build a role option with radio button, icon, title and description
  Widget _buildRoleOption({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required UserRole role,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedRole == role ? color : Colors.grey[300]!,
            width: _selectedRole == role ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
          color: _selectedRole == role
              ? color.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Radio<UserRole>(
              value: role,
              groupValue: _selectedRole,
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
              activeColor: color,
            ),
            SizedBox(width: 8.w),
            Icon(icon, color: color, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
