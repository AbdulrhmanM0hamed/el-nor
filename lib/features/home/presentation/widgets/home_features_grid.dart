import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/constant/assets_manager.dart';
import 'feature_item.dart';

class HomeFeaturesGrid extends StatelessWidget {
  const HomeFeaturesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130.h,
      padding: EdgeInsets.only(top: 10.h, left: 12.w, right: 12.w),
      margin: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FeatureItem(
            icon: AssetsManager.pngtreeImage,
            title: 'المسبحة',
            routeName: '/masabha',
            color: const Color(0xFF83B783), // Green shade
          ),
          FeatureItem(
            icon: AssetsManager.qiblahImage,
            title: 'القبلة',
            routeName: '/qupla',
            color: const Color(0xFFC89B7B), // Brown shade
          ),
          FeatureItem(
            icon: AssetsManager.ramadanImage,
            title: 'مواقيت الصلاة',
            routeName: '/prayer-times',
            color: const Color(0xFF7B90C8), // Blue shade
          ),
          FeatureItem(
            icon: AssetsManager.azkarImage,
            title: 'الاذكار',
            routeName: '/athkar',
            color: const Color(0xFFC87B7B), // Red shade
          ),
        ],
      ),
    );
  }
}