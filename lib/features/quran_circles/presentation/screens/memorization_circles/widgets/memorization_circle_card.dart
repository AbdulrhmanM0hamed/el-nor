import 'package:noor_quran/core/utils/theme/app_colors.dart';
import 'package:noor_quran/core/utils/user_role.dart';
import 'package:noor_quran/features/quran_circles/data/models/memorization_circle_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MemorizationCircleCard extends StatelessWidget {
  final MemorizationCircle circle;
  final UserRole userRole;
  final String userId;
  final VoidCallback onTap;

  const MemorizationCircleCard({
    Key? key,
    required this.circle,
    required this.userRole,
    required this.userId,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveSize = screenWidth / 375;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 16 * responsiveSize,
          vertical: 8 * responsiveSize,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12 * responsiveSize),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8 * responsiveSize,
              offset: Offset(0, 4 * responsiveSize),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16 * responsiveSize,
                vertical: 12 * responsiveSize,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12 * responsiveSize),
                  topRight: Radius.circular(12 * responsiveSize),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(),
                    color: Colors.white,
                    size: 20 * responsiveSize,
                  ),
                  SizedBox(width: 8 * responsiveSize),
                  Text(
                    _getStatusText(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 14 * responsiveSize,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('yyyy/MM/dd').format(circle.startDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 12 * responsiveSize,
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16 * responsiveSize),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    circle.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 16 * responsiveSize,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8 * responsiveSize),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16 * responsiveSize,
                        color: AppColors.logoTeal,
                      ),
                      SizedBox(width: 4 * responsiveSize),
                      Expanded(
                        child: Text(
                          circle.teacherName.isNotEmpty
                              ? 'المعلم: ${circle.teacherName}'
                              : 'المعلم',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontSize: 14 * responsiveSize,
                                color: Colors.grey[500],
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (circle.teacherId == userId) ...[
                        SizedBox(width: 8 * responsiveSize),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8 * responsiveSize,
                            vertical: 2 * responsiveSize,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.logoTeal.withOpacity(0.15),
                            borderRadius:
                                BorderRadius.circular(12 * responsiveSize),
                          ),
                          child: Text(
                            'أنت المعلم',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  fontSize: 12 * responsiveSize,
                                  color: AppColors.logoTeal,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 8 * responsiveSize),
                  Text(
                    circle.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12 * responsiveSize,
                          color: Colors.grey[500],
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16 * responsiveSize),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(
                        context,
                        Icons.book,
                        'السور المقررة',
                        '${circle.assignments.length}',
                        AppColors.logoTeal,
                      ),
                      _buildInfoItem(
                        context,
                        Icons.people,
                        'الطلاب',
                        '${circle.students.length}',
                        AppColors.logoTeal,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (circle.students.isNotEmpty && _canManageStudents)
              Padding(
                padding: EdgeInsets.only(
                  left: 16 * responsiveSize,
                  right: 16 * responsiveSize,
                  bottom: 16 * responsiveSize,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الطلاب المشاركين',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontSize: 12 * responsiveSize,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 8 * responsiveSize),
                    SizedBox(
                      height: 40 * responsiveSize,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: circle.students.length > 5
                            ? 5
                            : circle.students.length,
                        itemBuilder: (context, index) {
                          final showMore =
                              circle.students.length > 5 && index == 4;

                          if (showMore) {
                            return Container(
                              width: 40 * responsiveSize,
                              height: 40 * responsiveSize,
                              margin: EdgeInsets.only(right: 8 * responsiveSize),
                              decoration: BoxDecoration(
                                color: AppColors.logoTeal.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '+${circle.students.length - 4}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AppColors.logoTeal,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12 * responsiveSize,
                                      ),
                                ),
                              ),
                            );
                          }

                          return Container(
                            width: 40 * responsiveSize,
                            height: 40 * responsiveSize,
                            margin: EdgeInsets.only(right: 8 * responsiveSize),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                              image: circle.students[index].profileImageUrl !=
                                      null
                                  ? DecorationImage(
                                      image: NetworkImage(circle
                                          .students[index].profileImageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: circle.students[index].profileImageUrl ==
                                    null
                                ? Center(
                                    child: Text(
                                      _getInitial(
                                          circle.students[index].name),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: AppColors.logoTeal,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16 * responsiveSize,
                                          ),
                                    ),
                                  )
                                : null,
                          );
                        },
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

  Widget _buildInfoItem(BuildContext context, IconData icon, String label,
      String value, Color? color) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveSize = screenWidth / 375;
    final iconColor = color ?? AppColors.logoTeal;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * responsiveSize,
        vertical: 6 * responsiveSize,
      ),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8 * responsiveSize),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16 * responsiveSize,
            color: iconColor,
          ),
          SizedBox(width: 4 * responsiveSize),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12 * responsiveSize,
                  color: iconColor.withOpacity(0.8),
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12 * responsiveSize,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (circle.isExam) {
      return AppColors.logoOrange;
    }
    return circle.teacherId == userId ? AppColors.secondary : AppColors.logoTeal;
  }

  IconData _getStatusIcon() {
    if (circle.isExam) {
      return Icons.assignment;
    }
    return circle.teacherId == userId ? Icons.star : Icons.menu_book;
  }

  String _getStatusText() {
    if (circle.isExam) {
      return 'امتحان حفظ';
    }
    return circle.teacherId == userId ? 'حلقتي' : 'حلقة حفظ';
  }

  String _getInitial(String name) {
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  bool get _canManageStudents =>
      userRole == UserRole.admin ||
      userRole == UserRole.teacher ||
      circle.teacherId == userId;
}
