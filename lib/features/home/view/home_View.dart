import 'package:beat_elslam/core/utils/constant/font_manger.dart';
import 'package:beat_elslam/core/utils/constant/styles_manger.dart';
import 'package:beat_elslam/core/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'widgets/home_view_body.dart';

class HomeView extends StatelessWidget {
  static const String routeName = '/home';

  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ' الرئيسة',
          style: getBoldStyle(
            fontFamily: FontConstant.cairo,
            fontSize: FontSize.size22,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Top SVG background
          Positioned(
            top: 0,
            right: 30.w,
            child: Opacity(
              opacity: 0.3,
              child: SvgPicture.asset(
                'assets/images/back1.svg',
                width: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          
          // Bottom SVG background
          Positioned(
            bottom: 0,
            left: 30.w,
            child: Opacity(
              opacity: 0.3,
              child: SvgPicture.asset(
                'assets/images/back2.svg',
                width: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          
          // Main content
          const HomeViewBody(),
        ],
      ),
    );
  }
}
