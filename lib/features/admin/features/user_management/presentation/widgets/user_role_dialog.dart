import 'package:noor_quran/features/admin/data/models/student_model.dart';
import 'package:flutter/material.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final responsive = (double size) => size * screenWidth / 375;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive(15)),
      ),
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      child: Container(
        width: responsive(320),
        padding: EdgeInsets.all(responsive(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'اختر الدور:',
              style: TextStyle(
                fontSize: responsive(18),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive(20)),
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
                    responsive,
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
                  SizedBox(height: responsive(12)),
                  _buildRoleOption(
                    context,
                    responsive,
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
                  SizedBox(height: responsive(12)),
                  _buildRoleOption(
                    context,
                    responsive,
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
            SizedBox(height: responsive(24)),
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
                      fontSize: responsive(16),
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
                    padding: EdgeInsets.symmetric(horizontal: responsive(24), vertical: responsive(12)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(responsive(8)),
                    ),
                  ),
                  child: Text(
                    'حفظ',
                    style: TextStyle(
                      fontSize: responsive(16),
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
    BuildContext context,
    Function(double) responsive, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(responsive(12)),
      child: Container(
        padding: EdgeInsets.all(responsive(12)),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(responsive(12)),
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Theme.of(context).cardColor,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(responsive(8)),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(responsive(8)),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: responsive(24),
              ),
            ),
            SizedBox(width: responsive(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: responsive(16),
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  SizedBox(height: responsive(4)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: responsive(12),
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