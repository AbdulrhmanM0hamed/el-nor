import 'package:beat_elslam/features/admin/data/models/student_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  late bool isAdmin;
  late bool isTeacher;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    isAdmin = widget.user.isAdmin;
    isTeacher = widget.user.isTeacher;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      child: Container(
        width: 320.w,
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'اختر الدور:',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            if (isUpdating)
              Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              )
            else
              Column(
                children: [
                  _buildRoleOption(
                    context,
                    title: 'مشرف',
                    subtitle: 'صلاحيات كاملة للنظام وإدارة المنصة',
                    icon: Icons.admin_panel_settings,
                    iconColor: Colors.red,
                    isSelected: isAdmin,
                    onTap: () {
                      if (!isUpdating) {
                        setState(() {
                          isAdmin = true;
                          isTeacher = false;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildRoleOption(
                    context,
                    title: 'معلم',
                    subtitle: 'يمكنه إدارة الحلقات وتقييم الطلاب',
                    icon: Icons.school,
                    iconColor: Colors.blue,
                    isSelected: isTeacher && !isAdmin,
                    onTap: () {
                      if (!isUpdating) {
                        setState(() {
                          isAdmin = false;
                          isTeacher = true;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildRoleOption(
                    context,
                    title: 'طالب',
                    subtitle: 'مستخدم عادي بدون صلاحيات خاصة',
                    icon: Icons.person,
                    iconColor: Colors.green,
                    isSelected: !isAdmin && !isTeacher,
                    onTap: () {
                      if (!isUpdating) {
                        setState(() {
                          isAdmin = false;
                          isTeacher = false;
                        });
                      }
                    },
                  ),
                ],
              ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: isUpdating ? null : () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'إلغاء',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isUpdating ? null : () async {
                    if (widget.user.isAdmin != isAdmin || widget.user.isTeacher != isTeacher) {
                      setState(() {
                        isUpdating = true;
                      });
                      await widget.onRoleChanged(isAdmin, isTeacher);
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'حفظ',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12.r),
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Theme.of(context).cardColor,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24.r,
              ),
            ),
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
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
} 