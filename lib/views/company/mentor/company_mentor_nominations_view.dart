import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/mentor/company_mentor_nominations_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/company/Loading-Empty-Error/jisr_empty_state.dart';
import 'package:jisr_platform/core/widgets/company/Loading-Empty-Error/jisr_error_state.dart';
import 'package:jisr_platform/core/widgets/company/Loading-Empty-Error/jisr_loading_state.dart';
import 'package:jisr_platform/models/company/mentor/company_mentor_constants.dart';
import 'package:jisr_platform/views/company/mentor/widgets/company_mentor_nomination_widgets.dart';

class CompanyMentorNominationsView
    extends GetView<CompanyMentorNominationsController> {
  const CompanyMentorNominationsView({super.key});

  static const List<_NominationFilter> _filters = <_NominationFilter>[
    _NominationFilter('', 'الكل'),
    _NominationFilter(
      CompanyMentorNominationStatuses.pending,
      'قيد المراجعة',
    ),
    _NominationFilter(
      CompanyMentorNominationStatuses.approved,
      'مقبولة',
    ),
    _NominationFilter(
      CompanyMentorNominationStatuses.rejected,
      'مرفوضة',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.cardWhite,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: AppColors.primaryBlue,
          ),
          title: const Text(
            'ترشيحات المرشدين',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: SafeArea(
          child: Obx(
            () {
              final nominations = controller.nominations;

              return RefreshIndicator(
                color: AppColors.primaryBlue,
                onRefresh: controller.fetchNominations,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    16,
                    18,
                    30,
                  ),
                  children: <Widget>[
                    _OverviewHeader(
                      total: controller.totalNominations.value,
                      onCreate: controller.openNominationForm,
                    ),
                    const SizedBox(height: 15),
                    _StatusFilters(
                      filters: _filters,
                      selectedValue:
                          controller.selectedStatus.value,
                      enabled: !controller.isLoading.value,
                      onSelected: controller.selectStatus,
                    ),
                    if (controller.isLoading.value &&
                        nominations.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          color: AppColors.primaryBlue,
                          backgroundColor: AppColors.primaryBlue
                              .withOpacity(0.08),
                        ),
                      ),
                    ],
                    const SizedBox(height: 21),
                    Row(
                      children: <Widget>[
                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'طلبات الترشيح',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'اضغط على أي طلب لعرض كامل التفاصيل',
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue
                                .withOpacity(0.07),
                            borderRadius:
                                BorderRadius.circular(30),
                          ),
                          child: Text(
                            '${controller.totalNominations.value}',
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    if (controller.isLoading.value &&
                        nominations.isEmpty)
                      const SizedBox(
                        height: 300,
                        child: JisrLoadingState(
                          message:
                              'جاري تحميل ترشيحات المرشدين...',
                        ),
                      )
                    else if (controller
                            .errorMessage.value.isNotEmpty &&
                        nominations.isEmpty)
                      JisrErrorState(
                        title: 'تعذّر تحميل الترشيحات',
                        message: controller.errorMessage.value,
                        onRetry: controller.fetchNominations,
                      )
                    else if (nominations.isEmpty)
                      JisrEmptyState(
                        icon: Icons.people_outline_rounded,
                        title: 'لا توجد ترشيحات',
                        message:
                            controller.selectedStatus.value.isEmpty
                                ? 'لم ترشّح الشركة أي موظف للإرشاد حتى الآن.'
                                : 'لا توجد طلبات ضمن الحالة المحددة حاليًا.',
                        actionText:
                            controller.selectedStatus.value.isEmpty
                                ? 'إنشاء أول ترشيح'
                                : null,
                        onActionPressed:
                            controller.selectedStatus.value.isEmpty
                                ? controller.openNominationForm
                                : null,
                      )
                    else ...<Widget>[
                      ...nominations.map(
                        (nomination) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child:
                              CompanyMentorNominationCard(
                            nomination: nomination,
                            createdAtText:
                                controller.dateTimeText(
                              nomination.createdAt,
                            ),
                            onTap: () {
                              showCompanyMentorNominationDetails(
                                context: context,
                                nomination: nomination,
                                createdAtText:
                                    controller.dateTimeText(
                                  nomination.createdAt,
                                ),
                                reviewedAtText:
                                    controller.dateTimeText(
                                  nomination.reviewedAt,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (controller.hasMore) ...<Widget>[
                        const SizedBox(height: 4),
                        OutlinedButton(
                          onPressed:
                              controller.isLoadingMore.value
                                  ? null
                                  : () {
                                      controller.fetchNominations(
                                        loadMore: true,
                                      );
                                    },
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                AppColors.primaryBlue,
                            side: BorderSide(
                              color: AppColors.primaryBlue
                                  .withOpacity(0.22),
                            ),
                            minimumSize:
                                const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),
                          ),
                          child: controller.isLoadingMore.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        AppColors.primaryBlue,
                                  ),
                                )
                              : const Text(
                                  'عرض المزيد',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ],
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

class _OverviewHeader extends StatelessWidget {
  final int total;
  final VoidCallback onCreate;

  const _OverviewHeader({
    required this.total,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.17),
            blurRadius: 21,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: -34,
            top: -44,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.045),
              ),
            ),
          ),
          Positioned(
            left: 45,
            bottom: -52,
            child: Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.055),
                  width: 18,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'خبرات فريقك تصنع أثرًا',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'رشّح موظفًا متميزًا ليشارك خبرته المهنية مع طلاب جسور.',
                            style: TextStyle(
                              color: Colors.white
                                  .withOpacity(0.82),
                              fontSize: 11.5,
                              height: 1.55,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 58,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.11),
                        borderRadius:
                            BorderRadius.circular(17),
                        border: Border.all(
                          color:
                              Colors.white.withOpacity(0.14),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Text(
                            '$total',
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ترشيح',
                            style: TextStyle(
                              color:
                                  Colors.white.withOpacity(0.72),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onCreate,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.cardWhite,
                      foregroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.add_rounded,
                          size: 19,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'ترشيح موظف جديد',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  final List<_NominationFilter> filters;
  final String selectedValue;
  final bool enabled;
  final ValueChanged<String> onSelected;

  const _StatusFilters({
    required this.filters,
    required this.selectedValue,
    required this.enabled,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.textGrey.withOpacity(0.1),
        ),
      ),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) {
            return const SizedBox(width: 5);
          },
          itemBuilder: (context, index) {
            final filter = filters[index];
            final selected =
                selectedValue == filter.value;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled
                    ? () {
                        onSelected(filter.value);
                      }
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 180,
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryBlue
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Text(
                    filter.label,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : AppColors.textGrey,
                      fontSize: 10.8,
                      fontWeight: selected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NominationFilter {
  final String value;
  final String label;

  const _NominationFilter(
    this.value,
    this.label,
  );
}