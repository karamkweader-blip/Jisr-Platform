import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/tasks/company_task_assignments_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/views/company/tasks/widgets/assignments/task_assignment_card.dart';

class CompanyTaskAssignmentsView
    extends GetView<CompanyTaskAssignmentsController> {
  const CompanyTaskAssignmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Obx(() {
            final visibleAssignments = controller.visibleAssignments;

            if (controller.isLoading.value &&
                controller.assignments.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryBlue,
                ),
              );
            }

            if (controller.errorMessage.value.isNotEmpty &&
                controller.assignments.isEmpty) {
              return _AssignmentsError(
                message: controller.errorMessage.value,
                onRetry: controller.fetchAssignments,
              );
            }

            return RefreshIndicator(
              color: AppColors.primaryBlue,
              onRefresh: controller.refreshAssignments,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: [
                  const _AssignmentsTopBar(),
                  const SizedBox(height: 18),
                  _AssignmentsSummaryCard(
                    totalAssignments: controller.assignments.length,
                    workingAssignments: controller.countForStatus('working'),
                    submittedAssignments:
                        controller.countForStatus('submitted'),
                  ),
                  const SizedBox(height: 20),
                  _AssignmentsFilters(
                    selectedStatus: controller.selectedStatus.value,
                    onSelected: controller.selectStatus,
                    allCount: controller.countForStatus('all'),
                    workingCount: controller.countForStatus('working'),
                    submittedCount:
                        controller.countForStatus('submitted'),
                    completedCount:
                        controller.countForStatus('completed'),
                  ),
                  if (controller.errorMessage.value.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _InlineErrorBanner(
                      message: controller.errorMessage.value,
                      onRetry: controller.refreshAssignments,
                    ),
                  ],
                  const SizedBox(height: 18),
                  if (visibleAssignments.isEmpty)
                    const _AssignmentsEmpty()
                  else
                    ...visibleAssignments.map(
                      (assignment) => TaskAssignmentCard(
                        assignment: assignment,
                        statusLabel: controller.assignmentStatusLabel(
                          assignment.status,
                        ),
                        difficultyLabel: controller.difficultyLabel(
                          assignment.task.difficultyLevel,
                        ),
                        deadlineText: controller.formatDate(
                          assignment.task.deadline,
                        ),
                        deadlineHint: controller.deadlineHint(
                          assignment.task.deadline,
                        ),
                        startedAtText: controller.formatDate(
                          assignment.startedAt,
                        ),
                        onOpenWorkspacePressed: () {
  controller.goToAssignmentWorkspace(assignment);
},
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _AssignmentsTopBar extends StatelessWidget {
  const _AssignmentsTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: Get.back,
            borderRadius: BorderRadius.circular(16),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المهام قيد المتابعة',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'تابع الطلاب الذين تم قبولهم في مهام شركتك',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AssignmentsSummaryCard extends StatelessWidget {
  final int totalAssignments;
  final int workingAssignments;
  final int submittedAssignments;

  const _AssignmentsSummaryCard({
    required this.totalAssignments,
    required this.workingAssignments,
    required this.submittedAssignments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.cardWhite.withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.track_changes_rounded,
              color: AppColors.cardWhite,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalAssignments تكليف نشط',
                  style: const TextStyle(
                    color: AppColors.cardWhite,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$workingAssignments قيد التنفيذ · $submittedAssignments بانتظار المراجعة',
                  style: TextStyle(
                    color: AppColors.cardWhite.withOpacity(0.84),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentsFilters extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onSelected;
  final int allCount;
  final int workingCount;
  final int submittedCount;
  final int completedCount;

  const _AssignmentsFilters({
    required this.selectedStatus,
    required this.onSelected,
    required this.allCount,
    required this.workingCount,
    required this.submittedCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      ('all', 'الكل', allCount),
      ('working', 'قيد التنفيذ', workingCount),
      ('submitted', 'بانتظار المراجعة', submittedCount),
      ('completed', 'مكتملة', completedCount),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filters.map((filter) {
        final isSelected = selectedStatus == filter.$1;

        return ChoiceChip(
          label: Text('${filter.$2} (${filter.$3})'),
          selected: isSelected,
          onSelected: (_) => onSelected(filter.$1),
          selectedColor: AppColors.primaryBlue.withOpacity(0.14),
          backgroundColor: AppColors.cardWhite,
          side: BorderSide(
            color: isSelected
                ? AppColors.primaryBlue.withOpacity(0.40)
                : AppColors.textGrey.withOpacity(0.14),
          ),
          labelStyle: TextStyle(
            color: isSelected
                ? AppColors.primaryBlue
                : AppColors.textGrey,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        );
      }).toList(),
    );
  }
}

class _AssignmentsEmpty extends StatelessWidget {
  const _AssignmentsEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 48,
            color: AppColors.primaryBlue,
          ),
          SizedBox(height: 13),
          Text(
            'لا توجد مهام ضمن هذا القسم',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'عند قبول طالب وبدء تنفيذ المهمة ستظهر هنا لمتابعة تقدمه.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InlineErrorBanner({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: onRetry,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _AssignmentsError({
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
                color: Colors.red,
                size: 46,
              ),
              const SizedBox(height: 12),
              const Text(
                'تعذر تحميل التكليفات',
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