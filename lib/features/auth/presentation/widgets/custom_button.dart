import 'package:flutter/material.dart';
import '../../../../core/utils/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? widthFactor;
  final double? height;
  final double? fontSize;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.widthFactor,
    this.height,
    this.fontSize,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final buttonWidth = screenWidth * (widthFactor ?? 0.9);
    final buttonHeight = height ?? screenHeight * 0.065;
    final responsiveFontSize = fontSize ?? screenWidth * 0.04;
    final iconSize = screenWidth * 0.05;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined
              ? Colors.transparent
              : (backgroundColor ?? AppColors.logoTeal),
          foregroundColor: textColor ?? (isOutlined ? AppColors.logoTeal : Colors.white),
          elevation: isOutlined ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: isOutlined
                ? BorderSide(
                    color: backgroundColor ?? AppColors.logoTeal,
                    width: 1.5,
                  )
                : BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.015,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: buttonHeight * 0.5,
                height: buttonHeight * 0.5,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOutlined ? (backgroundColor ?? AppColors.logoTeal) : Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null)
                    Icon(
                      icon,
                      size: iconSize,
                    ),
                  if (icon != null) SizedBox(width: screenWidth * 0.02),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: responsiveFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

