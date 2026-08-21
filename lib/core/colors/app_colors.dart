import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand colors.
  static const Color primaryBlue = Color(0xFF005792);
  static const Color primaryBlueLight = Color(0xFF0A78B5);
  static const Color primaryBlueDark = Color(0xFF003F6B);
  static const Color actionYellow = Color(0xFFF0A500);

  // Light theme colors.
  static const Color background = Color(0xFFF6F8FB);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainer = Color(0xFFF0F4F8);
  static const Color lightBorder = Color(0xFFE1E8EF);

  static const Color textDark = Color(0xFF172332);
  static const Color textGrey = Color(0xFF64748B);

  // Dark theme colors.
  static const Color darkBackground = Color(0xFF0D1722);
  static const Color darkSurface = Color(0xFF162332);
  static const Color darkSurfaceContainer = Color(0xFF1C2B3A);
  static const Color darkBorder = Color(0xFF293B4B);

  static const Color darkText = Color(0xFFEAF2FA);
  static const Color darkTextGrey = Color(0xFF91A4B8);

  // Content colors.
  static const Color onPrimary = Colors.white;
  static const Color onPrimaryMuted = Colors.white70;

  // Status colors.
  static const Color dangerRed = Color(0xFFD84A4A);
  static const Color successGreen = Color(0xFF2E8B67);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color infoBlue = Color(0xFF3B82F6);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      primaryBlue,
      Color(0xFF0077B6),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}