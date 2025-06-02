import 'package:flutter/material.dart';
import '../../../../../core/utils/constant/font_manger.dart';
import '../../../../../core/utils/theme/app_colors.dart';

/// A loading indicator widget with a message
class LoadingIndicator extends StatelessWidget {
  /// The message to display below the loading indicator
  final String message;
  
  const LoadingIndicator({
    Key? key,
    this.message = 'جاري تحميل المصحف...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.logoTeal),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontFamily: FontConstant.cairo,
                fontSize: 16,
                color: AppColors.logoTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
