import 'package:flutter/material.dart';
import 'package:jisr_platform/controllers/company/tasks/company_tasks_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

import 'package:get/get.dart';
class TaskStatusFilterBar extends StatelessWidget {
  final CompanyTaskStatusFilter selectedFilter;
  final ValueChanged<CompanyTaskStatusFilter> onChanged;

  const TaskStatusFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: CompanyTaskStatusFilter.values.map((filter) {
          final isSelected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Material(
              color: isSelected
                  ? AppColors.primaryBlue
                  : Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => onChanged(filter),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.primaryBlue.withOpacity(0.10),
                    ),
                  ),
                  child: Text(
                    filter.label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Get.theme.colorScheme.onSurfaceVariant,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}