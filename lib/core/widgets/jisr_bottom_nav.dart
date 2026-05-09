import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/routes/app_routes.dart';

enum JisrBottomNavTab { profile, home, cv }

class JisrBottomNav extends StatelessWidget {
  final JisrBottomNavTab activeTab;

  const JisrBottomNav({super.key, required this.activeTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 18),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomItem(
            icon: Icons.person_outline,
            title: 'ملف شخصي',
            isActive: activeTab == JisrBottomNavTab.profile,
            onTap: () {},
          ),
          _BottomItem(
            icon: Icons.home_rounded,
            title: 'الرئيسية',
            isActive: activeTab == JisrBottomNavTab.home,
            onTap: () {
              if (activeTab != JisrBottomNavTab.home) {
                Get.offNamed(Routes.studentHome);
              }
            },
          ),
          _BottomItem(
            icon: Icons.upload_file_outlined,
            title: 'رفع CV',
            isActive: activeTab == JisrBottomNavTab.cv,
            onTap: () {
              if (activeTab != JisrBottomNavTab.cv) {
                Get.toNamed(Routes.cvUpload);
              }
            },
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
  final VoidCallback onTap;

  const _BottomItem({
    required this.icon,
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.actionYellow : AppColors.textGrey;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontFamily: 'Cairo',
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
