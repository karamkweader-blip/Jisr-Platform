import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class TasksHeader extends StatelessWidget {
  final VoidCallback onCreatePressed;

  const TasksHeader({
    super.key,
    required this.onCreatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المهام',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'تابع المهام التي أنشأتها أو نشرتها',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onCreatePressed,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
        ),
      ],
    );
  }
}