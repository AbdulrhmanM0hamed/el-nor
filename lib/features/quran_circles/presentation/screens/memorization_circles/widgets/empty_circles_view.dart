import 'package:flutter/material.dart';

class EmptyCirclesView extends StatelessWidget {
  const EmptyCirclesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveSize = screenWidth / 375;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 64 * responsiveSize,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16 * responsiveSize),
          Text(
            'لا توجد حلقات حفظ حالياً',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 18 * responsiveSize,
                  color: Colors.grey[700],
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8 * responsiveSize),
          Text(
            'سيتم إضافة حلقات جديدة قريباً',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14 * responsiveSize,
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 