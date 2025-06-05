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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.logoTeal,
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
} 