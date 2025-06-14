import 'package:noor_quran/features/admin/data/models/student_model.dart';
import 'package:flutter/material.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final responsive = (double size) => size * screenWidth / 375;

    return Container(
      margin: EdgeInsets.only(bottom: responsive(16)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(responsive(16)),
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
        borderRadius: BorderRadius.circular(responsive(16)),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: responsive(4),
                color: _getRoleColor(user),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(responsive(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserHeader(context, responsive),
                  SizedBox(height: responsive(12)),
                  _buildUserChips(responsive),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, Function(double) responsive) {
    return Row(
      children: [
        _buildUserAvatar(context, responsive),
        SizedBox(width: responsive(16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      user.name,
                      style: TextStyle(
                        fontSize: responsive(18),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                  ),
                  _buildEditButton(context, responsive),
                ],
              ),
              SizedBox(height: responsive(4)),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: responsive(14),
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) ...[
                SizedBox(height: responsive(4)),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: responsive(14),
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: responsive(4)),
                    Text(
                      user.phoneNumber!,
                      style: TextStyle(
                        fontSize: responsive(13),
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatar(BuildContext context, Function(double) responsive) {
    return Container(
      width: responsive(65),
      height: responsive(65),
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
                  fontSize: responsive(24),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildEditButton(BuildContext context, Function(double) responsive) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEditRole,
        borderRadius: BorderRadius.circular(responsive(8)),
        child: Container(
          padding: EdgeInsets.all(responsive(8)),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(responsive(8)),
          ),
          child: Icon(
            Icons.edit_outlined,
            color: Theme.of(context).primaryColor,
            size: responsive(20),
          ),
        ),
      ),
    );
  }

  Widget _buildUserChips(Function(double) responsive) {
    return Wrap(
      spacing: responsive(8),
      runSpacing: responsive(4),
      children: [
        UserRoleChip(
          text: _getUserRoleText(),
          color: _getRoleColor(user),
          icon: _getRoleIcon(user),
        ),
        UserInfoChip(
          text: _formatDate(user.createdAt),
          icon: Icons.calendar_today_outlined,
          color: Colors.orange,
        ),
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
