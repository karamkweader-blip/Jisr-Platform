import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/company/company_bottom_navigation_bar.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class StudentBottomNav extends StatelessWidget {
  final int currentIndex;

  const StudentBottomNav({
    super.key,
    this.currentIndex = 0,
  });

  static const List<_StudentNavDestination> _destinations = [
    _StudentNavDestination(
      route: Routes.studentTasks,
    ),
    _StudentNavDestination(
      route: Routes.studentOpportunities,
    ),
    _StudentNavDestination(
      route: Routes.studentHome,
    ),
    _StudentNavDestination(
      route: Routes.studentConversations,
    ),
    _StudentNavDestination(
      route: Routes.studentProfile,
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
    final targetRoute = _destinations[index].route;
    final currentRoute = Get.currentRoute;

    // currentIndex is only a visual fallback for secondary student pages.
    // Navigation must be blocked only when we are already on the real route;
    // otherwise pages such as conversations cannot return to Home.
    if (currentRoute == targetRoute ||
        currentRoute.startsWith('$targetRoute/')) {
      return;
    }

    Get.offNamed(targetRoute);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex();

    return CompanyBottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: _goTo,
      studentMode: true,
    );
  }
}

class _StudentNavDestination {
  final String route;

  const _StudentNavDestination({
    required this.route,
  });
}
