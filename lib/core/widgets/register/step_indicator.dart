import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class StepIndicator extends StatelessWidget {
  final int current;

  const StepIndicator({
    super.key,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(
        3,
        (index) {
          final bool isActive = current == index;

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 300,
              ),
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 6,
                right: index == 2 ? 0 : 6,
              ),
              height: 10,
              decoration: BoxDecoration(
                gradient: isActive
                    ? AppColors.primaryGradient
                    : null,
                color: isActive
                    ? null
                    : colorScheme.outlineVariant,
                borderRadius:
                    BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}