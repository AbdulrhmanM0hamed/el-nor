import 'package:flutter/material.dart';
import '../../../../../core/utils/theme/app_colors.dart';
import '../../../../../core/utils/constant/font_manger.dart';
import '../../../../../core/utils/constant/styles_manger.dart';

class PrayerTimeCard extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final Color? color;
  final bool isNext;

  const PrayerTimeCard({
    Key? key,
    required this.title,
    required this.time,
    required this.icon,
    this.color,
    this.isNext = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardColor = color ?? AppColors.primary;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cardColor.withOpacity(0.8),
            cardColor.withOpacity(0.6),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.3),
            blurRadius: screenWidth * 0.025,
            offset: Offset(0, screenWidth * 0.01),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        child: Stack(
          children: [
            // Decorative elements
            Positioned(
              top: -screenWidth * 0.05,
              right: -screenWidth * 0.05,
              child: CircleAvatar(
                radius: screenWidth * 0.1,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
            Positioned(
              bottom: -screenWidth * 0.025,
              left: -screenWidth * 0.025,
              child: CircleAvatar(
                radius: screenWidth * 0.06,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
            
            // Main content
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                children: [
                  // Prayer icon
                  Container(
                    width: screenWidth * 0.13,
                    height: screenWidth * 0.13,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(screenWidth * 0.065),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: screenWidth * 0.07,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  
                  // Prayer info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: getBoldStyle(
                            fontFamily: FontConstant.cairo,
                            fontSize: screenWidth * 0.04, // Replaces FontSize.size16
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.01),
                        Text(
                          time,
                          style: TextStyle(
                            fontFamily: FontConstant.cairo,
                            fontSize: screenWidth * 0.055, // Replaces FontSize.size22
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Next prayer indicator
                  if (isNext)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenWidth * 0.015,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      ),
                      child: Text(
                        'الصلاة التالية',
                        style: getMediumStyle(
                          fontFamily: FontConstant.cairo,
                          fontSize: screenWidth * 0.03, // Replaces FontSize.size12
                          color: Colors.white,
                        ),
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