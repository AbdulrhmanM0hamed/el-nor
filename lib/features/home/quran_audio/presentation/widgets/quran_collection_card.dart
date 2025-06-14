import 'package:flutter/material.dart';

import '../../data/models/quran_reciter_model.dart';
import '../screens/quran_player_screen.dart';
import '../../../../../core/utils/theme/app_colors.dart';

class QuranCollectionCard extends StatelessWidget {
  final QuranCollection collection;

  const QuranCollectionCard({
    Key? key,
    required this.collection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.01,
        vertical: screenWidth * 0.02,
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
      ),
      child: InkWell(
        onTap: () {
          try {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuranPlayerScreen(collection: collection),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('حدث خطأ أثناء فتح صفحة القارئ: ${e.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'حسنًا',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02,
            vertical: screenWidth * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: screenWidth * 0.18,
                    height: screenWidth * 0.18,
                    decoration: BoxDecoration(
                      color: AppColors.logoTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: screenWidth * 0.09,
                      color: AppColors.logoTeal,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collection.title,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenWidth * 0.01),
                        Text(
                          '${collection.surahs.length} سورة',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.play_circle_fill_rounded,
                    size: screenWidth * 0.1,
                    color: AppColors.logoTeal,
                  ),
                ],
              ),
              if (collection.reciters.isNotEmpty && collection.reciters.length <= 5) ...[
                // عرض القراء فقط إذا كان عددهم 5 أو أقل
                SizedBox(height: screenWidth * 0.04),
                Wrap(
                  spacing: screenWidth * 0.02,
                  runSpacing: screenWidth * 0.02,
                  children: collection.reciters.map((reciter) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenWidth * 0.015,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.logoTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      ),
                      child: Text(
                        reciter,
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: AppColors.logoTeal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ] else if (collection.reciters.length > 5) ...[
                // إذا كان عدد القراء أكثر من 5، عرض أول 3 فقط مع إشارة إلى وجود المزيد
                SizedBox(height: screenWidth * 0.04),
                Wrap(
                  spacing: screenWidth * 0.02,
                  runSpacing: screenWidth * 0.02,
                  children: [
                    ...collection.reciters.take(3).map((reciter) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenWidth * 0.015,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.logoTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        ),
                        child: Text(
                          reciter,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: AppColors.logoTeal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenWidth * 0.015,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.logoTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      ),
                      child: Text(
                        '+ ${collection.reciters.length - 3} آخرون',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: AppColors.logoTeal,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}