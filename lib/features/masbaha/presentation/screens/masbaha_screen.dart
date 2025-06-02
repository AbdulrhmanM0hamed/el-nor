import 'package:beat_elslam/core/utils/constant/font_manger.dart';
import 'package:beat_elslam/core/utils/constant/styles_manger.dart';
import 'package:beat_elslam/core/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/masbaha_cubit.dart';
import '../cubit/masbaha_state.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({Key? key, required String title})
      : super(
          key: key,
          title: Text(
            title,
            style: getBoldStyle(
              fontFamily: FontConstant.cairo,
              fontSize: 18.sp,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
        );
}

class MasbahaScreen extends StatelessWidget {
  const MasbahaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MasbahaCubit(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'المسبحة الإلكترونية'),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.primary.withOpacity(0.05),
              ],
            ),
          ),
          child: BlocBuilder<MasbahaCubit, MasbahaState>(
            builder: (context, state) {
              final isMaxCount = state.counter >= MasbahaCubit.maxCount;
              
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Content section (counter and saved counts)
                  Column(
                    children: [
                      // Counter display
                      SizedBox(height: 40.h),
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${state.counter}',
                                style: getBoldStyle(
                                  fontFamily: FontConstant.cairo,
                                  fontSize: 90.sp,
                                  color: AppColors.primary,
                                )
                              ),
                              SizedBox(height: 30.h),
                              if (isMaxCount)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Text(
                                    'وصلت للحد الأقصى (1000)',
                                    style: getBoldStyle(
                                      fontFamily: FontConstant.cairo,
                                      fontSize: 16.sp,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Action buttons at bottom
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildActionButton(
                                      onTap: () => context.read<MasbahaCubit>().reset(),
                                      label: 'تصفير',
                                      icon: Icons.refresh,
                                      color: Colors.red,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: _buildActionButton(
                                      onTap: () => context.read<MasbahaCubit>().setToOne(),
                                      label: 'البدء',
                                      icon: Icons.looks_one,
                                      color: state.counter == 0 ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Circular Tasbih button
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.3,
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: isMaxCount 
                          ? null 
                          : () => context.read<MasbahaCubit>().increment(),
                        splashColor: Colors.white.withOpacity(0.3),
                        highlightColor: Colors.white.withOpacity(0.1),
                        child: Ink(
                          height: 150.h,
                          width: 150.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isMaxCount 
                              ? AppColors.primary.withOpacity(0.5) 
                              : AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 15.r,
                                spreadRadius: 2,
                                offset: Offset(0, 5.h),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'تسبيح',
                              style: getSemiBoldStyle(
                                fontFamily: FontConstant.cairo,
                                fontSize: 22.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16.r),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        splashColor: color.withOpacity(0.3),
        highlightColor: color.withOpacity(0.1),
        child: Ink(
          height: 56.h,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                label,
                style: getSemiBoldStyle(
                  fontFamily: FontConstant.cairo,
                  fontSize: 16.sp,
                  color: color,
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
} 