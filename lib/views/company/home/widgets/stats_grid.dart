import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/company_home_model.dart';

class StatsGrid extends StatelessWidget {
  final CompanyHomeStats stats;

  final VoidCallback
  onActiveOpportunitiesPressed;

  final VoidCallback
  onNewApplicantsPressed;

  final VoidCallback
  onPendingReviewsPressed;

  final VoidCallback
  onActiveAssignmentsPressed;

  const StatsGrid({
    super.key,
    required this.stats,
    required this.onActiveOpportunitiesPressed,
    required this.onNewApplicantsPressed,
    required this.onPendingReviewsPressed,
    required this.onActiveAssignmentsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
       _StatCard(
  title: 'المهام المنشورة',
  value: stats.activeOpportunitiesCount,
  icon: Icons.task_alt_rounded,
  onTap: onActiveOpportunitiesPressed,
),

        _StatCard(
          title: 'المتقدمون الجدد',
          value: stats.newApplicantsCount,
          icon:
              Icons.person_add_alt_1_rounded,
          onTap: onNewApplicantsPressed,
        ),
        _StatCard(
          title: 'بانتظار التقييم',
          value: stats.pendingReviewsCount,
          icon: Icons.rate_review_outlined,
          onTap: onPendingReviewsPressed,
        ),
        _StatCard(
          title: 'المهام الجارية',
          value:
              stats.activeAssignmentsCount,
          icon:
              Icons.play_circle_outline_rounded,
          onTap: onActiveAssignmentsPressed,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final borderRadius =
        BorderRadius.circular(18);

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: borderRadius,
            border: Border.all(
              color:
                  colorScheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black
                        .withOpacity(0.18)
                    : AppColors.primaryBlue
                        .withOpacity(0.045),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue
                      .withOpacity(
                        isDark
                            ? 0.18
                            : 0.08,
                      ),
                  borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                ),
                child: Icon(
                  icon,
                  color:
                      AppColors.primaryBlue,
                  size: 19,
                ),
              ),
              const Spacer(),
              Text(
                value.toString(),
                style: TextStyle(
                  color:
                      colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight:
                      FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme
                            .onSurfaceVariant,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons
                        .arrow_back_ios_new_rounded,
                    color: colorScheme
                        .onSurfaceVariant,
                    size: 11,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}