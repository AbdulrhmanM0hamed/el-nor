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
    final cardColor = color ?? AppColors.primary;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cardColor.withOpacity(0.8),
            cardColor.withOpacity(0.6),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Decorative elements
            Positioned(
              top: -20,
              right: -20,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
            Positioned(
              bottom: -10,
              left: -10,
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
            
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Prayer icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Prayer info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: getBoldStyle(
                            fontFamily: FontConstant.cairo,
                            fontSize: FontSize.size16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          time,
                          style:const TextStyle(
                            fontFamily: FontConstant.cairo,
                            fontSize: FontSize.size22,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'الصلاة التالية',
                        style: getMediumStyle(
                          fontFamily: FontConstant.cairo,
                          fontSize: FontSize.size12,
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