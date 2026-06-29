import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class AssignmentStatusChip extends StatelessWidget {
  final String status;
  final String label;

  const AssignmentStatusChip({
    super.key,
    required this.status,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _textColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (status) {
      case 'working':
        return AppColors.primaryBlue.withOpacity(0.10);

      case 'submitted':
        return AppColors.actionYellow.withOpacity(0.16);

      case 'completed':
        return Colors.green.withOpacity(0.12);

      default:
        return AppColors.textGrey.withOpacity(0.10);
    }
  }

  Color get _textColor {
    switch (status) {
      case 'working':
        return AppColors.primaryBlue;

      case 'submitted':
        return AppColors.textDark;

      case 'completed':
        return Colors.green.shade700;

      default:
        return AppColors.textGrey;
    }
  }
}