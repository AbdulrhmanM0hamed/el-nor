import 'package:beat_elslam/core/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'content_card.dart';

class IslamicContentGrid extends StatelessWidget {
  const IslamicContentGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.8, // Make cards slightly taller than wide
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Quran Card
          ContentCard(
            title: 'القرآن الكريم',
            iconPath: 'assets/images/mushaf_1.png',
            cardColor: AppColors.logoTeal.withValues(alpha: .2),
            onTap: () {
              Navigator.pushNamed(context, '/quran');
            },
          ),
          
          // Hadith Card
          ContentCard(
            title: 'الأحاديث النبوية',
            iconPath: 'assets/images/moon.png',
            cardColor: const Color(0xFFB17AD8),
            onTap: () {
              Navigator.pushNamed(context, '/hadith');
            },
          ),
          
          // Tafsir Card
          ContentCard(
            title: 'تفسير القرآن',
            iconPath: 'assets/images/mushaf.png',
            cardColor: const Color(0xFFE678AE),
            onTap: () {
              Navigator.pushNamed(context, '/tafsir');
            },
          ),
          
          // Names of Allah Card
          ContentCard(
            title: 'أسماء الله الحسنى',
            iconPath: 'assets/images/nameofallah.png',
            cardColor: const Color.fromARGB(255, 74, 137, 168),
            onTap: () {
              Navigator.pushNamed(context, '/asma-allah');
            },
          ),
        ],
      ),
    );
  }
} 