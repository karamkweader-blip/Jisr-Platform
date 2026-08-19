import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/opportunities/company_opportunity_candidates_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_candidate_model.dart';
import 'package:jisr_platform/views/company/opportunities/widgets/company_opportunity_smart_ranking_widgets.dart';

class CompanyOpportunityCandidatesView
    extends GetView<
        CompanyOpportunityCandidatesController> {
  const CompanyOpportunityCandidatesView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);

    final blueContainer =
        baseTheme.brightness == Brightness.dark
            ? const Color(0xFF123F5E)
            : const Color(0xFFDCEFFD);

    return Theme(
      data: baseTheme.copyWith(
        colorScheme:
            baseTheme.colorScheme.copyWith(
          primary: AppColors.primaryBlue,
          onPrimary: Colors.white,
          primaryContainer: blueContainer,
          onPrimaryContainer:
              AppColors.primaryBlue,
          secondary: AppColors.primaryBlue,
          onSecondary: Colors.white,
          secondaryContainer: blueContainer,
          onSecondaryContainer:
              AppColors.primaryBlue,
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor:
                AppColors.cardWhite,
            surfaceTintColor:
                Colors.transparent,
            centerTitle: true,
            iconTheme: const IconThemeData(
              color: AppColors.primaryBlue,
            ),
            title: Text(
              'مرشحو ${controller.opportunityTitle}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          body: SafeArea(
            child: Obx(() {
              final smartRankingSelected =
                  controller
                      .isSmartRankingSelected;

              return Column(
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      18,
                      14,
                      18,
                      8,
                    ),
                    child:
                        CompanyCandidatesModeSelector(
                      smartRankingSelected:
                          smartRankingSelected,
                      onChanged:
                          (showSmartRanking) {
                        controller.selectMode(
                          showSmartRanking
                              ? CompanyOpportunityCandidatesMode
                                  .smartRanking
                              : CompanyOpportunityCandidatesMode
                                  .allApplicants,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: smartRankingSelected
                        ? _buildSmartRankingBody(
                            context,
                          )
                        : _buildAllApplicantsBody(),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildSmartRankingBody(
    BuildContext context,
  ) {
    if (controller.isRankingLoading.value &&
        controller.rankedCandidates.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryBlue,
        ),
      );
    }

    if (controller.rankingErrorMessage.value
            .isNotEmpty &&
        controller.rankedCandidates.isEmpty) {
      return _State(
        icon: Icons.auto_awesome_rounded,
        title:
            'تعذّر تحميل الترتيب الذكي',
        message: controller
            .rankingErrorMessage.value,
        actionText: 'إعادة المحاولة',
        onRetry:
            controller.fetchSmartRanking,
      );
    }

    if (controller.rankedCandidates.isEmpty) {
      return _State(
        icon: Icons.manage_search_rounded,
        title: 'لا يوجد مرشحون للترتيب',
        message:
            'لا توجد حاليًا طلبات معلقة من طلاب فعالين على هذه الفرصة.',
        actionText: 'تحديث',
        onRetry:
            controller.refreshSmartRanking,
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh:
          controller.refreshSmartRanking,
      child: ListView.separated(
        physics:
            const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          28,
        ),
        itemCount:
            controller.rankedCandidates.length +
                1,
        separatorBuilder: (_, index) {
          return SizedBox(
            height: index == 0 ? 16 : 11,
          );
        },
        itemBuilder: (_, index) {
          if (index == 0) {
            return CompanySmartRankingOverview(
              meta:
                  controller.rankingMeta.value,
            );
          }

          final candidate =
              controller.rankedCandidates[
                  index - 1];

          return CompanySmartRankingCard(
            candidate: candidate,
            onTap: () {
              showCompanySmartRankingDetails(
                context: context,
                candidate: candidate,
                weights: controller
                    .rankingMeta.value.weights,
                onOpenCandidate: () {
                  controller
                      .openRankedCandidate(
                    candidate,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAllApplicantsBody() {
    if (controller.isLoading.value &&
        controller.candidates.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryBlue,
        ),
      );
    }

    if (controller
            .errorMessage.value.isNotEmpty &&
        controller.candidates.isEmpty) {
      return _State(
        icon: Icons.groups_outlined,
        title: 'تعذّر تحميل المتقدمين',
        message:
            controller.errorMessage.value,
        actionText: 'إعادة المحاولة',
        onRetry: controller.fetchCandidates,
      );
    }

    if (controller.candidates.isEmpty) {
      return _State(
        icon: Icons.groups_outlined,
        title: 'لا يوجد متقدمون',
        message:
            'لا توجد طلبات تقديم على هذه الفرصة حتى الآن.',
        actionText: 'تحديث',
        onRetry:
            controller.refreshCandidates,
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh:
          controller.refreshCandidates,
      child: ListView.separated(
        physics:
            const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          28,
        ),
        itemCount:
            controller.candidates.length,
        separatorBuilder: (_, __) {
          return const SizedBox(height: 10);
        },
        itemBuilder: (_, index) {
          final item =
              controller.candidates[index];

          return _CandidateCard(
            item: item,
            onTap: () {
              controller.openCandidate(item);
            },
          );
        },
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  final CompanyOpportunityCandidate item;
  final VoidCallback onTap;

  const _CandidateCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        item.student.profilePictureUrl;

    return Material(
      color: AppColors.cardWhite,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(19),
            border: Border.all(
              color: AppColors.textGrey
                  .withOpacity(0.10),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primaryBlue
                    .withOpacity(0.035),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 23,
                backgroundColor:
                    AppColors.primaryBlue
                        .withOpacity(0.09),
                backgroundImage:
                    imageUrl?.isNotEmpty == true
                        ? NetworkImage(imageUrl!)
                        : null,
                child:
                    imageUrl?.isNotEmpty == true
                        ? null
                        : Text(
                            item.student.name
                                    .trim()
                                    .isEmpty
                                ? 'ط'
                                : item.student.name
                                    .trim()[0],
                            style:
                                const TextStyle(
                              color: AppColors
                                  .primaryBlue,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.student.name,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:
                            AppColors.textDark,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.student.major.isEmpty
                          ? item.student.email
                          : item.student.major,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:
                            AppColors.textGrey,
                        fontSize: 10.5,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.displayStatus.isEmpty
                          ? item.applicationStatus
                          : item.displayStatus,
                      style: const TextStyle(
                        color: AppColors
                            .primaryBlue,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (item.matchScore != null)
                Container(
                  width: 60,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors
                        .primaryBlue
                        .withOpacity(0.08),
                    borderRadius:
                        BorderRadius.circular(
                      13,
                    ),
                  ),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '${item.matchScore!.round()}%',
                        textDirection:
                            TextDirection.ltr,
                        style: const TextStyle(
                          color: AppColors
                              .primaryBlue,
                          fontSize: 11.5,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'تطابق مهارات',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color: AppColors
                              .textGrey,
                          fontSize: 7.5,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.textGrey,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _State extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onRetry;

  const _State({
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue
                    .withOpacity(0.08),
                borderRadius:
                    BorderRadius.circular(22),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: onRetry,
                style:
                    OutlinedButton.styleFrom(
                  foregroundColor:
                      AppColors.primaryBlue,
                  side: BorderSide(
                    color: AppColors
                        .primaryBlue
                        .withOpacity(0.25),
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                ),
                label: Text(
                  actionText ??
                      'إعادة المحاولة',
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}