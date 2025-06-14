import 'package:noor_quran/core/utils/constant/font_manger.dart';
import 'package:noor_quran/core/utils/constant/styles_manger.dart';
import 'package:noor_quran/core/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/masbaha_cubit.dart';
import '../cubit/masbaha_state.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return AppBar(
      title: Text(
        title,
        style: getBoldStyle(
          fontFamily: FontConstant.cairo,
          fontSize: screenWidth * 0.045,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MasbahaScreen extends StatelessWidget {
  const MasbahaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocProvider(
      create: (context) => MasbahaCubit(),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'المسبحة الإلكترونية'),
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
                      SizedBox(height: screenHeight * 0.05),
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
                                  fontSize: screenWidth * 0.23,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.04),
                              if (isMaxCount)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.04,
                                      vertical: screenHeight * 0.01),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.04),
                                  ),
                                  child: Text(
                                    'وصلت للحد الأقصى (1000)',
                                    style: getBoldStyle(
                                      fontFamily: FontConstant.cairo,
                                      fontSize: screenWidth * 0.04,
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
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildActionButton(
                                      onTap: () =>
                                          context.read<MasbahaCubit>().reset(),
                                      label: 'تصفير',
                                      icon: Icons.refresh,
                                      color: Colors.red,
                                      screenWidth: screenWidth,
                                      screenHeight: screenHeight,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.03),
                                  Expanded(
                                    child: _buildActionButton(
                                      onTap: () => context
                                          .read<MasbahaCubit>()
                                          .setToOne(),
                                      label: 'البدء',
                                      icon: Icons.looks_one,
                                      color: state.counter == 0
                                          ? Colors.green
                                          : Colors.grey,
                                      screenWidth: screenWidth,
                                      screenHeight: screenHeight,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.025),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Circular Tasbih button
                  Positioned(
                    bottom: screenHeight * 0.22,
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
                          height: screenWidth * 0.38,
                          width: screenWidth * 0.38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isMaxCount
                                ? AppColors.primary.withOpacity(0.5)
                                : AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: screenWidth * 0.04,
                                spreadRadius: 2,
                                offset: Offset(0, screenHeight * 0.006),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'تسبيح',
                              style: getSemiBoldStyle(
                                fontFamily: FontConstant.cairo,
                                fontSize: screenWidth * 0.055,
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
    required double screenWidth,
    required double screenHeight,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(screenWidth * 0.04),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        splashColor: color.withOpacity(0.3),
        highlightColor: color.withOpacity(0.1),
        child: Ink(
          height: screenHeight * 0.07,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: screenWidth * 0.06),
              SizedBox(width: screenWidth * 0.02),
              Text(label,
                  style: getSemiBoldStyle(
                    fontFamily: FontConstant.cairo,
                    fontSize: screenWidth * 0.04,
                    color: color,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}