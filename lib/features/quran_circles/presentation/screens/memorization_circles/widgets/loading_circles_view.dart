import 'package:flutter/material.dart';
import '../../../../../../core/utils/theme/app_colors.dart';

class LoadingCirclesView extends StatelessWidget {
  const LoadingCirclesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: AppColors.logoTeal),
          SizedBox(height: 16),
          Text(
            'جاري تحميل حلقات الحفظ...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
} 