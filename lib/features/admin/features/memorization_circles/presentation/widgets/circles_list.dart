import 'package:flutter/material.dart';

import '../../../../../../../core/utils/theme/app_colors.dart';
import '../../../../data/models/memorization_circle_model.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    double responsive(double size) => size * screenWidth / 375;

    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.logoTeal),
            SizedBox(height: responsive(16)),
            Text(
              'جاري تحميل الحلقات...',
              style: TextStyle(
                fontSize: responsive(16),
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
              size: responsive(64),
              color: Colors.red,
            ),
            SizedBox(height: responsive(16)),
            Text(
              errorMessage!,
              style: TextStyle(
                fontSize: responsive(18),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive(24)),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.logoTeal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: responsive(24),
                  vertical: responsive(12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive(8)),
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
              size: responsive(64),
              color: Colors.grey.shade400,
            ),
            SizedBox(height: responsive(16)),
            Text(
              'لا توجد حلقات تحفيظ حالياً',
              style: TextStyle(
                fontSize: responsive(18),
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive(8)),
            Text(
              'اضغط على زر الإضافة لإنشاء حلقة جديدة',
              style: TextStyle(
                fontSize: responsive(14),
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      return ListView.separated(
        padding: EdgeInsets.all(responsive(16)),
        itemCount: circles.length,
        separatorBuilder: (context, index) => SizedBox(height: responsive(12)),
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
