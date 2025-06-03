import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/utils/theme/app_colors.dart';
import '../../../data/models/memorization_circle_model.dart';
import '../shared/profile_image_fixed.dart';

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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Divider(height: 16.h),
              _buildCircleDetails(),
              if (circle.description != null && circle.description!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  circle.description!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 12.h),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            circle.name,
            style: TextStyle(
              fontSize: 16.sp,
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
                size: 20.sp,
              ),
              constraints: BoxConstraints(
                minWidth: 36.w,
                minHeight: 36.h,
              ),
              padding: EdgeInsets.zero,
              splashRadius: 24.r,
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete,
                color: Colors.red,
                size: 20.sp,
              ),
              constraints: BoxConstraints(
                minWidth: 36.w,
                minHeight: 36.h,
              ),
              padding: EdgeInsets.zero,
              splashRadius: 24.r,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircleDetails() {
    return Row(
      children: [
        if (circle.teacherId != null && circle.teacherId!.isNotEmpty) ...[
          ProfileImage(
            imageUrl: circle.teacherImageUrl,
            name: circle.teacherName ?? 'معلم',
            color: AppColors.logoTeal,
            size: 40.0,
            showDebugLogs: false,
          ),
          SizedBox(width: 12.w),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (circle.teacherName != null && circle.teacherName!.isNotEmpty) ...[
                Text(
                  'المعلم: ${circle.teacherName}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
              ] else ...[
                Text(
                  'لم يتم تعيين معلم بعد',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4.h),
              ],
              Text(
                'تاريخ البدء: ${_formatDate(circle.startDate)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8.w,
            vertical: 4.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.logoOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.logoOrange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.people,
                size: 14.sp,
                color: AppColors.logoOrange,
              ),
              SizedBox(width: 4.w),
              Text(
                '${circle.studentIds.length} طالب',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.logoOrange,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: Colors.grey.shade400,
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
