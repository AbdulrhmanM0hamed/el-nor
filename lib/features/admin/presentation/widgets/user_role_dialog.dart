import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../auth/data/models/user_model.dart';

class UserRoleDialog extends StatefulWidget {
  final UserModel user;
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
  late bool _isAdmin;
  late bool _isTeacher;

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.user.isAdmin;
    _isTeacher = widget.user.isTeacher;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'تعديل صلاحيات المستخدم',
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
          SizedBox(height: 24.h),
          Text(
            'الصلاحيات:',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          _buildRoleCheckbox(
            'مشرف (صلاحيات كاملة)',
            _isAdmin,
            (value) {
              setState(() {
                _isAdmin = value ?? false;
                // إذا كان المستخدم مشرفًا، فهو أيضًا معلم بشكل تلقائي
                if (_isAdmin) {
                  _isTeacher = true;
                }
              });
            },
          ),
          SizedBox(height: 8.h),
          _buildRoleCheckbox(
            'معلم (يمكنه تقييم الطلاب وإدارة الحضور)',
            _isTeacher,
            (value) {
              setState(() {
                _isTeacher = value ?? false;
                // إذا لم يعد المستخدم معلمًا، فلا يمكن أن يكون مشرفًا
                if (!_isTeacher) {
                  _isAdmin = false;
                }
              });
            },
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
            widget.onRoleChanged(_isAdmin, _isTeacher);
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

  Widget _buildRoleCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.logoTeal,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }
}
