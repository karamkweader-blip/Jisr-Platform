import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class StudentBottomNav extends StatelessWidget {
  final int currentIndex;

  const StudentBottomNav({
    super.key,
    this.currentIndex = 0,
  });

  static const List<_StudentNavDestination> _destinations = [
    _StudentNavDestination(
      label: 'الرئيسية',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      route: Routes.studentHome,
    ),
    _StudentNavDestination(
      label: 'الملف',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      route: Routes.studentProfile,
    ),
    _StudentNavDestination(
      label: 'السيرة',
      icon: Icons.description_outlined,
      selectedIcon: Icons.description_rounded,
      route: Routes.cvUpload,
    ),
    _StudentNavDestination(
      label: 'المجتمع',
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups_rounded,
      route: Routes.studentCommunityPosts,
    ),
    _StudentNavDestination(
      label: 'تقديماتي',
      icon: Icons.fact_check_outlined,
      selectedIcon: Icons.fact_check_rounded,
      route: Routes.studentOpportunityApplications,
    ),
  ];

  int _selectedIndex() {
    final currentRoute = Get.currentRoute;

    for (int index = 0; index < _destinations.length; index++) {
      final destinationRoute = _destinations[index].route;

      if (currentRoute == destinationRoute ||
          currentRoute.startsWith('$destinationRoute/')) {
        return index;
      }
    }

    if (currentIndex >= 0 && currentIndex < _destinations.length) {
      return currentIndex;
    }

    return 0;
  }

  void _goTo(int index) {
    final selectedIndex = _selectedIndex();

    if (index == selectedIndex) return;

    Get.offNamed(_destinations[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex();

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(.08),
              blurRadius: 22,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: _goTo,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: AppColors.textGrey.withOpacity(.75),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w800,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
          ),
          items: List.generate(
            _destinations.length,
            (index) {
              final destination = _destinations[index];
              final isSelected = selectedIndex == index;

              return BottomNavigationBarItem(
                label: destination.label,
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(
                    destination.icon,
                    size: 23,
                  ),
                ),
                activeIcon: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        AppColors.primaryBlue.withOpacity(.15),
                        AppColors.primaryBlue.withOpacity(.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(.12),
                    ),
                  ),
                  child: Icon(
                    isSelected
                        ? destination.selectedIcon
                        : destination.icon,
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StudentNavDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;

  const _StudentNavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });
}