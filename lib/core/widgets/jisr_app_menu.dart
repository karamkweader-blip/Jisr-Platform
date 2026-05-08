import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class JisrAppMenu extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onLogoutAllSessions;

  const JisrAppMenu({
    super.key,
    required this.onLogout,
    required this.onLogoutAllSessions,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: AppColors.primaryBlue),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) {
        if (value == 'logout') onLogout();
        if (value == 'logout_all') onLogoutAllSessions();
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'logout', child: Text('تسجيل خروج')),
        PopupMenuItem(value: 'logout_all', child: Text('إنهاء جميع الجلسات')),
      ],
    );
  }
}
