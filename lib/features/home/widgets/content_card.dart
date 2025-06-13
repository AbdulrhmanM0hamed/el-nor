import 'package:noor_quran/core/utils/constant/font_manger.dart';
import 'package:noor_quran/core/utils/constant/styles_manger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:noor_quran/core/utils/constant/font_manger.dart';
import 'package:noor_quran/core/utils/constant/styles_manger.dart';

class ContentCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final Color cardColor;
  final VoidCallback onTap;

  const ContentCard({
    super.key,
    required this.title,
    required this.iconPath,
    required this.cardColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: cardColor.withValues(alpha: 0.9),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Wave background
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.r),
                  bottomRight: Radius.circular(24.r),
                ),
                child: Image.asset(
                  'assets/images/splash_background.png',
                  color: Colors.white.withOpacity(0.1),
                  fit: BoxFit.cover,
                  height: 100.h,
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon with background
                  Container(
                    width: 80.w,
                    height: 80.h,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      iconPath,
                      width: 60.w,
                      height: 60.h,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const Spacer(),

                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: getBoldStyle(
                      fontFamily: FontConstant.cairo,
                      fontSize: FontSize.size18.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
