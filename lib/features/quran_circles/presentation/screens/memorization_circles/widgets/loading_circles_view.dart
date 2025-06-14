import 'package:flutter/material.dart';
import '../../../../../../core/utils/theme/app_colors.dart';

class LoadingCirclesView extends StatelessWidget {
  const LoadingCirclesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveSize = screenWidth / 375;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.logoTeal),
          SizedBox(height: 16 * responsiveSize),
          Text(
            'جاري تحميل حلقات الحفظ...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16 * responsiveSize,
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
} 