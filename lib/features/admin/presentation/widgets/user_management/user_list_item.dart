import 'package:beat_elslam/features/admin/data/models/student_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'user_role_chip.dart';
import 'user_info_chip.dart';

class UserListItem extends StatelessWidget {
  final StudentModel user;
  final VoidCallback onEditRole;

  const UserListItem({
    Key? key,
    required this.user,
    required this.onEditRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4.w,
                color: _getRoleColor(user),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserHeader(context),
                  SizedBox(height: 12.h),
                  _buildUserChips(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Row(
      children: [
        _buildUserAvatar(context),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      user.name ?? '',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                  ),
                  _buildEditButton(context),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    return Container(
      width: 65.r,
      height: 65.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _getRoleColor(user).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        backgroundImage: user.profileImageUrl != null
            ? NetworkImage(user.profileImageUrl!)
            : null,
        child: user.profileImageUrl == null
            ? Text(
                _getInitial(user.name),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.sp,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEditRole,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.edit_outlined,
            color: Theme.of(context).primaryColor,
            size: 20.r,
          ),
        ),
      ),
    );
  }

  Widget _buildUserChips() {
    return Row(
      children: [
        UserRoleChip(
          text: _getUserRoleText(),
          color: _getRoleColor(user),
          icon: _getRoleIcon(user),
        ),
        SizedBox(width: 8.w),
        UserInfoChip(
          text: _formatDate(user.createdAt),
          icon: Icons.calendar_today_outlined,
          color: Colors.orange,
        ),
        if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) ...[
          SizedBox(width: 8.w),
          UserInfoChip(
            text: user.phoneNumber!,
            icon: Icons.phone_outlined,
            color: Colors.blue,
          ),
        ],
      ],
    );
  }

  String _getInitial(String? name) {
    if (name == null || name.isEmpty) return '?';
    return name[0].toUpperCase();
  }

  String _getUserRoleText() {
    if (user.isAdmin) return 'مشرف';
    if (user.isTeacher) return 'معلم';
    return 'طالب';
  }

  Color _getRoleColor(StudentModel user) {
    if (user.isAdmin) return Colors.red;
    if (user.isTeacher) return Colors.blue;
    return Colors.green;
  }

  IconData _getRoleIcon(StudentModel user) {
    if (user.isAdmin) return Icons.admin_panel_settings_outlined;
    if (user.isTeacher) return Icons.school_outlined;
    return Icons.person_outline;
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}