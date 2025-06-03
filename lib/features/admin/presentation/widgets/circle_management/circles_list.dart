import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/theme/app_colors.dart';
import '../../../data/models/memorization_circle_model.dart';
import 'circle_card.dart';

class CirclesList extends StatelessWidget {
  final List<MemorizationCircleModel> circles;
  final Function(MemorizationCircleModel) onCircleTap;
  final Function(MemorizationCircleModel) onEditCircle;
  final Function(MemorizationCircleModel) onDeleteCircle;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const CirclesList({
    Key? key,
    required this.circles,
    required this.onCircleTap,
    required this.onEditCircle,
    required this.onDeleteCircle,
    required this.isLoading,
    this.errorMessage,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.logoTeal),
            SizedBox(height: 16.h),
            Text(
              'جاري تحميل الحلقات...',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    } else if (errorMessage != null && errorMessage!.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Colors.red,
            ),
            SizedBox(height: 16.h),
            Text(
              errorMessage!,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.logoTeal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    } else if (circles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.circle_outlined,
              size: 64.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد حلقات تحفيظ حالياً',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'اضغط على زر الإضافة لإنشاء حلقة جديدة',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      return ListView.separated(
        padding: EdgeInsets.all(16.r),
        itemCount: circles.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final circle = circles[index];
          return CircleCard(
            circle: circle,
            onTap: () => onCircleTap(circle),
            onEdit: () => onEditCircle(circle),
            onDelete: () => onDeleteCircle(circle),
          );
        },
      );
    }
  }
}
