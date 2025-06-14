import 'package:flutter/material.dart';
import '../../../core/utils/constant/assets_manager.dart';
import 'feature_item.dart';

class HomeFeaturesGrid extends StatelessWidget {
  const HomeFeaturesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenHeight * 0.01,
      ),
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
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
            routeName: '/qibla',
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