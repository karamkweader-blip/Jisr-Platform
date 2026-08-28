import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class ProfileSectionCard
    extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    return Container(
      padding:
          padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.16)
                : AppColors.primaryBlue
                    .withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: subtitle == null
                  ? FontWeight.w800
                  : FontWeight.w900,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 5),
            Text(
              subtitle!,
              style: TextStyle(
                color: colorScheme
                    .onSurfaceVariant,
                fontSize: 12.8,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ],
          SizedBox(
            height:
                subtitle == null ? 12 : 14,
          ),
          ...children,
        ],
      ),
    );
  }
}