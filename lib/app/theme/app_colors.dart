import 'package:flutter/material.dart';

class AppColors {
  // Theme Colors
  static const Color pageBackground = Color(0xFFF8F9FA);
  static const Color subTitle = Color(0xFF708090);
  static const Color title = Color(0xFF002413);
  static const Color primary = Color(0xFF00BC65);
  static const Color primaryTranslucent = Color(0x1C00BC65); // 11% opacity
  static const Color positive = Color(0xFF4FD1C5);
  static const Color negative = Color(0xFFEE5F62);
  static const Color allowed = Color(0xFF00BC65);
  static const Color allowedWithRemarks = Color(0xFFCED501);
  static const Color notAllowed = Color(0xFFEE5F62);

  // Helper method to get primary with custom opacity
  static Color primaryWithOpacity(double opacity) {
    return primary.withOpacity(opacity);
  }
}
