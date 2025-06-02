import 'package:beat_elslam/core/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'custom_themes/appbar_theme.dart';
import 'custom_themes/bottom_sheet_theme.dart';
import 'custom_themes/checkbox_theme.dart';
import 'custom_themes/chip_theme.dart';
import 'custom_themes/elevated_button_theme.dart';
import 'custom_themes/outline_button_theme.dart';
import 'custom_themes/text_field_theme.dart';
import 'custom_themes/text_theme.dart';


class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: Colors.white,
    textTheme: TTextTheme.lightTextTheme,
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    bottomSheetTheme: TBottomSheetTheme.lightBottomSheetTheme,
    checkboxTheme: TCheckboxTheme.lightCheckboxTheme,
    chipTheme: TChipTheme.lightChipTheme,
    inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme,
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: TOutlinedButtonTheme.lightOutlinedButtonTheme,
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: Colors.white,
      background: Colors.white,
      error: AppColors.error,
    ),
    cardColor: Colors.white,
    shadowColor: Colors.black.withOpacity(0.04),
    dividerColor: Colors.grey.shade200,
    extensions: [
      CustomColors.light,
    ],
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    textTheme: TTextTheme.darkTextTheme,
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    bottomSheetTheme: TBottomSheetTheme.darkBottomSheetTheme,
    checkboxTheme: TCheckboxTheme.darkCheckboxTheme,
    chipTheme: TChipTheme.darkChipTheme,
    inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme,
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: TOutlinedButtonTheme.darkOutlinedButtonTheme,
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: const Color(0xFF2A2A2A),
      background: const Color(0xFF1A1A1A),
      error: AppColors.error,
    ),
    cardColor: const Color(0xFF2A2A2A),
    shadowColor: Colors.black.withOpacity(0.2),
    dividerColor: Colors.grey.shade800,
    extensions: [
      CustomColors.dark,
    ],
  );
}

class CustomColors extends ThemeExtension<CustomColors> {
  final Color cardHeaderBg;
  final Color cardContentBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color timeContainerBg;
  final Color timeContainerBorder;

  CustomColors({
    required this.cardHeaderBg,
    required this.cardContentBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.timeContainerBg,
    required this.timeContainerBorder,
  });

  static final light = CustomColors(
    cardHeaderBg: AppColors.primary.withOpacity(0.04),
    cardContentBg: Colors.white,
    textPrimary: Colors.black87,
    textSecondary: Colors.black54,
    timeContainerBg: Colors.grey.shade50,
    timeContainerBorder: Colors.grey.shade200,
  );

  static final dark = CustomColors(
    cardHeaderBg: AppColors.primary.withOpacity(0.15),
    cardContentBg: const Color(0xFF2A2A2A),
    textPrimary: Colors.white,
    textSecondary: Colors.white70,
    timeContainerBg: const Color(0xFF353535),
    timeContainerBorder: Colors.grey.shade800,
  );

  @override
  ThemeExtension<CustomColors> copyWith({
    Color? cardHeaderBg,
    Color? cardContentBg,
    Color? textPrimary,
    Color? textSecondary,
    Color? timeContainerBg,
    Color? timeContainerBorder,
  }) {
    return CustomColors(
      cardHeaderBg: cardHeaderBg ?? this.cardHeaderBg,
      cardContentBg: cardContentBg ?? this.cardContentBg,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      timeContainerBg: timeContainerBg ?? this.timeContainerBg,
      timeContainerBorder: timeContainerBorder ?? this.timeContainerBorder,
    );
  }

  @override
  ThemeExtension<CustomColors> lerp(
    ThemeExtension<CustomColors>? other,
    double t,
  ) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      cardHeaderBg: Color.lerp(cardHeaderBg, other.cardHeaderBg, t)!,
      cardContentBg: Color.lerp(cardContentBg, other.cardContentBg, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      timeContainerBg: Color.lerp(timeContainerBg, other.timeContainerBg, t)!,
      timeContainerBorder: Color.lerp(timeContainerBorder, other.timeContainerBorder, t)!,
    );
  }
}
