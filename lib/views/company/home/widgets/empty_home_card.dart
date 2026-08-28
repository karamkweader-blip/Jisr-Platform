import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class EmptyHomeCard extends StatelessWidget {
  final VoidCallback onPressed;

  const EmptyHomeCard({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue
                  .withOpacity(
                    isDark ? 0.18 : 0.08,
                  ),
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.add_task_rounded,
              color: AppColors.primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'لا يوجد نشاط بعد',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بنشر أول مهمة حتى يتمكن الطلاب المناسبون من التقديم عليها.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  colorScheme.onSurfaceVariant,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              child: const Text(
                'إنشاء مهمة جديدة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}