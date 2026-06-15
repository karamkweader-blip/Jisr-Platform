import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/auth_actions_controller.dart';
import 'package:jisr_platform/core/widgets/company/company_account_menu.dart';
import 'package:jisr_platform/core/widgets/company/jisr_animated_logo.dart';
import 'package:jisr_platform/core/widgets/company/jisr_bottom_nav_item.dart';
import 'package:jisr_platform/views/company/home/company_home_view.dart';
import 'package:jisr_platform/views/company/profile/company_profile_view.dart';
import 'package:jisr_platform/views/company/tasks/company_tasks_view.dart';
import '../../controllers/company/company_main_controller.dart';
import '../../core/colors/app_colors.dart';

class CompanyMainView extends GetView<CompanyMainController> {
  const CompanyMainView({super.key});

  static const List<JisrBottomNavItem> _navItems = [
    JisrBottomNavItem(
      label: 'الرئيسية',
      icon: Icons.home_rounded,
    ),
    JisrBottomNavItem(
      label: 'الفرص',
      icon: Icons.work_rounded,
    ),
    JisrBottomNavItem(
      label: 'المرشحون',
      icon: Icons.groups_rounded,
    ),
    JisrBottomNavItem(
      label: 'الرسائل',
      icon: Icons.chat_rounded,
    ),
    JisrBottomNavItem(
      label: 'الملف',
      icon: Icons.business_rounded,
    ),
  ];

  static const List<Widget> _pages = [
    CompanyHomeView(),
    CompanyTasksView(),
    _CompanyPlaceholderPage(title: 'المرشحون'),
    _CompanyPlaceholderPage(title: 'الرسائل'),
    CompanyProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final authActionsController = Get.find<AuthActionsController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            'جسور',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          leading: CompanyAccountMenu(
            controller: authActionsController,
          ),
            actions: const [
    Padding(
      padding: EdgeInsetsDirectional.only(end: 12),
      child: Center(
        child: JisrAnimatedLogo(size: 38),
      ),
    ),
  ],
        ),
        body: Obx(
          () => IndexedStack(
            index: controller.selectedIndex.value,
            children: _pages,
          ),
        ),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            currentIndex: controller.selectedIndex.value,
            onTap: controller.changeTab,
            items: _navItems
                .map((item) => item.toBottomNavigationBarItem())
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _CompanyPlaceholderPage extends StatelessWidget {
  final String title;

  const _CompanyPlaceholderPage({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}