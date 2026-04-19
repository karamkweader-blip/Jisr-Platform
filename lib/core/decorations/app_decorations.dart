import 'package:flutter/material.dart';
import '../colors/app_colors.dart';

class AppDecorations {

  ///SHADOW
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: AppColors.primaryBlue.withOpacity(0.05),
      blurRadius: 15,
      offset: const Offset(0, 6),
    ),
  ];

  /// INPUT 
  static InputDecoration fieldInput(
    String hint,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,

      /// ICON
      prefixIcon: Icon(
        icon,
        color: AppColors.primaryBlue.withOpacity(0.7),
        size: 20,
      ),

      suffixIcon: suffixIcon,

      /// STYLE
      filled: true,
      fillColor: AppColors.cardWhite,

      contentPadding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 14,
      ),

      /// BORDER 
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),

      /// FOCUSED
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.primaryBlue,
          width: 1.5,
        ),
      ),

      /// ERROR
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.red.shade400,
          width: 1.3,
        ),
      ),

      /// FOCUSED ERROR
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.red.shade600,
          width: 1.5,
        ),
      ),

      /// ERROR STYLE
      errorStyle: const TextStyle(
        fontSize: 12,
        height: 1.2,
      ),

      /// HINT STYLE
      hintStyle: TextStyle(
        color: AppColors.textGrey.withOpacity(0.8),
        fontSize: 14,
      ),
    );
  }
}