import 'package:flutter/material.dart';

class AppColors {
  // Main logo colors
  static const Color logoOrange = Color(0xFFE59022);
  static const Color logoTeal = Color.fromARGB(255, 49, 144, 153);
  static const Color logoYellow = Color(0xFFF5EB46);
  
  // Original app colors
  static const Color primary = Color.fromARGB(255, 49, 144, 153); // Updated to match logoTeal
  static const Color secondary = Color.fromARGB(255, 59, 110, 151);
  static const Color accent = Color(0xFFE59022); // Updated to match logoOrange

  // Background Colors
  static const Color scaffoldBackground = Colors.white;
  static const Color cardBackground = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF263643);
  static const Color textSecondary = Color.fromARGB(255, 113, 119, 126);
  static const Color textLight = Colors.white;
  static const Color textLight70 = Colors.white60;
  static const Color black = Color.fromARGB(255, 0, 0, 0);

  // Status Colors
  static const Color success = Color(0xFF28A745);
  static const Color error = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF17A2B8);

  // Border Colors
  static const Color border = Color.fromARGB(255, 202, 202, 202);
  static const Color divider = Color.fromARGB(34, 225, 225, 225);
  static const Color grey = Colors.grey;

  // Rating Colors
  static const Color starActive = Color(0xFFFFBC57);
  static const Color starInactive = Color(0xFFD1D1D1);

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color white = Color.fromARGB(255, 255, 255, 255);

  static Color getContainerBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]! // لون داكن للوضع الليلي
        : Colors.grey[100]!; // لون فاتح للوضع النهاري
  }
}
