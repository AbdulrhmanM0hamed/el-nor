import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/utils/theme/app_colors.dart';
import '../../../data/models/memorization_circle_model.dart';

class CircleInfoCard extends StatelessWidget {
  final MemorizationCircleModel circle;

  const CircleInfoCard({
    Key? key,
    required this.circle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات الحلقة',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.logoTeal,
              ),
            ),
            Divider(height: 16.h),
            _buildInfoRow('اسم الحلقة:', circle.name),
            _buildInfoRow('تاريخ البدء:', _formatDate(circle.startDate)),
            _buildInfoRow('عدد الطلاب:', '${circle.studentIds.length}'),
            if (circle.description != null && circle.description!.isNotEmpty)
              _buildInfoRow('الوصف:', circle.description!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
