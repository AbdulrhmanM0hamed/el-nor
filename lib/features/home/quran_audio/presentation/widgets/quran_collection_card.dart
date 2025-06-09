import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.r),
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
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 70.w,
                    height: 70.w,
                    decoration: BoxDecoration(
                      color: AppColors.logoTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 36.sp,
                      color: AppColors.logoTeal,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collection.title,
                          style: TextStyle(
                            
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${collection.surahs.length} سورة',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.play_circle_fill_rounded,
                    size: 40.sp,
                    color: AppColors.logoTeal,
                  ),
                ],
              ),
              if (collection.reciters.isNotEmpty && collection.reciters.length <= 5) ...[  
                // عرض القراء فقط إذا كان عددهم 5 أو أقل
                SizedBox(height: 16.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: collection.reciters.map((reciter) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.logoTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        reciter,
                        style: TextStyle(
                          fontSize: 12.sp,
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
                SizedBox(height: 16.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    ...collection.reciters.take(3).map((reciter) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.logoTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          reciter,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.logoTeal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.logoTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '+ ${collection.reciters.length - 3} آخرون',
                        style: TextStyle(
                          fontSize: 12.sp,
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