import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/market_analysis/market_analysis_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/models/student/market_analysis/market_analysis_models.dart';

class MarketAnalysisView extends GetView<MarketAnalysisController> {
  final bool isCompanyMode;

  const MarketAnalysisView({
    super.key,
    this.isCompanyMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final listBottomPadding = isCompanyMode ? 32.0 : 96.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: isCompanyMode
            ? null
            : const StudentBottomNav(currentIndex: 2),
        body: SafeArea(
          child: GetBuilder<MarketAnalysisController>(
            builder: (_) {
              return RefreshIndicator(
                color: AppColors.actionYellow,
                onRefresh: controller.refreshAll,
                child: CustomScrollView(
                  controller: controller.scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _MarketHeader(
                        isCompanyMode: isCompanyMode,
                      ),
                    ),
                    if (controller.isLoadingPaths)
                      const SliverFillRemaining(
                        child: _MarketLoading(),
                      )
                    else if (controller.errorMessage != null &&
                        controller.careerPaths.isEmpty)
                      SliverFillRemaining(
                        child: _MarketError(
                          message: controller.errorMessage!,
                          onRetry: controller.fetchCareerPaths,
                        ),
                      )
                    else if (controller.careerPaths.isEmpty)
                      const SliverFillRemaining(
                        child: _MarketEmpty(
                          message:
                              'لا توجد بيانات سوق عمل جاهزة حالياً.',
                        ),
                      )
                    else ...[
                      SliverToBoxAdapter(
                        child: _CareerPathSelector(
                          controller: controller,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _MarketSummary(
                          controller: controller,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _MarketTabs(
                          controller: controller,
                        ),
                      ),
                      if (controller.isLoadingInsights)
                        const SliverFillRemaining(
                          child: _MarketLoading(),
                        )
                      else if (controller.selectedSection == 'trends')
                        _TrendsList(
                          controller: controller,
                          bottomPadding: listBottomPadding,
                        )
                      else if (controller.selectedSection == 'categories')
                        _CategoriesList(
                          controller: controller,
                          bottomPadding: listBottomPadding,
                        )
                      else
                        _DemandSkillsList(
                          controller: controller,
                          bottomPadding: listBottomPadding,
                        ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MarketHeader extends StatelessWidget {
  final bool isCompanyMode;

  const _MarketHeader({
    required this.isCompanyMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(.22),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            PositionedDirectional(
              end: -22,
              top: -20,
              child: _GlowCircle(
                size: 100,
                color: Colors.white.withOpacity(.10),
              ),
            ),
            PositionedDirectional(
              start: -18,
              bottom: -28,
              child: _GlowCircle(
                size: 80,
                color: AppColors.actionYellow.withOpacity(.20),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: Get.back,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.14),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(.18),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تحليل سوق العمل',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isCompanyMode
                                ? 'اكتشف المهارات المطلوبة قبل إنشاء فرصك وتحديد متطلباتها'
                                : 'اعرف المهارات المطلوبة فعلياً في الوظائف',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.analytics_rounded,
                        color: Colors.white,
                        size: 31,
                      ),
                    )
                        .animate(
                          onPlay: (controller) {
                            controller.repeat(reverse: true);
                          },
                        )
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.06, 1.06),
                          duration: 1600.ms,
                        ),
                  ],
                ),
                const SizedBox(height: 18),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeaderChip(label: 'طلب المهارات'),
                    _HeaderChip(label: 'اتجاهات السوق'),
                    _HeaderChip(label: 'أدلة من الوظائف'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(
            duration: 520.ms,
          ).slideY(
            begin: .18,
          ),
    );
  }
}

class _CareerPathSelector extends StatelessWidget {
  final MarketAnalysisController controller;

  const _CareerPathSelector({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'اختر المسار المهني',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.careerPaths.length,
              separatorBuilder: (_, __) {
                return const SizedBox(width: 10);
              },
              itemBuilder: (context, index) {
                final path = controller.careerPaths[index];
                final active =
                    controller.selectedCareerPath?.id == path.id;

                return _CareerPathCard(
                  path: path,
                  isActive: active,
                  onTap: () {
                    controller.selectCareerPath(path);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CareerPathCard extends StatelessWidget {
  final MarketCareerPath path;
  final bool isActive;
  final VoidCallback onTap;

  const _CareerPathCard({
    required this.path,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 250,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryBlue
              : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive
                ? AppColors.primaryBlue
                : AppColors.primaryBlue.withOpacity(.08),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(.08),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withOpacity(.16)
                    : AppColors.primaryBlue.withOpacity(.09),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(
                Icons.route_rounded,
                color: isActive
                    ? Colors.white
                    : AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    path.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: isActive
                          ? Colors.white
                          : AppColors.primaryBlue,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${path.totalJobPostings} إعلان · '
                    '${path.latestSnapshotDate.isEmpty ? 'بدون تاريخ' : path.latestSnapshotDate}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: isActive
                          ? Colors.white70
                          : AppColors.textGrey,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketSummary extends StatelessWidget {
  final MarketAnalysisController controller;

  const _MarketSummary({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Row(
        children: [
          Expanded(
            child: _SummaryBox(
              label: 'إعلانات',
              value: '${controller.totalJobPostings}',
              icon: Icons.work_rounded,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryBox(
              label: 'مهارات',
              value: '${controller.skills.length}',
              icon: Icons.psychology_rounded,
              color: AppColors.actionYellow,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryBox(
              label: 'أساسية',
              value: '${controller.coreSkillsCount}',
              icon: Icons.star_rounded,
              color: const Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withOpacity(.12),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textGrey,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketTabs extends StatelessWidget {
  final MarketAnalysisController controller;

  const _MarketTabs({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = [
      _MarketTabData(
        'demand',
        'الطلب',
        Icons.bar_chart_rounded,
      ),
      _MarketTabData(
        'trends',
        'الاتجاهات',
        Icons.trending_up_rounded,
      ),
      _MarketTabData(
        'categories',
        'التصنيفات',
        Icons.category_rounded,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryBlue.withOpacity(.08),
          ),
        ),
        child: Row(
          children: tabs.map((tab) {
            final active =
                controller.selectedSection == tab.key;

            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  controller.changeSection(tab.key);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primaryBlue
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab.icon,
                        color: active
                            ? Colors.white
                            : AppColors.textGrey,
                        size: 17,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          tab.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: active
                                ? Colors.white
                                : AppColors.textGrey,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _DemandSkillsList extends StatelessWidget {
  final MarketAnalysisController controller;
  final double bottomPadding;

  const _DemandSkillsList({
    required this.controller,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.skills.isEmpty) {
      return const SliverFillRemaining(
        child: _MarketEmpty(
          message:
              'لا توجد مهارات مكتشفة لهذا المسار حالياً.',
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        18,
        0,
        18,
        bottomPadding,
      ),
      sliver: SliverList.separated(
        itemCount: controller.skills.length,
        separatorBuilder: (_, __) {
          return const SizedBox(height: 12);
        },
        itemBuilder: (context, index) {
          final skill = controller.skills[index];

          return _DemandSkillCard(
            skill: skill,
            controller: controller,
            onTap: () {
              _showEvidenceSheet(
                context,
                controller,
                skill,
              );
            },
          )
              .animate()
              .fadeIn(
                delay: Duration(
                  milliseconds: 55 * (index % 6),
                ),
                duration: 420.ms,
              )
              .slideY(
                begin: .12,
                curve: Curves.easeOutCubic,
              );
        },
      ),
    );
  }
}

class _DemandSkillCard extends StatelessWidget {
  final MarketDemandSkill skill;
  final MarketAnalysisController controller;
  final VoidCallback onTap;

  const _DemandSkillCard({
    required this.skill,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = controller.demandColor(
      skill.demandLevel,
    );

    final percent = skill.demandPercentage
        .clamp(0, 100)
        .toDouble();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withOpacity(.14),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(.055),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withOpacity(.10),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(
                    Icons.bolt_rounded,
                    color: color,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        skill.skillName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.primaryBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        skill.skillCategory,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textGrey,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _MiniBadge(
                  text: controller.demandLevelArabic(
                    skill.demandLevel,
                  ),
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: percent / 100,
                      minHeight: 10,
                      backgroundColor: color.withOpacity(.09),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${percent.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.work_outline_rounded,
                  size: 16,
                  color: AppColors.textGrey,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'ظهرت في ${skill.jobPostingCount} إعلان',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'عرض الدليل',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.open_in_new_rounded,
                  size: 15,
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendsList extends StatelessWidget {
  final MarketAnalysisController controller;
  final double bottomPadding;

  const _TrendsList({
    required this.controller,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.trends.isEmpty) {
      return const SliverFillRemaining(
        child: _MarketEmpty(
          message:
              'لا توجد اتجاهات محفوظة لهذا المسار حالياً.',
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        18,
        0,
        18,
        bottomPadding,
      ),
      sliver: SliverList.separated(
        itemCount: controller.trends.length,
        separatorBuilder: (_, __) {
          return const SizedBox(height: 12);
        },
        itemBuilder: (context, index) {
          final trend = controller.trends[index];

          final color = controller.trendColor(
            trend.trendDirection,
          );

          final percent = trend.demandScore
              .clamp(0, 100)
              .toDouble();

          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: color.withOpacity(.12),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      AppColors.primaryBlue.withOpacity(.055),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _trendIcon(trend.trendDirection),
                    color: color,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        trend.skillName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.primaryBlue,
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${trend.skillCategory} · '
                        '${trend.sourceJobCount} إعلان',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textGrey,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _MiniBadge(
                      text: controller.trendArabic(
                        trend.trendDirection,
                      ),
                      color: color,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${percent.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(
                delay: Duration(
                  milliseconds: 55 * (index % 6),
                ),
                duration: 420.ms,
              )
              .slideY(
                begin: .12,
                curve: Curves.easeOutCubic,
              );
        },
      ),
    );
  }
}

class _CategoriesList extends StatelessWidget {
  final MarketAnalysisController controller;
  final double bottomPadding;

  const _CategoriesList({
    required this.controller,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    final map = controller.demandResponse?.skillMap ??
        <String, List<MarketDemandSkill>>{};

    final entries = map.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList();

    if (entries.isEmpty) {
      return const SliverFillRemaining(
        child: _MarketEmpty(
          message:
              'لا توجد تصنيفات مهارات لهذا المسار حالياً.',
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        18,
        0,
        18,
        bottomPadding,
      ),
      sliver: SliverList.separated(
        itemCount: entries.length,
        separatorBuilder: (_, __) {
          return const SizedBox(height: 12);
        },
        itemBuilder: (context, index) {
          final entry = entries[index];
          final categorySkills = entry.value;

          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(.08),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      AppColors.primaryBlue.withOpacity(.055),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue
                            .withOpacity(.09),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.category_rounded,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.primaryBlue,
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _MiniBadge(
                      text: '${categorySkills.length} مهارة',
                      color: AppColors.actionYellow,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categorySkills.map((skill) {
                    final color = controller.demandColor(
                      skill.demandLevel,
                    );

                    return InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        _showEvidenceSheet(
                          context,
                          controller,
                          skill,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(.09),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: color.withOpacity(.14),
                          ),
                        ),
                        child: Text(
                          '${skill.skillName} '
                          '${skill.demandPercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: color,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(
                delay: Duration(
                  milliseconds: 55 * (index % 6),
                ),
                duration: 420.ms,
              )
              .slideY(
                begin: .12,
                curve: Curves.easeOutCubic,
              );
        },
      ),
    );
  }
}

void _showEvidenceSheet(
  BuildContext context,
  MarketAnalysisController controller,
  MarketDemandSkill skill,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: MediaQuery.of(context).size.height * .82,
          padding: const EdgeInsets.fromLTRB(
            18,
            14,
            18,
            20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: FutureBuilder<MarketSkillEvidenceResponse?>(
            future: controller.loadEvidence(skill),
            builder: (context, snapshot) {
              final response = snapshot.data;

              final evidence =
                  response?.evidence ?? <MarketSkillEvidence>[];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color:
                            AppColors.textGrey.withOpacity(.24),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.actionYellow
                              .withOpacity(.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.fact_check_rounded,
                          color: AppColors.actionYellow,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أدلة ظهور ${skill.skillName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                color: AppColors.primaryBlue,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'من إعلانات الوظائف المحللة',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                color: AppColors.textGrey,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'إغلاق',
                        onPressed: Get.back,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (snapshot.connectionState ==
                      ConnectionState.waiting)
                    const Expanded(
                      child: _MarketLoading(),
                    )
                  else if (evidence.isEmpty)
                    const Expanded(
                      child: _MarketEmpty(
                        message:
                            'لا توجد أدلة تفصيلية لهذه المهارة حالياً.',
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        physics:
                            const BouncingScrollPhysics(),
                        itemCount: evidence.length,
                        separatorBuilder: (_, __) {
                          return const SizedBox(height: 12);
                        },
                        itemBuilder: (context, index) {
                          final item = evidence[index];

                          return _EvidenceCard(
                            item: item,
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

class _EvidenceCard extends StatelessWidget {
  final MarketSkillEvidence item;

  const _EvidenceCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final job = item.jobPosting;
    final evidence = item.evidence;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.business_center_rounded,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  job.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryBlue,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (job.companyName.isNotEmpty ||
              job.location.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${job.companyName.isEmpty ? 'شركة غير محددة' : job.companyName}'
              '${job.location.isEmpty ? '' : ' · ${job.location}'}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              evidence.context.isEmpty
                  ? evidence.matchedText
                  : evidence.context,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textDark,
                height: 1.55,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (evidence.alias.isNotEmpty)
                _MiniBadge(
                  text: evidence.alias,
                  color: AppColors.actionYellow,
                ),
              if (evidence.extractionMethod.isNotEmpty)
                _MiniBadge(
                  text: evidence.extractionMethod,
                  color: AppColors.primaryBlue,
                ),
              _MiniBadge(
                text: 'ثقة '
                    '${((evidence.confidence.clamp(0, 1)) * 100).toStringAsFixed(0)}%',
                color: const Color(0xFF16A34A),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String label;

  const _HeaderChip({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.13),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Colors.white.withOpacity(.16),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Cairo',
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _MiniBadge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: color.withOpacity(.16),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Cairo',
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MarketLoading extends StatelessWidget {
  const _MarketLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.actionYellow,
          ),
          const SizedBox(height: 14),
          Text(
            'جارٍ تحليل بيانات سوق العمل...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textGrey.withOpacity(.85),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketEmpty extends StatelessWidget {
  final String message;

  const _MarketEmpty({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color:
                    AppColors.actionYellow.withOpacity(.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: AppColors.actionYellow,
                size: 38,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
                height: 1.55,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _MarketError({
    required this.message,
    required this.onRetry,
  });

  String get _safeMessage {
    final lower = message.toLowerCase();

    final containsTechnicalDetails =
        lower.contains('market_job_postings') ||
            lower.contains('base table or view not found') ||
            lower.contains('sqlstate') ||
            lower.contains('route') ||
            lower.contains('could not be found') ||
            lower.contains('exception');

    if (containsTechnicalDetails) {
      return 'بيانات سوق العمل غير متاحة حاليًا. '
          'يرجى المحاولة مرة أخرى لاحقًا.';
    }

    if (message.length > 180) {
      return 'تعذر تحميل بيانات سوق العمل. '
          'تحقق من الاتصال ثم أعد المحاولة.';
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626)
                            .withOpacity(.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.wifi_off_rounded,
                        size: 38,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _safeMessage,
                      textAlign: TextAlign.center,
                      maxLines: 8,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textGrey,
                        height: 1.55,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),
                      label: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor:
                            AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _MarketTabData {
  final String key;
  final String title;
  final IconData icon;

  const _MarketTabData(
    this.key,
    this.title,
    this.icon,
  );
}

IconData _trendIcon(String value) {
  switch (value.toLowerCase().trim()) {
    case 'rising':
      return Icons.trending_up_rounded;
    case 'falling':
      return Icons.trending_down_rounded;
    case 'stable':
      return Icons.trending_flat_rounded;
    case 'new':
    default:
      return Icons.fiber_new_rounded;
  }
}
