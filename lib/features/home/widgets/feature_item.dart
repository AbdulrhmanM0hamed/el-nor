import 'package:noor_quran/core/utils/constant/font_manger.dart';
import 'package:noor_quran/core/utils/constant/styles_manger.dart';
import 'package:noor_quran/features/home/asma_allah/data/repositories/allah_names_repository.dart';
import 'package:noor_quran/features/home/asma_allah/presentation/cubit/asma_allah_cubit.dart';
import 'package:noor_quran/features/home/asma_allah/presentation/screens/asma_allah_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';

class FeatureItem extends StatelessWidget {
  final String icon;
  final String title;
  final String routeName;
  final Color color;
  final Logger _logger = Logger();

  FeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.routeName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _logger.i('Tapped on feature: $title with route: $routeName');
        
        // استخدام نهج خاص لميزة أسماء الله الحسنى
        if (routeName == '/asma-allah') {
          _logger.i('Using direct navigation for Asma Allah feature');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => AsmaAllahCubit(
                  AllahNamesRepositoryImpl(),
                ),
                child: const AsmaAllahScreen(),
              ),
            ),
          );
        } else {
          // استخدام نظام التنقل العادي لباقي الميزات
          Navigator.pushNamed(context, routeName);
        }
      },
      child: Container(
        width: 80.w,
        height: 110.h,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30.r),
                  child: Image.asset(
                    icon,
                    width: 50.w,
                    height: 50.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: getBoldStyle(
                fontFamily: FontConstant.cairo,
                fontSize: FontSize.size12.sp,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 