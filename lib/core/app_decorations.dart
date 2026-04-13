import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  // ظل ناعم جداً للبطاقات والحقول
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: AppColors.primaryBlue.withOpacity(0.05),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  // شكل الحقول النصية (TextField) الموحد
  static InputDecoration fieldInput(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
      filled: true,
      fillColor: AppColors.cardWhite,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}