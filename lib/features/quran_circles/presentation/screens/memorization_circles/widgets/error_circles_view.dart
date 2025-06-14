import 'package:flutter/material.dart';
import '../../../../../../core/utils/theme/app_colors.dart';

class ErrorCirclesView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorCirclesView({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveSize = screenWidth / 375;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.0 * responsiveSize),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64 * responsiveSize,
              color: AppColors.error,
            ),
            SizedBox(height: 16 * responsiveSize),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16 * responsiveSize,
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16 * responsiveSize),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.logoTeal,
                padding: EdgeInsets.symmetric(
                  horizontal: 32 * responsiveSize,
                  vertical: 12 * responsiveSize,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * responsiveSize),
                ),
              ),
              child: Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontSize: 14 * responsiveSize,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 