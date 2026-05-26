import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF0290E8);
  static const Color primaryLight = Color(0xFF4CB3F0);
  static const Color primaryDark = Color(0xFF0164A2);

  static const Color green = Color(0xFF0290E8); // Setting this to primary as well since user wanted global change

  // Accent
  static const Color accent = Color(0xFF0290E8);
  static const Color accentLight = Color(0xFF4CB3F0);

  // Background
  static const Color background = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color scaffoldBackgroundDark = Color(0xFF121212);
  static const Color cardBackgroundDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color borderDark = Color(0xFF2C2C2C);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Border
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderFocused = Color(0xFF0290E8);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Others
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient primaryDarkGradient = LinearGradient(
    colors: [primaryDark, primary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
