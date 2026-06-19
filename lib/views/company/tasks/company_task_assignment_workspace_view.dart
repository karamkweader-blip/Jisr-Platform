import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/tasks/company_task_assignment_workspace_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/views/company/tasks/widgets/assignments/assignment_overview_section.dart';
import 'package:jisr_platform/views/company/tasks/widgets/assignments/assignment_progress_timeline.dart';
import 'package:jisr_platform/views/company/tasks/widgets/assignments/assignment_workspace_header.dart';
import 'package:jisr_platform/views/company/tasks/widgets/assignments/assignment_workspace_tabs.dart';

class CompanyTaskAssignmentWorkspaceView
    extends GetView<CompanyTaskAssignmentWorkspaceController> {
  const CompanyTaskAssignmentWorkspaceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Obx(() {
            final details = controller.assignmentDetails.value;

            if (controller.isLoading.value && details == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryBlue,
                ),
              );
            }

            if (controller.errorMessage.value.isNotEmpty &&
                details == null) {
              return _WorkspaceErrorState(
                message: controller.errorMessage.value,
                onRetry: controller.fetchAssignmentDetails,
              );
            }

            if (details == null) {
              return const SizedBox.shrink();
            }

            return RefreshIndicator(
              color: AppColors.primaryBlue,
onRefresh: controller.refreshWorkspace, 
                child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: [
                  AssignmentWorkspaceHeader(
                    details: details,
                    studentName: controller.studentName,
                    studentEmail: controller.studentEmail,
                    studentProfilePictureUrl:
                        controller.studentProfilePictureUrl,
                    statusLabel: controller.assignmentStatusLabel(
                      details.assignment.status,
                    ),
                    deadlineText: controller.formatDate(
                      details.task.deadline,
                    ),
                    startedAtText: controller.formatDate(
                      details.assignment.startedAt,
                    ),
                  ),
                  const SizedBox(height: 20),

AssignmentWorkspaceTabs(
  selectedTab: controller.selectedTab.value,
  onSelected: (tab) {
    controller.changeTab(tab);
  },
),
                  const SizedBox(height: 24),
                 if (controller.selectedTab.value == AssignmentWorkspaceTab.overview) ...[
  const Text(
    'نظرة عامة',
    style: TextStyle(
      color: AppColors.textDark,
      fontSize: 17,
      fontWeight: FontWeight.w900,
    ),
  ),
  const SizedBox(height: 12),
  AssignmentOverviewSection(
    details: details,
    difficultyLabel: controller.difficultyLabel,
    formatDate: controller.formatDate,
  ),
] else ...[
  AssignmentProgressTimeline(
    progressData: controller.assignmentProgress.value,
    isLoading: controller.isProgressLoading.value,
    errorMessage: controller.progressErrorMessage.value,
    statusLabel: controller.assignmentStatusLabel,
    formatDate: controller.formatDate,
    formatDateTime: controller.formatDateTime,
    onRetry: () {
      controller.fetchAssignmentProgress(
        forceRefresh: true,
      );
    },
  ),
],

                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _WorkspaceErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _WorkspaceErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.primaryBlue,
                size: 46,
              ),
              const SizedBox(height: 12),
              const Text(
                'تعذر تحميل مساحة العمل',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}