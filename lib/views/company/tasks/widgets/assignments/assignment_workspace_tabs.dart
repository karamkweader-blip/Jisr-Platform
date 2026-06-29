import 'package:flutter/material.dart';
import 'package:jisr_platform/controllers/company/tasks/company_task_assignment_workspace_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class AssignmentWorkspaceTabs extends StatelessWidget {
  final AssignmentWorkspaceTab selectedTab;
  final ValueChanged<AssignmentWorkspaceTab> onSelected;

  const AssignmentWorkspaceTabs({
    super.key,
    required this.selectedTab,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _WorkspaceTabItem(
              label: 'نظرة عامة',
              icon: Icons.dashboard_outlined,
              isSelected:
                  selectedTab == AssignmentWorkspaceTab.overview,
              onTap: () => onSelected(AssignmentWorkspaceTab.overview),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _WorkspaceTabItem(
              label: 'التقدم',
              icon: Icons.timeline_rounded,
              isSelected:
                  selectedTab == AssignmentWorkspaceTab.progress,
              onTap: () => onSelected(AssignmentWorkspaceTab.progress),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceTabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _WorkspaceTabItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primaryBlue
          : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 11,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : AppColors.textGrey,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppColors.textGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}