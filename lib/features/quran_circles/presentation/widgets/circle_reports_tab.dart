import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/theme/app_colors.dart';

class CircleReportsTab extends StatelessWidget {
  final bool isAdmin;
  final VoidCallback? onAddReport;

  const CircleReportsTab({
    Key? key,
    this.isAdmin = false,
    this.onAddReport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_rounded,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'تقارير الحلقة',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'سيتم إضافة تقارير تفصيلية عن أداء الطلاب قريباً',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (isAdmin && onAddReport != null)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('إنشاء تقرير جديد'),
                onPressed: onAddReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.logoTeal,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
