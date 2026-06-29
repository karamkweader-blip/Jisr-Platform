import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class TaskWorkflowTimeline extends StatelessWidget {
  final int currentIndex;

  const TaskWorkflowTimeline({
    super.key,
    required this.currentIndex,
  });

  static const List<String> _steps = [
    'مسودة',
    'منشورة',
    'طلبات',
    'مراجعة',
    'متابعة',
    'تسليم',
    'تقييم',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          children: List.generate(_steps.length, (index) {
            final isActive = index <= currentIndex;
            final isCurrent = index == currentIndex;

            return Row(
              children: [
                _StepItem(
                  label: _steps[index],
                  isActive: isActive,
                  isCurrent: isCurrent,
                ),
                if (index != _steps.length - 1)
                  Container(
                    width: 34,
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    color: isActive
                        ? AppColors.primaryBlue.withOpacity(0.55)
                        : AppColors.textGrey.withOpacity(0.18),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isCurrent;

  const _StepItem({
    required this.label,
    required this.isActive,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isCurrent ? 34 : 28,
          height: isCurrent ? 34 : 28,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue : AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent
                  ? AppColors.actionYellow
                  : AppColors.primaryBlue.withOpacity(0.16),
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Icon(
            isActive ? Icons.check_rounded : Icons.circle_outlined,
            size: isCurrent ? 18 : 14,
            color: isActive ? AppColors.cardWhite : AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: TextStyle(
            color: isCurrent ? AppColors.primaryBlue : AppColors.textGrey,
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}