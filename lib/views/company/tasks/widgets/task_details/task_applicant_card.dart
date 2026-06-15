import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/tasks/company_task_application_model.dart';

class TaskApplicantCard extends StatelessWidget {
  final CompanyTaskApplicationModel application;
  final String statusLabel;
  final String appliedAt;
  final VoidCallback onDetailsPressed;

  const TaskApplicantCard({
    super.key,
    required this.application,
    required this.statusLabel,
    required this.appliedAt,
    required this.onDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final score = application.matchScore.round();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          _Avatar(
            name: application.student.name,
            imageUrl: application.student.profilePictureUrl,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application.student.name,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _MiniChip(
                      label: statusLabel,
                      icon: Icons.hourglass_bottom_rounded,
                    ),
                    _MiniChip(
                      label: '$score% تطابق',
                      icon: Icons.bolt_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'مشاريع البورتفوليو: ${application.portfolioProjectsCount} · تاريخ التقديم: $appliedAt',
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              _MatchCircle(score: score),
              const SizedBox(height: 10),
              SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: onDetailsPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.cardWhite,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'التفاصيل',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _Avatar({
    required this.name,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter = name.trim().isNotEmpty ? name.trim()[0] : 'ط';

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(imageUrl!),
      );
    }

    return CircleAvatar(
      radius: 25,
      backgroundColor: AppColors.primaryBlue.withOpacity(0.10),
      child: Text(
        firstLetter,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _MiniChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 13,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchCircle extends StatelessWidget {
  final int score;

  const _MatchCircle({
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final value = (score.clamp(0, 100)) / 100;

    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 4,
            backgroundColor: AppColors.textGrey.withOpacity(0.12),
            color: AppColors.actionYellow,
          ),
          Text(
            '$score',
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}