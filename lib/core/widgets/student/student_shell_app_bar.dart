import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/company/jisr_animated_logo.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class StudentShellAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;

  const StudentShellAppBar({
    super.key,
    this.title = 'جسور',
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leadingWidth: 92,
      leading: Builder(
        builder: (scaffoldContext) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 6, end: 2),
            child: Row(
              children: [
                _AppBarAction(
                  tooltip: 'القائمة',
                  icon: Icons.menu_rounded,
                  onTap: () => Scaffold.of(scaffoldContext).openDrawer(),
                ),
                const SizedBox(width: 4),
                _AppBarAction(
                  tooltip: 'الإشعارات',
                  icon: Icons.notifications_none_rounded,
                  onTap: () {
                    Get.snackbar(
                      'الإشعارات',
                      'سيتم تفعيل مركز الإشعارات قريباً.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.primaryBlue,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: [
        _AppBarAction(
          tooltip: 'مساعد جسر الذكي',
          icon: Icons.smart_toy_outlined,
          onTap: () => Get.toNamed(Routes.studentChatbot),
        ),
        const Padding(
          padding: EdgeInsetsDirectional.only(start: 5, end: 12),
          child: Center(child: JisrAnimatedLogo(size: 38)),
        ),
      ],
    );
  }
}

class _AppBarAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarAction({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 38,
        height: 38,
        child: Material(
          color: dark ? const Color(0xFF17283A) : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(dark ? .24 : .08),
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
