import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class JisrBottomNavItem {
  final String label;
  final IconData icon;

  const JisrBottomNavItem({
    required this.label,
    required this.icon,
  });

  BottomNavigationBarItem toBottomNavigationBarItem() {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }

  static BottomNavigationBarThemeData theme() {
    return const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.textGrey,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.cardWhite,
      elevation: 12,
    );
  }
}