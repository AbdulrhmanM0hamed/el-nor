import 'package:noor_quran/core/utils/constant/font_manger.dart';
import 'package:noor_quran/core/utils/constant/styles_manger.dart';
import 'package:flutter/material.dart';


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
    final screenWidth = MediaQuery.of(context).size.width;
    final cardSize = screenWidth * 0.4;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(screenWidth * 0.02),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.06),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.9),
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
                  bottomLeft: Radius.circular(screenWidth * 0.06),
                  bottomRight: Radius.circular(screenWidth * 0.06),
                ),
                child: Image.asset(
                  'assets/images/splash_background.png',
                  color: Colors.white.withOpacity(0.1),
                  fit: BoxFit.cover,
                  height: cardSize * 0.5,
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(cardSize * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon with background
                  Container(
                    width: cardSize * 0.5,
                    height: cardSize * 0.5,
                    padding: EdgeInsets.all(cardSize * 0.075),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      iconPath,
                      width: cardSize * 0.375,
                      height: cardSize * 0.375,
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
                      fontSize: cardSize * 0.1,
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
