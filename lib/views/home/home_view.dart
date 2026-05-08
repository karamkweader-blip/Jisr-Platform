import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/auth_actions_controller.dart';
import 'package:jisr_platform/controllers/home/home_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/jisr_app_menu.dart';
import 'package:jisr_platform/controllers/auth/auth_actions_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authActionsController = Get.find<AuthActionsController>();
    Get.find<AuthActionsController>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          centerTitle: true,
          title: const Text(
            'جسور',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: JisrAppMenu(
            onLogout: authActionsController.logout,
            onLogoutAllSessions: authActionsController.logoutAllSessions,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.22),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: AppColors.actionYellow,
                      size: 42,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.homeData.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      controller.homeData.subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 34),

              Row(
                children: const [
                  Expanded(
                    child: _HomeActionCard(
                      icon: Icons.person_outline,
                      title: 'ملفي الشخصي',
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _HomeActionCard(
                      icon: Icons.upload_file_outlined,
                      title: 'رفع CV',
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BottomItem(icon: Icons.person_outline, title: 'ملف شخصي'),
                    _BottomItem(
                      icon: Icons.home_rounded,
                      title: 'الرئيسية',
                      isActive: true,
                    ),
                    _BottomItem(
                      icon: Icons.upload_file_outlined,
                      title: 'رفع CV',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _HomeActionCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 38),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;

  const _BottomItem({
    required this.icon,
    required this.title,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: isActive ? AppColors.actionYellow : AppColors.textGrey,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.actionYellow : AppColors.textGrey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
