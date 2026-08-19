import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_smart_ranking_model.dart';

class CompanyCandidatesModeSelector
    extends StatelessWidget {
  final bool smartRankingSelected;
  final ValueChanged<bool> onChanged;

  const CompanyCandidatesModeSelector({
    super.key,
    required this.smartRankingSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color:
              AppColors.textGrey.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ModeButton(
              selected: smartRankingSelected,
              icon: Icons.auto_awesome_rounded,
              label: 'الترتيب الذكي',
              onTap: () => onChanged(true),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _ModeButton(
              selected: !smartRankingSelected,
              icon: Icons.groups_2_outlined,
              label: 'جميع المتقدمين',
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class CompanySmartRankingOverview
    extends StatelessWidget {
  final CompanyOpportunityRankingMeta meta;

  const CompanySmartRankingOverview({
    super.key,
    required this.meta,
  });

  @override
  Widget build(BuildContext context) {
    final weights = meta.weights;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(23),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color:
                AppColors.primaryBlue.withOpacity(0.14),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color:
                      Colors.white.withOpacity(0.14),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.actionYellow,
                  size: 24,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'أفضل المرشحين لهذه الفرصة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'المعروض حاليًا: ${meta.candidateCount} مرشح',
                      style: const TextStyle(
                        color:
                            AppColors.onPrimaryMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color:
                      Colors.white.withOpacity(0.13),
                  borderRadius:
                      BorderRadius.circular(30),
                ),
                child: Text(
                  meta.scoreScale,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: <Widget>[
              _WeightChip(
                label: 'المهارات',
                weight: weights.skills,
              ),
              _WeightChip(
                label: 'المشاريع',
                weight: weights.projects,
              ),
              _WeightChip(
                label: 'الوسوم',
                weight: weights.tags,
              ),
              _WeightChip(
                label: 'النشاط',
                weight: weights.activity,
              ),
              _WeightChip(
                label: 'الحداثة',
                weight: weights.freshness,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CompanySmartRankingCard
    extends StatelessWidget {
  final CompanyOpportunityRankedCandidate candidate;
  final VoidCallback onTap;

  const CompanySmartRankingCard({
    super.key,
    required this.candidate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardWhite,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: candidate.rank == 1
                  ? AppColors.actionYellow
                      .withOpacity(0.30)
                  : AppColors.textGrey
                      .withOpacity(0.10),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primaryBlue
                    .withOpacity(0.04),
                blurRadius: 17,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: <Widget>[
                  _RankBadge(
                    rank: candidate.rank,
                  ),
                  const SizedBox(width: 10),
                  _StudentAvatar(
                    name: candidate.student.name,
                    imageUrl: candidate
                        .student.profilePictureUrl,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          candidate.student.name,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 14.5,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                        if (candidate.student.email
                            .isNotEmpty) ...<Widget>[
                          const SizedBox(height: 4),
                          Text(
                            candidate.student.email,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            textDirection:
                                TextDirection.ltr,
                            style: const TextStyle(
                              color:
                                  AppColors.textGrey,
                              fontSize: 10.5,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FinalScoreBadge(
                    score:
                        candidate.scores.finalScore,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _SmallScoreItem(
                      label: 'المهارات',
                      score:
                          candidate.scores.skillScore,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SmallScoreItem(
                      label: 'المشاريع',
                      score:
                          candidate.scores.projectScore,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SmallScoreItem(
                      label: 'الوسوم',
                      score:
                          candidate.scores.tagScore,
                    ),
                  ),
                ],
              ),
              if (candidate
                  .hasMissingMandatorySkills) ...<Widget>[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed
                        .withOpacity(0.06),
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.dangerRed
                          .withOpacity(0.13),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.dangerRed,
                        size: 17,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'مهارات إلزامية ناقصة: '
                          '${candidate.metrics.missingMandatorySkills.join('، ')}',
                          style: const TextStyle(
                            color:
                                AppColors.dangerRed,
                            fontSize: 10.5,
                            height: 1.4,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 13),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.checklist_rounded,
                    color: AppColors.primaryBlue
                        .withOpacity(0.80),
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      '${candidate.metrics.matchedSkillsCount} من '
                      '${candidate.metrics.totalSkillsCount} مهارة متطابقة',
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Text(
                    'تحليل النتيجة',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.primaryBlue,
                    size: 16,
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

Future<void> showCompanySmartRankingDetails({
  required BuildContext context,
  required CompanyOpportunityRankedCandidate
      candidate,
  required CompanyOpportunityRankingWeights weights,
  required VoidCallback onOpenCandidate,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: AppColors.cardWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(28),
      ),
    ),
    builder: (sheetContext) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.84,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (
            context,
            scrollController,
          ) {
            return ListView(
              controller: scrollController,
              physics:
                  const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                9,
                20,
                26,
              ),
              children: <Widget>[
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textGrey
                          .withOpacity(0.22),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    _RankBadge(
                      rank: candidate.rank,
                      large: true,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            candidate.student.name,
                            style: const TextStyle(
                              color:
                                  AppColors.textDark,
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                          if (candidate.student.email
                              .isNotEmpty) ...<Widget>[
                            const SizedBox(height: 4),
                            Text(
                              candidate.student.email,
                              textDirection:
                                  TextDirection.ltr,
                              style:
                                  const TextStyle(
                                color: AppColors
                                    .textGrey,
                                fontSize: 11.5,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _FinalScoreBadge(
                      score:
                          candidate.scores.finalScore,
                      large: true,
                    ),
                    IconButton(
                      tooltip: 'إغلاق',
                      onPressed: () {
                        Navigator.of(
                          sheetContext,
                        ).pop();
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                      color: AppColors.textGrey,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _DetailsSection(
                  icon: Icons.analytics_outlined,
                  title: 'تفصيل النتيجة الذكية',
                  child: Column(
                    children: <Widget>[
                      _ScoreProgressRow(
                        label: 'المهارات',
                        score: candidate
                            .scores.skillScore,
                        weight: weights.skills,
                      ),
                      _ScoreProgressRow(
                        label: 'المشاريع',
                        score: candidate
                            .scores.projectScore,
                        weight: weights.projects,
                      ),
                      _ScoreProgressRow(
                        label: 'الوسوم',
                        score:
                            candidate.scores.tagScore,
                        weight: weights.tags,
                      ),
                      _ScoreProgressRow(
                        label: 'النشاط',
                        score: candidate
                            .scores.activityScore,
                        weight: weights.activity,
                      ),
                      _ScoreProgressRow(
                        label: 'حداثة الحساب',
                        score: candidate
                            .scores.freshnessScore,
                        weight: weights.freshness,
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 13),
                _DetailsSection(
                  icon: Icons.insights_rounded,
                  title: 'مؤشرات المطابقة',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _MetricChip(
                        icon:
                            Icons.check_circle_outline,
                        label:
                            '${candidate.metrics.matchedSkillsCount} مهارة متطابقة',
                      ),
                      _MetricChip(
                        icon: Icons
                            .change_circle_outlined,
                        label:
                            '${candidate.metrics.partiallyMatchedSkillsCount} مطابقة جزئية',
                      ),
                      _MetricChip(
                        icon:
                            Icons.workspace_premium_outlined,
                        label:
                            '${candidate.metrics.projectEvaluationsCount} تقييم مشاريع',
                      ),
                      _MetricChip(
                        icon:
                            Icons.local_offer_outlined,
                        label:
                            '${candidate.metrics.matchedTagsCount}/${candidate.metrics.totalTagsCount} وسوم',
                      ),
                      _MetricChip(
                        icon: Icons.bolt_outlined,
                        label:
                            '${candidate.metrics.activityPoints} نقطة نشاط',
                      ),
                      _MetricChip(
                        icon:
                            Icons.update_rounded,
                        label:
                            '${candidate.metrics.freshDays} يوم منذ آخر تحديث',
                      ),
                    ],
                  ),
                ),
                if (candidate.metrics
                    .missingMandatorySkills
                    .isNotEmpty) ...<Widget>[
                  const SizedBox(height: 13),
                  _DetailsSection(
                    icon: Icons.warning_amber_rounded,
                    title:
                        'المهارات الإلزامية الناقصة',
                    danger: true,
                    child: Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: candidate.metrics
                          .missingMandatorySkills
                          .map(
                            (skill) => _MissingChip(
                              label: skill,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
                if (candidate.explanation.reasons
                    .isNotEmpty) ...<Widget>[
                  const SizedBox(height: 13),
                  _DetailsSection(
                    icon: Icons.lightbulb_outline_rounded,
                    title: 'أسباب الترتيب',
                    child: Column(
                      children: candidate
                          .explanation.reasons
                          .map(
                            (reason) =>
                                _ExplanationItem(
                              text: reason,
                              positive: true,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
                if (candidate.explanation.missing
                    .isNotEmpty) ...<Widget>[
                  const SizedBox(height: 13),
                  _DetailsSection(
                    icon: Icons.remove_circle_outline,
                    title: 'عناصر غير متوفرة',
                    child: Column(
                      children: candidate
                          .explanation.missing
                          .map(
                            (item) =>
                                _ExplanationItem(
                              text: item,
                              positive: false,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(
                        sheetContext,
                      ).pop();

                      onOpenCandidate();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor:
                          AppColors.primaryBlue,
                      foregroundColor:
                          AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(
                      Icons.person_search_rounded,
                      size: 19,
                    ),
                    label: const Text(
                      'فتح الملف الكامل للمرشح',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

class _ModeButton extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ModeButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primaryBlue
          : Colors.transparent,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                color: selected
                    ? AppColors.onPrimary
                    : AppColors.textGrey,
                size: 18,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? AppColors.onPrimary
                        : AppColors.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeightChip extends StatelessWidget {
  final String label;
  final double weight;

  const _WeightChip({
    required this.label,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
        ),
      ),
      child: Text(
        '$label ${_numberText(weight)}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  final bool large;

  const _RankBadge({
    required this.rank,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = rank == 1
        ? AppColors.actionYellow
        : AppColors.primaryBlue;

    final size = large ? 48.0 : 38.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(
          large ? 16 : 13,
        ),
        border: Border.all(
          color: color.withOpacity(0.22),
        ),
      ),
      child: Center(
        child: Text(
          '#$rank',
          textDirection: TextDirection.ltr,
          style: TextStyle(
            color: color,
            fontSize: large ? 14 : 11.5,
            fontWeight: FontWeight.w900,
          ),
        ),
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
    final fallback =
        name.trim().isEmpty ? 'ط' : name.trim()[0];

    return CircleAvatar(
      radius: 22,
      backgroundColor:
          AppColors.primaryBlue.withOpacity(0.09),
      backgroundImage:
          imageUrl?.isNotEmpty == true
              ? NetworkImage(imageUrl!)
              : null,
      child: imageUrl?.isNotEmpty == true
          ? null
          : Text(
              fallback,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
    );
  }
}

class _FinalScoreBadge extends StatelessWidget {
  final double score;
  final bool large;

  const _FinalScoreBadge({
    required this.score,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: large ? 61 : 54,
      padding: EdgeInsets.symmetric(
        horizontal: large ? 7 : 6,
        vertical: large ? 9 : 7,
      ),
      decoration: BoxDecoration(
        color:
            AppColors.primaryBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            _numberText(score),
            textDirection: TextDirection.ltr,
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: large ? 17 : 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'النتيجة',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallScoreItem extends StatelessWidget {
  final String label;
  final double score;

  const _SmallScoreItem({
    required this.label,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          Text(
            _numberText(score),
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final bool danger;

  const _DetailsSection({
    required this.icon,
    required this.title,
    required this.child,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? AppColors.dangerRed
        : AppColors.primaryBlue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: danger
            ? AppColors.dangerRed.withOpacity(0.045)
            : AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                icon,
                color: color,
                size: 19,
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ScoreProgressRow extends StatelessWidget {
  final String label;
  final double score;
  final double weight;
  final bool showDivider;

  const _ScoreProgressRow({
    required this.label,
    required this.score,
    required this.weight,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedScore =
        score.clamp(0, 100).toDouble() / 100;

    return Column(
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 11.5,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    'الوزن ${_numberText(weight)}%',
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 9.5,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 9),
                  SizedBox(
                    width: 43,
                    child: Text(
                      _numberText(score),
                      textAlign: TextAlign.end,
                      textDirection:
                          TextDirection.ltr,
                      style: const TextStyle(
                        color:
                            AppColors.primaryBlue,
                        fontSize: 11.5,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: normalizedScore,
                  minHeight: 6,
                  color: AppColors.primaryBlue,
                  backgroundColor:
                      AppColors.primaryBlue
                          .withOpacity(0.09),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: AppColors.textGrey
                .withOpacity(0.10),
          ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({
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
        color:
            AppColors.primaryBlue.withOpacity(0.07),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingChip extends StatelessWidget {
  final String label;

  const _MissingChip({
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
        color:
            AppColors.dangerRed.withOpacity(0.07),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color:
              AppColors.dangerRed.withOpacity(0.13),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.dangerRed,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ExplanationItem extends StatelessWidget {
  final String text;
  final bool positive;

  const _ExplanationItem({
    required this.text,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final color = positive
        ? AppColors.primaryBlue
        : AppColors.dangerRed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color.withOpacity(0.09),
              shape: BoxShape.circle,
            ),
            child: Icon(
              positive
                  ? Icons.check_rounded
                  : Icons.remove_rounded,
              color: color,
              size: 13,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              text,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 11.5,
                height: 1.55,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _numberText(double value) {
  if (value == value.roundToDouble()) {
    return value.round().toString();
  }

  return value.toStringAsFixed(1);
}