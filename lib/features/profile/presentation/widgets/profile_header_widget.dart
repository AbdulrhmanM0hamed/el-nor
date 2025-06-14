import 'package:flutter/material.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final responsive = (double size) => size * screenWidth / 375;

    return Container(
      width: double.infinity,
      height: responsive(220),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(responsive(30)),
          bottomRight: Radius.circular(responsive(30)),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: responsive(50),
                backgroundColor: Theme.of(context).cardColor,
                backgroundImage: user.profileImageUrl != null &&
                        user.profileImageUrl!.isNotEmpty
                    ? NetworkImage(user.profileImageUrl!)
                    : null,
                child: user.profileImageUrl == null ||
                        user.profileImageUrl!.isEmpty
                    ? Icon(
                        Icons.person,
                        size: responsive(50),
                        color: Theme.of(context).primaryColor,
                      )
                    : null,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: responsive(8), vertical: responsive(4)),
                decoration: BoxDecoration(
                  color: _getRoleBadgeColor(),
                  borderRadius: BorderRadius.circular(responsive(12)),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  _getRoleText(),
                  style: TextStyle(
                    fontSize: responsive(12),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive(16)),
          Text(
            user.name,
            style: TextStyle(
              fontSize: responsive(24),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: responsive(8)),
          Text(
            user.email,
            style: TextStyle(
              fontSize: responsive(16),
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