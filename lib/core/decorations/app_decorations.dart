import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppDecorations {
  AppDecorations._();

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: AppColors.primaryBlue.withOpacity(0.06),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  static BoxDecoration cardDecoration({
    double radius = AppDimensions.radiusMedium,
  }) {
    return BoxDecoration(
      color: AppColors.cardWhite,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: softShadow,
    );
  }

  static InputDecoration fieldInput(
    String hint,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: AppColors.primaryBlue.withOpacity(0.7),
        size: 20,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.cardWhite,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.primaryBlue,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: BorderSide(
          color: AppColors.actionYellow.withOpacity(0.9),
          width: 1.3,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.actionYellow,
          width: 1.4,
        ),
      ),
      errorStyle: const TextStyle(
        fontSize: 12,
        height: 1.2,
      ),
      hintStyle: TextStyle(
        color: AppColors.textGrey.withOpacity(0.8),
        fontSize: 14,
      ),
    );
  }
}