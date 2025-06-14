import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../../core/utils/theme/app_colors.dart';
import '../../../../data/models/memorization_circle_model.dart';
import '../../../../shared/profile_image_fixed.dart';

class CircleCard extends StatelessWidget {
  final MemorizationCircleModel circle;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CircleCard({
    Key? key,
    required this.circle,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsive = (double size) => size * screenWidth / 375;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive(12)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(responsive(12)),
        child: Padding(
          padding: EdgeInsets.all(responsive(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, responsive),
              Divider(height: responsive(16)),
              _buildCircleDetails(context, responsive),
              if (circle.description != null && circle.description!.isNotEmpty) ...[
                SizedBox(height: responsive(8)),
                Text(
                  circle.description!,
                  style: TextStyle(
                    fontSize: responsive(12),
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: responsive(12)),
              _buildFooter(context, responsive),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Function(double) responsive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            circle.name,
            style: TextStyle(
              fontSize: responsive(16),
              fontWeight: FontWeight.bold,
              color: AppColors.logoTeal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: onEdit,
              icon: Icon(
                Icons.edit,
                color: AppColors.logoTeal,
                size: responsive(20),
              ),
              constraints: BoxConstraints(
                minWidth: responsive(36),
                minHeight: responsive(36),
              ),
              padding: EdgeInsets.zero,
              splashRadius: responsive(24),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete,
                color: Colors.red,
                size: responsive(20),
              ),
              constraints: BoxConstraints(
                minWidth: responsive(36),
                minHeight: responsive(36),
              ),
              padding: EdgeInsets.zero,
              splashRadius: responsive(24),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircleDetails(BuildContext context, Function(double) responsive) {
    return Row(
      children: [
        if (circle.teacherId != null && circle.teacherId!.isNotEmpty) ...[
          ProfileImage(
            imageUrl: circle.teacherImageUrl,
            name: circle.teacherName ?? 'معلم',
            color: AppColors.logoTeal,
            size: responsive(40.0),
            showDebugLogs: false,
          ),
          SizedBox(width: responsive(12)),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (circle.teacherName != null && circle.teacherName!.isNotEmpty) ...[
                Text(
                  'المعلم: ${circle.teacherName}',
                  style: TextStyle(
                    fontSize: responsive(14),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: responsive(4)),
              ] else ...[
                Text(
                  'لم يتم تعيين معلم بعد',
                  style: TextStyle(
                    fontSize: responsive(14),
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: responsive(4)),
              ],
              Text(
                'تاريخ البدء: ${_formatDate(circle.startDate)}',
                style: TextStyle(
                  fontSize: responsive(12),
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, Function(double) responsive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive(8),
            vertical: responsive(4),
          ),
          decoration: BoxDecoration(
            color: AppColors.logoOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(responsive(12)),
            border: Border.all(
              color: AppColors.logoOrange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.people,
                size: responsive(14),
                color: AppColors.logoOrange,
              ),
              SizedBox(width: responsive(4)),
              Text(
                '${circle.studentIds.length} طالب',
                style: TextStyle(
                  fontSize: responsive(12),
                  fontWeight: FontWeight.w500,
                  color: AppColors.logoOrange,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: responsive(16),
          color: Colors.grey.shade400,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'ar').format(date);
  }
}
