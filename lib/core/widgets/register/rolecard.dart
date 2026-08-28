import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/role_controller.dart';

class RoleCard extends GetView<RoleController> {
  final UserRole role;
  final String title;
  final String desc;
  final Color color;
  final IconData icon;

  const RoleCard({
    super.key,
    required this.role,
    required this.title,
    required this.desc,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    return Obx(
      () {
        final isSelected =
            controller.selectedRole.value == role;

        return GestureDetector(
          onTap: () {
            controller.selectRole(role);
          },
          child: AnimatedContainer(
            duration:
                const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(
                      isDark ? 0.18 : 0.10,
                    )
                  : colorScheme.surface,
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? color
                    : colorScheme.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? color.withOpacity(0.20)
                      : isDark
                      ? Colors.black
                          .withOpacity(0.18)
                      : Colors.black
                          .withOpacity(0.05),
                  blurRadius:
                      isSelected ? 12 : 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 250,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color
                        : color.withOpacity(
                            isDark ? 0.22 : 0.15,
                          ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Colors.white
                        : color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? color
                        : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme
                        .onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}