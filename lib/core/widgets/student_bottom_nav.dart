import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class StudentBottomNav extends StatelessWidget {
  final int currentIndex;

  const StudentBottomNav({super.key, required this.currentIndex});

  void _goTo(int index) {
    if (index == currentIndex) return;

    if (index == 0) {
      Get.offNamed(Routes.studentProfile);
    } else if (index == 1) {
      Get.offNamed(Routes.studentHome);
    } else if (index == 2) {
      Get.offNamed(Routes.cvUpload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 0, 22, 18),
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
            isActive: currentIndex == 0,
            onTap: () => _goTo(0),
          ),
          _BottomItem(
            icon: Icons.home_rounded,
            title: 'الرئيسية',
            isActive: currentIndex == 1,
            onTap: () => _goTo(1),
          ),
          _BottomItem(
            icon: Icons.upload_file_outlined,
            title: 'رفع CV',
            isActive: currentIndex == 2,
            onTap: () => _goTo(2),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.actionYellow.withOpacity(.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: isActive ? 28 : 24),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
