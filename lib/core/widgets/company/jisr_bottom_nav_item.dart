import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class JisrBottomNavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const JisrBottomNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  BottomNavigationBarItem toBottomNavigationBarItem({
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      label: label,
      icon: _AnimatedNavigationIcon(
        icon: icon,
        selectedIcon: selectedIcon,
        isSelected: isSelected,
      ),
    );
  }

  static BottomNavigationBarThemeData theme() {
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.cardWhite,
      elevation: 0,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor:
          AppColors.textGrey.withOpacity(0.78),
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _AnimatedNavigationIcon extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;

  const _AnimatedNavigationIcon({
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 4),
      padding: EdgeInsets.symmetric(
        horizontal: isSelected ? 15 : 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.primaryBlue.withOpacity(0.15),
                  AppColors.primaryBlue.withOpacity(0.05),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryBlue.withOpacity(0.12)
              : Colors.transparent,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 190),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
        ) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.82,
                end: 1,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Icon(
          isSelected ? selectedIcon : icon,
          key: ValueKey<bool>(isSelected),
          color: isSelected
              ? AppColors.primaryBlue
              : AppColors.textGrey.withOpacity(0.78),
          size: isSelected ? 24 : 23,
        ),
      ),
    );
  }
}