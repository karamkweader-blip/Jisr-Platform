import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class TaskDetailsHeaderCard extends StatelessWidget {
  final String title;
  final String statusLabel;
  final String difficultyLabel;
  final String deadline;
  final String deadlineHint;
  final int durationDays;
  final int maxApplicants;
  final int maxAcceptedStudents;
  final bool isDraft;
  final bool isPublishing;
  final VoidCallback onPublishPressed;
  final VoidCallback onApplicantsPressed;

  const TaskDetailsHeaderCard({
    super.key,
    required this.title,
    required this.statusLabel,
    required this.difficultyLabel,
    required this.deadline,
    required this.deadlineHint,
    required this.durationDays,
    required this.maxApplicants,
    required this.maxAcceptedStudents,
    required this.isDraft,
    required this.isPublishing,
    required this.onPublishPressed,
    required this.onApplicantsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusRow(
            statusLabel: statusLabel,
            difficultyLabel: difficultyLabel,
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.cardWhite,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.timer_outlined,
                color: AppColors.cardWhite,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '$deadline · $deadlineHint',
                style: TextStyle(
                  color: AppColors.cardWhite.withOpacity(0.88),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _HeaderStat(
                  value: '$durationDays',
                  label: 'أيام',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderStat(
                  value: '$maxApplicants',
                  label: 'حد المتقدمين',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderStat(
                  value: '$maxAcceptedStudents',
                  label: 'قبول',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isDraft)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isPublishing ? null : onPublishPressed,
                icon: isPublishing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.rocket_launch_outlined),
                label: Text(isPublishing ? 'جاري النشر...' : 'نشر المهمة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.actionYellow,
                  foregroundColor: AppColors.textDark,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onApplicantsPressed,
                icon: const Icon(Icons.groups_2_outlined),
                label: const Text('مراجعة المتقدمين'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.cardWhite,
                  side: BorderSide(
                    color: AppColors.cardWhite.withOpacity(0.55),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String statusLabel;
  final String difficultyLabel;

  const _StatusRow({
    required this.statusLabel,
    required this.difficultyLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Pill(label: statusLabel),
        const SizedBox(width: 8),
        _Pill(label: difficultyLabel),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardWhite.withOpacity(0.16),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.cardWhite.withOpacity(0.28),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.cardWhite,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;

  const _HeaderStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardWhite.withOpacity(0.13),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.cardWhite.withOpacity(0.20),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.cardWhite,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: AppColors.cardWhite.withOpacity(0.80),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}