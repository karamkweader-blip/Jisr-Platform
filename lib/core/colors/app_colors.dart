import 'package:flutter/material.dart';

class AppColors {
 
  static const Color primaryBlue = Color(0xFF005792);
  static const Color actionYellow = Color(0xFFF0A500);  


  // ألوان الخلفيات (ليست أبيض ناصع)
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardWhite = Colors.white;

  // ألوان النصوص    
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGrey = Color(0xFF64748B);

  // التدرج اللوني الفاخر للزر الرئيسي
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF005792), Color(0xFF0077B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}