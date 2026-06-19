import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_progress_model.dart';
import 'package:jisr_platform/views/company/tasks/widgets/assignments/assignment_status_chip.dart';
import 'package:jisr_platform/views/company/tasks/widgets/assignments/progress_update_card.dart';

class AssignmentProgressTimeline extends StatelessWidget {
  final CompanyTaskAssignmentProgressModel? progressData;
  final bool isLoading;
  final String errorMessage;
  final String Function(String status) statusLabel;
  final String Function(DateTime? date) formatDate;
  final String Function(DateTime? date) formatDateTime;
  final VoidCallback onRetry;

  const AssignmentProgressTimeline({
    super.key,
    required this.progressData,
    required this.isLoading,
    required this.errorMessage,
    required this.statusLabel,
    required this.formatDate,
    required this.formatDateTime,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && progressData == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 42),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryBlue,
          ),
        ),
      );
    }

    if (errorMessage.isNotEmpty && progressData == null) {
      return _ProgressErrorState(
        message: errorMessage,
        onRetry: onRetry,
      );
    }

    if (progressData == null) {
      return const SizedBox.shrink();
    }

    final assignment = progressData!.assignment;
    final updates = progressData!.progressUpdates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProgressSummaryCard(
          taskTitle: assignment.task.title,
          studentName: assignment.student.name,
          status: assignment.status,
          statusText: statusLabel(assignment.status),
          deadlineText: formatDate(assignment.task.deadline),
          latestPercentage: progressData!.latestProgressPercentage,
          latestUpdateDate: progressData!.latestProgressUpdate?.createdAt,
          formatDateTime: formatDateTime,
        ),
        const SizedBox(height: 22),
        const Text(
          'سجل تحديثات التقدم',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        if (updates.isEmpty)
          const _ProgressEmptyState()
        else
          ...List.generate(updates.length, (index) {
            final update = updates[index];
            final isLast = index == updates.length - 1;

            return _TimelineItem(
              isLast: isLast,
              child: ProgressUpdateCard(
                update: update,
                createdAtText: formatDateTime(update.createdAt),
              ),
            );
          }),
      ],
    );
  }
}

class _ProgressSummaryCard extends StatelessWidget {
  final String taskTitle;
  final String studentName;
  final String status;
  final String statusText;
  final String deadlineText;
  final int latestPercentage;
  final DateTime? latestUpdateDate;
  final String Function(DateTime? date) formatDateTime;

  const _ProgressSummaryCard({
    required this.taskTitle,
    required this.studentName,
    required this.status,
    required this.statusText,
    required this.deadlineText,
    required this.latestPercentage,
    required this.latestUpdateDate,
    required this.formatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _ProgressCircle(percentage: latestPercentage),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        taskTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AssignmentStatusChip(
                      status: status,
                      label: statusText,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'الطالب: $studentName',
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'الموعد النهائي: $deadlineText',
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  latestUpdateDate == null
                      ? 'لا يوجد تحديث تقدم حتى الآن'
                      : 'آخر تحديث: ${formatDateTime(latestUpdateDate)}',
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 10.5,
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

class _ProgressCircle extends StatelessWidget {
  final int percentage;

  const _ProgressCircle({
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final safePercentage = percentage.clamp(0, 100).toInt();

    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: CircularProgressIndicator(
              value: safePercentage / 100,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              color: AppColors.primaryBlue,
              backgroundColor: AppColors.primaryBlue.withOpacity(0.10),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$safePercentage%',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'التقدم',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final bool isLast;
  final Widget child;

  const _TimelineItem({
    required this.isLast,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      color: AppColors.primaryBlue.withOpacity(0.18),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressEmptyState extends StatelessWidget {
  const _ProgressEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.timeline_outlined,
            color: AppColors.primaryBlue,
            size: 45,
          ),
          SizedBox(height: 12),
          Text(
            'لا توجد تحديثات تقدم حتى الآن',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'عند إرسال الطالب تحديثاً جديداً سيظهر هنا ضمن سجل التقدم.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 11.5,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProgressErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: 42,
          ),
          const SizedBox(height: 10),
          const Text(
            'تعذر تحميل التقدم',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 11.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}