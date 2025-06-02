import 'package:beat_elslam/core/utils/constant/font_manger.dart';
import 'package:flutter/material.dart';

TextStyle _getTextStyle(double fontSize, FontWeight fontWeight, 
    String fontfamily, FontStyle fontStyle, [Color? color]) {
  return TextStyle(
      fontSize: fontSize,
      color: color, // اللون يتم تعيينه فقط إذا تم تمريره
      fontWeight: fontWeight,
      fontFamily: fontfamily,
      fontStyle: fontStyle);
}

TextStyle getRegularStyle(
    {double fontSize = FontSize.size12,
    Color? color, // اللون كمعامل اختياري
    required String fontFamily,
    FontStyle? fontStyle}) {
  return _getTextStyle(fontSize, FontWeightManger.Regular, fontFamily,
      fontStyle ?? FontStyle.normal, color);
}

// Medium style
TextStyle getMediumStyle(
    {double fontSize = FontSize.size12,
    Color? color, // اللون كمعامل اختياري
    required String fontFamily,
    FontStyle? fontStyle}) {
  return _getTextStyle(fontSize, FontWeightManger.Medium, fontFamily,
      fontStyle ?? FontStyle.normal, color);
}

// Light style
TextStyle getLightStyle(
    {double fontSize = FontSize.size12,
    Color? color, // اللون كمعامل اختياري
    required String fontFamily,
    FontStyle? fontStyle}) {
  return _getTextStyle(fontSize, FontWeightManger.Light, fontFamily,
      fontStyle ?? FontStyle.normal, color);
}

// Bold style
TextStyle getBoldStyle(
    {double fontSize = FontSize.size12,
    Color? color, // اللون كمعامل اختياري
    required String fontFamily,
    FontStyle? fontStyle}) {
  return _getTextStyle(fontSize, FontWeightManger.Bold, fontFamily,
      fontStyle ?? FontStyle.normal, color);
}

// SemiBold style
TextStyle getSemiBoldStyle(
    {double fontSize = FontSize.size12,
    Color? color, // اللون كمعامل اختياري
    required String fontFamily,
    FontStyle? fontStyle}) {
  return _getTextStyle(fontSize, FontWeightManger.SemiBold, fontFamily,
      fontStyle ?? FontStyle.normal, color);
}
