import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/theme/app_colors.dart';
import '../screens/quran_reciters_screen.dart';

class QuranAudioPreviewCard extends StatelessWidget {
  const QuranAudioPreviewCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: InkWell(
        onTap: () {
          // الانتقال مباشرة إلى شاشة قائمة القراء
          Navigator.pushNamed(
            context,
            QuranRecitersScreen.routeName,
          );
        },
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: AppColors.logoTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(
                  Icons.headphones_rounded,
                  size: 32.sp,
                  color: AppColors.logoTeal,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أصوات القرآن الكريم',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'استمع إلى تلاوات القراء المختلفة',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 24.sp,
                color: AppColors.logoTeal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}