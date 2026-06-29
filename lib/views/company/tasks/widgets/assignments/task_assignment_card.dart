import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_model.dart';
import 'package:jisr_platform/views/company/tasks/widgets/assignments/assignment_match_score_indicator.dart';
import 'package:jisr_platform/views/company/tasks/widgets/assignments/assignment_status_chip.dart';

class TaskAssignmentCard extends StatelessWidget {
  final CompanyTaskAssignmentModel assignment;
  final String statusLabel;
  final String difficultyLabel;
  final String deadlineText;
  final String deadlineHint;
  final String startedAtText;
  final VoidCallback onOpenWorkspacePressed;
  const TaskAssignmentCard({
    super.key,
    required this.assignment,
    required this.statusLabel,
    required this.difficultyLabel,
    required this.deadlineText,
    required this.deadlineHint,
    required this.startedAtText,
    required this.onOpenWorkspacePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StudentAvatar(
                name: assignment.student.name,
                imageUrl: assignment.student.profilePictureUrl,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.student.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assignment.student.email.isEmpty
                          ? 'لا يوجد بريد إلكتروني'
                          : assignment.student.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AssignmentStatusChip(
                status: assignment.status,
                label: statusLabel,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.speed_rounded,
                      label: difficultyLabel,
                    ),
                    _InfoChip(
                      icon: Icons.calendar_month_outlined,
                      label: deadlineText,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              const Icon(
                Icons.play_circle_outline_rounded,
                size: 18,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'بدأ العمل: $startedAtText',
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                deadlineHint,
                style: TextStyle(
                  color: deadlineHint == 'انتهى الموعد'
                      ? Colors.red
                      : AppColors.textGrey,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),

Row(
  children: [
    const Icon(
      Icons.hub_outlined,
      size: 18,
      color: AppColors.primaryBlue,
    ),
    const SizedBox(width: 7),
    const Text(
      'توافق المهارات',
      style: TextStyle(
        color: AppColors.textGrey,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
    const Spacer(),
    AssignmentMatchScoreIndicator(
      score: assignment.matching.score,
      compact: true,
    ),
  ],
),
           const SizedBox(height: 14),
SizedBox(
  width: double.infinity,
  child: TextButton.icon(
    onPressed: onOpenWorkspacePressed,
    icon: const Icon(
      Icons.arrow_back_ios_new_rounded,
      size: 15,
    ),
    label: const Text('فتح مساحة العمل'),
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryBlue,
      backgroundColor: AppColors.primaryBlue.withOpacity(0.07),
      padding: const EdgeInsets.symmetric(vertical: 11),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  ),
),
        ],
      ),
    );
  }
}

class _StudentAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _StudentAvatar({
    required this.name,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter = name.trim().isNotEmpty ? name.trim()[0] : 'ط';

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _InitialAvatar(letter: firstLetter);
          },
        ),
      );
    }

    return _InitialAvatar(letter: firstLetter);
  }
}

class _InitialAvatar extends StatelessWidget {
  final String letter;

  const _InitialAvatar({
    required this.letter,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primaryBlue.withOpacity(0.10),
      child: Text(
        letter,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}