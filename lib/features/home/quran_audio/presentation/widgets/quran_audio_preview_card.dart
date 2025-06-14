import 'package:flutter/material.dart';
import '../../../../../core/utils/theme/app_colors.dart';
import '../screens/quran_reciters_screen.dart';

class QuranAudioPreviewCard extends StatelessWidget {
  const QuranAudioPreviewCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.02,
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
      ),
      child: InkWell(
        onTap: () {
          // الانتقال مباشرة إلى شاشة قائمة القراء
          Navigator.pushNamed(
            context,
            QuranRecitersScreen.routeName,
          );
        },
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Row(
            children: [
              Container(
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                decoration: BoxDecoration(
                  color: AppColors.logoTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                ),
                child: Icon(
                  Icons.headphones_rounded,
                  size: screenWidth * 0.08,
                  color: AppColors.logoTeal,
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أصوات القرآن الكريم',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Text(
                      'استمع إلى تلاوات القراء المختلفة',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: screenWidth * 0.06,
                color: AppColors.logoTeal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}