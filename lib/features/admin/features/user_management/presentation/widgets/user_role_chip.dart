import 'package:flutter/material.dart';

class UserRoleChip extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const UserRoleChip({
    Key? key,
    required this.text,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsive = (double size) => size * screenWidth / 375;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive(12),
        vertical: responsive(6),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive(20)),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: responsive(16),
            color: color,
          ),
          SizedBox(width: responsive(6)),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: responsive(12),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}