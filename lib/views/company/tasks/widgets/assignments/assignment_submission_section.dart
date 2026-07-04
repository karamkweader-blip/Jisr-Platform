import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_submission_model.dart';

class AssignmentSubmissionSection extends StatelessWidget {
  final CompanyTaskAssignmentSubmissionModel? submission;
  final bool isLoading;
  final String errorMessage;
  final String Function(String) statusLabel;
  final String Function(String) submissionTypeLabel;
  final String Function(DateTime?) formatDateTime;
  final ValueChanged<String> onOpenLink;
  final VoidCallback onRetry;

  const AssignmentSubmissionSection({
    super.key,
    required this.submission,
    required this.isLoading,
    required this.errorMessage,
    required this.statusLabel,
    required this.submissionTypeLabel,
    required this.formatDateTime,
    required this.onOpenLink,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && submission == null) {
      return const _SubmissionLoadingState();
    }

    if (errorMessage.isNotEmpty && submission == null) {
      return _SubmissionErrorState(
        message: errorMessage,
        onRetry: onRetry,
      );
    }

    if (submission == null) {
      return const _EmptySubmissionState();
    }

    final finalSubmission = submission!.submission;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'التسليم النهائي',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            _StatusChip(
              label: statusLabel(submission!.status),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _SubmissionSummaryCard(
          submission: submission!,
          submissionTypeLabel: submissionTypeLabel,
          formatDateTime: formatDateTime,
        ),
        const SizedBox(height: 18),

        const Text(
          'الروابط والملفات المرفقة',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),

        if (finalSubmission.hasGithubUrl)
          _SubmissionLinkCard(
            title: 'مستودع GitHub',
         subtitle: 'اضغط لنسخ رابط الكود المرفق',
            icon: Icons.code_rounded,
            onTap: () => onOpenLink(
              finalSubmission.githubUrl!,
            ),
          ),

        if (finalSubmission.hasGithubUrl &&
            (finalSubmission.hasDemoUrl ||
                finalSubmission.hasZipFile))
          const SizedBox(height: 10),

        if (finalSubmission.hasDemoUrl)
          _SubmissionLinkCard(
            title: 'العرض التجريبي',
            subtitle: 'اضغط لنسخ رابط العرض أو النسخة التجريبية',
            icon: Icons.open_in_new_rounded,
            onTap: () => onOpenLink(
              finalSubmission.demoUrl!,
            ),
          ),

        if (finalSubmission.hasDemoUrl &&
            finalSubmission.hasZipFile)
          const SizedBox(height: 10),

        if (finalSubmission.hasZipFile)
          _SubmissionLinkCard(
            title: 'ملف التسليم ZIP',
            subtitle: 'اضغط لنسخ رابط ملف التسليم النهائي',
            icon: Icons.folder_zip_outlined,
            onTap: () => onOpenLink(
              finalSubmission.zipFile!.url,
            ),
          ),

        if (!finalSubmission.hasGithubUrl &&
            !finalSubmission.hasDemoUrl &&
            !finalSubmission.hasZipFile)
          const _NoLinksState(),

        const SizedBox(height: 18),

        const Text(
          'ملاحظات الطالب',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),

        _StudentNotesCard(
          notes: finalSubmission.notes,
        ),
        const SizedBox(height: 18),

        const Text(
          'إحصاءات المهمة',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'الطلاب المقبولون',
                value: submission!.stats.acceptedStudentsCount.toString(),
                icon: Icons.groups_2_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'التسليمات المستلمة',
                value: submission!.stats.submissionsCount.toString(),
                icon: Icons.assignment_turned_in_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SubmissionSummaryCard extends StatelessWidget {
  final CompanyTaskAssignmentSubmissionModel submission;
  final String Function(String) submissionTypeLabel;
  final String Function(DateTime?) formatDateTime;

  const _SubmissionSummaryCard({
    required this.submission,
    required this.submissionTypeLabel,
    required this.formatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.08),
        ),
      ),
      child: Column(
        children: [
          _SummaryRow(
            icon: Icons.person_outline_rounded,
            label: 'الطالب',
            value: submission.student.name,
          ),
          const Divider(height: 24),
          _SummaryRow(
            icon: Icons.assignment_outlined,
            label: 'نوع التسليم',
            value: submissionTypeLabel(
              submission.task.submissionType,
            ),
          ),
          const Divider(height: 24),
          _SummaryRow(
            icon: Icons.schedule_outlined,
            label: 'تاريخ الإرسال',
            value: formatDateTime(submission.submittedAt),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryBlue,
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmissionLinkCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SubmissionLinkCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryBlue,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
  Icons.copy_rounded,
  color: AppColors.primaryBlue,
  size: 20,
),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentNotesCard extends StatelessWidget {
  final String notes;

  const _StudentNotesCard({
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    final hasNotes = notes.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.08),
        ),
      ),
      child: Text(
        hasNotes
            ? notes
            : 'لم يضف الطالب ملاحظات مع التسليم النهائي.',
        style: TextStyle(
          color: hasNotes
              ? AppColors.textDark
              : AppColors.textGrey,
          fontSize: 13,
          height: 1.6,
          fontWeight: hasNotes
              ? FontWeight.w600
              : FontWeight.w500,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 21,
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;

  const _StatusChip({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _NoLinksState extends StatelessWidget {
  const _NoLinksState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.08),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.textGrey,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'لم يرفق الطالب روابطاً أو ملفات إضافية.',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySubmissionState extends StatelessWidget {
  const _EmptySubmissionState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.08),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.assignment_late_outlined,
            color: AppColors.primaryBlue,
            size: 46,
          ),
          SizedBox(height: 14),
          Text(
            'لم يرسل الطالب التسليم النهائي بعد',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'سيظهر هنا ملف التسليم أو الروابط والملاحظات بعد أن يرسل الطالب المهمة.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmissionLoadingState extends StatelessWidget {
  const _SubmissionLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}

class _SubmissionErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SubmissionErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.primaryBlue,
            size: 42,
          ),
          const SizedBox(height: 12),
          const Text(
            'تعذر تحميل التسليم النهائي',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
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
    );
  }
}