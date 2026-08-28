import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/home/company_home_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

import 'widgets/company_action_cards.dart';
import 'widgets/create_task_card.dart';
import 'widgets/empty_home_card.dart';
import 'widgets/home_header.dart';
import 'widgets/stats_grid.dart';

class CompanyHomeView
    extends GetView<CompanyHomeController> {
  const CompanyHomeView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Obx(
          () {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryBlue,
                ),
              );
            }

            if (controller
                .errorMessage
                .value
                .isNotEmpty) {
              return Center(
                child: RefreshIndicator(
                  onRefresh:
                      controller.fetchCompanyHome,
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color:
                              AppColors.dangerRed,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          controller
                              .errorMessage
                              .value,
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            color:
                                colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller
                              .fetchCompanyHome,
                          child: const Text(
                            'إعادة المحاولة',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final home =
                controller.homeData.value;

            if (home == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryBlue,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh:
                  controller.fetchCompanyHome,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(
                      20,
                      18,
                      20,
                      28,
                    ),
                children: [
                  HomeHeader(
                    home: home,
                  ),
                  const SizedBox(height: 20),
                  StatsGrid(
                    stats: home.stats,
                      onActiveOpportunitiesPressed:
                          controller
                              .onActiveOpportunitiesPressed,
                      onNewApplicantsPressed:
                          controller
                              .onNewApplicantsPressed,
                      onPendingReviewsPressed:
                          controller
                              .onPendingReviewsPressed,
                      onActiveAssignmentsPressed:
                        controller
                            .onActiveAssignmentsPressed,
                  ),
                  const SizedBox(height: 18),
                  CreateTaskCard(
                    onPressed: () {
                      _showCreateSheet(context);
                    },
                  ),
                  if (home
                      .requiredActions
                      .isNotEmpty) ...[
                    const SizedBox(height: 26),
                    const SectionHeader(
                      title: 'إجراءات مطلوبة',
                      subtitle:
                          'أشياء تحتاج مراجعتك الآن',
                    ),
                    const SizedBox(height: 12),
                    ...home.requiredActions.map(
                      (action) => Padding(
                        padding:
                            const EdgeInsets.only(
                              bottom: 12,
                            ),
                        child: RequiredActionCard(
                          action: action,
                          buttonLabel: controller
                              .resolveActionButtonLabel(
                                targetType:
                                    action.targetType,
                                fallbackLabel:
                                    action.actionLabel,
                              ),
                          onPressed: () {
                            controller
                                .onRequiredActionPressed(
                                  action,
                                );
                          },
                        ),
                      ),
                    ),
                  ],
                  if (home
                      .recentActivities
                      .isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const SectionHeader(
                      title: 'آخر النشاطات',
                      subtitle:
                          'آخر ما حدث داخل حساب الشركة',
                    ),
                    const SizedBox(height: 12),
                    ...home.recentActivities.map(
                      (activity) => Padding(
                        padding:
                            const EdgeInsets.only(
                              bottom: 10,
                            ),
                        child: RecentActivityCard(
                          activity: activity,
                          buttonLabel: controller
                              .resolveActionButtonLabel(
                                targetType:
                                    activity
                                        .targetType,
                                fallbackLabel:
                                    activity
                                        .actionLabel,
                              ),
                          onPressed: () {
                            controller
                                .onRecentActivityPressed(
                                  activity,
                                );
                          },
                        ),
                      ),
                    ),
                  ],
                  if (!home.hasAnyActivity) ...[
                    const SizedBox(height: 24),
                    EmptyHomeCard(
                      onPressed: () {
                        _showCreateSheet(context);
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCreateSheet(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorScheme.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    22,
                  ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'ماذا تريد أن تنشئ؟',
                    style: TextStyle(
                      color:
                          colorScheme.onSurface,
                      fontSize: 19,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'اختر المسار المناسب، وسنجهّز لك النموذج المطلوب.',
                    style: TextStyle(
                      color: colorScheme
                          .onSurfaceVariant,
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CreateOption(
                    icon:
                        Icons.task_alt_rounded,
                    title: 'مهمة تطبيقية',
                    subtitle:
                        'عمل تطبيقي محدد يستطيع الطلاب التقديم عليه',
                    onTap: () {
                      Navigator.pop(
                        sheetContext,
                      );

                      controller
                          .onCreateTaskPressed();
                    },
                  ),
                  const SizedBox(height: 10),
                  _CreateOption(
                    icon:
                        Icons.work_outline_rounded,
                    title:
                        'فرصة عمل أو تدريب',
                    subtitle:
                        'انشر وظيفة أو برنامج تدريب وحدّد نوعه داخل النموذج',
                    onTap: () {
                      Navigator.pop(
                        sheetContext,
                      );

                      controller
                          .onCreateOpportunityPressed();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CreateOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CreateOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    return Material(
      color: colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color:
                  colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue
                      .withOpacity(
                        isDark ? 0.18 : 0.09,
                      ),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color:
                      AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colorScheme
                            .onSurface,
                        fontSize: 14.5,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colorScheme
                            .onSurfaceVariant,
                        fontSize: 11.5,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons
                    .arrow_back_ios_new_rounded,
                color:
                    AppColors.primaryBlue,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}