import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_feed_item.dart';

class OpportunityCard extends StatelessWidget {
  final CompanyOpportunityFeedItem item;
  final VoidCallback onTap;

  const OpportunityCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.045),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.09),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _kindIcon(item.kind),
                      color: AppColors.primaryBlue,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OpportunityStatusChip(
                    label: _statusLabel(item.status),
                    status: item.status,
                  ),
                ],
              ),
              if (item.description.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OpportunityInfoChip(
                    icon: _kindIcon(item.kind),
                    label: _kindLabel(item.kind),
                  ),
                  if (item.meta.trim().isNotEmpty)
                    OpportunityInfoChip(
                      icon: item.kind == CompanyFeedKind.task
                          ? Icons.schedule_rounded
                          : Icons.location_on_outlined,
                      label: item.meta,
                    ),
                  OpportunityInfoChip(
                    icon: Icons.group_outlined,
                    label: item.kind == CompanyFeedKind.task
                        ? 'السعة ${item.applicationsCount}'
                        : '${item.applicationsCount} متقدم',
                  ),
                  if (item.deadline != null)
                    OpportunityInfoChip(
                      icon: Icons.calendar_today_outlined,
                      label: _dateLabel(item.deadline!),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _kindIcon(CompanyFeedKind kind) {
    switch (kind) {
      case CompanyFeedKind.task:
        return Icons.task_alt_rounded;
      case CompanyFeedKind.internship:
        return Icons.school_rounded;
      case CompanyFeedKind.job:
        return Icons.work_rounded;
    }
  }

  static String _kindLabel(CompanyFeedKind kind) {
    switch (kind) {
      case CompanyFeedKind.task:
        return 'مهمة';
      case CompanyFeedKind.internship:
        return 'تدريب';
      case CompanyFeedKind.job:
        return 'وظيفة';
    }
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'مسودة';
      case 'published':
        return 'منشورة';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'closed':
        return 'مغلقة';
      case 'cancelled':
        return 'ملغاة';
      default:
        return status;
    }
  }

  static String _dateLabel(DateTime date) {
    return 'حتى ${date.day}/${date.month}/${date.year}';
  }
}

class OpportunityStatusChip extends StatelessWidget {
  final String label;
  final String status;

  const OpportunityStatusChip({
    super.key,
    required this.label,
    required this.status,
  });

  Color get color {
    switch (status) {
      case 'draft':
        return AppColors.actionYellow;
      case 'published':
        return AppColors.primaryBlue;
      case 'in_progress':
        return Colors.orange;
      case 'closed':
        return Colors.blueGrey;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class OpportunityInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const OpportunityInfoChip({
    super.key,
    required this.icon,
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
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.textGrey,
            size: 15,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OpportunityCreateOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const OpportunityCreateOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryBlue,
                  size: 24,
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
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primaryBlue,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}