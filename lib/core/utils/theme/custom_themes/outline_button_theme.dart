import 'package:beat_elslam/core/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TOutlinedButtonTheme {
  TOutlinedButtonTheme._();

  static final lightOutlinedButtonTheme = OutlinedButton.styleFrom(
    elevation: 0,
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary),
    textStyle: const TextStyle(
      fontSize: 16,
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
      fontFamily: 'Cairo',
    ),
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static final darkOutlinedButtonTheme = OutlinedButton.styleFrom(
    elevation: 0,
    foregroundColor: Colors.white,
    side: const BorderSide(color: AppColors.primary),
    textStyle: const TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontFamily: 'Cairo',
    ),
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}
