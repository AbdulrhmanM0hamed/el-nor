import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:noor_quran/core/utils/constant/font_manger.dart';
import 'package:noor_quran/core/utils/constant/styles_manger.dart';
import 'package:noor_quran/features/home/asma_allah/data/repositories/allah_names_repository.dart';
import 'package:noor_quran/features/home/asma_allah/presentation/cubit/asma_allah_cubit.dart';
import 'package:noor_quran/features/home/asma_allah/presentation/screens/asma_allah_screen.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth * 0.22;
    final itemHeight = itemWidth * 1.3;

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
        width: itemWidth,
        height: itemHeight,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(itemWidth * 0.25),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(itemWidth * 0.3),
                  child: Image.asset(
                    icon,
                    width: itemWidth * 0.6,
                    height: itemWidth * 0.6,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            SizedBox(height: itemHeight * 0.08),
            Text(
              title,
              textAlign: TextAlign.center,
              style: getBoldStyle(
                fontFamily: FontConstant.cairo,
                fontSize: itemWidth * 0.15,
                color: color.withOpacity(0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
} 