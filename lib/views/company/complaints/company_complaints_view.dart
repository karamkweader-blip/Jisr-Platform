import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/complaints/company_complaints_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/company/Loading-Empty-Error/jisr_empty_state.dart';
import 'package:jisr_platform/core/widgets/company/Loading-Empty-Error/jisr_error_state.dart';
import 'package:jisr_platform/core/widgets/company/Loading-Empty-Error/jisr_loading_state.dart';
import 'package:jisr_platform/models/company/complaints/company_complaint_model.dart';
import 'package:jisr_platform/views/company/complaints/widgets/company_complaint_widgets.dart';

class CompanyComplaintsView extends GetView<CompanyComplaintsController> {
  const CompanyComplaintsView({super.key});

  static const List<_ComplaintFilter> _statusFilters = <_ComplaintFilter>[
    _ComplaintFilter('', 'الكل'),
    _ComplaintFilter(
      CompanyComplaintStatuses.pending,
      'قيد الانتظار',
    ),
    _ComplaintFilter(
      CompanyComplaintStatuses.underReview,
      'قيد المراجعة',
    ),
    _ComplaintFilter(
      CompanyComplaintStatuses.resolved,
      'تم الحل',
    ),
    _ComplaintFilter(
      CompanyComplaintStatuses.rejected,
      'مرفوضة',
    ),
  ];

  static const List<_ComplaintFilter> _contextFilters = <_ComplaintFilter>[
    _ComplaintFilter('', 'كل الأنواع'),
    _ComplaintFilter(
      CompanyComplaintContextTypes.taskAssignment,
      'شكاوى المهام',
    ),
    _ComplaintFilter(
      CompanyComplaintContextTypes.opportunityInterview,
      'شكاوى المقابلات',
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
            'شكاواي',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: SafeArea(
          child: Obx(() {
            final complaints = controller.complaints;

            final hasFilters =
                controller.selectedStatus.value.isNotEmpty ||
                controller.selectedContextType.value.isNotEmpty;

            return RefreshIndicator(
              color: AppColors.primaryBlue,
              onRefresh: controller.refreshComplaints,
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
                  _ComplaintsOverviewHeader(
                    total: controller.totalComplaints.value,
                  ),
                  const SizedBox(height: 17),
                  _FiltersSection(
                    title: 'حالة الشكوى',
                    filters: _statusFilters,
                    selectedValue:
                        controller.selectedStatus.value,
                    enabled: !controller.isLoading.value,
                    onSelected: controller.selectStatus,
                  ),
                  const SizedBox(height: 13),
                  _FiltersSection(
                    title: 'نوع الشكوى',
                    filters: _contextFilters,
                    selectedValue:
                        controller.selectedContextType.value,
                    enabled: !controller.isLoading.value,
                    onSelected: controller.selectContextType,
                  ),
                  if (hasFilters) ...<Widget>[
                    const SizedBox(height: 9),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.clearFilters,
                        icon: const Icon(
                          Icons.filter_alt_off_outlined,
                        ),
                        label: const Text('مسح الفلاتر'),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              AppColors.primaryBlue,
                          textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (controller.isLoading.value &&
                      complaints.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
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
                  const SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'الشكاوى المرسلة',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'اضغط على الشكوى لعرض نتيجة المراجعة',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 10.5,
                                fontWeight:
                                    FontWeight.w500,
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
                          '${controller.totalComplaints.value}',
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
                      complaints.isEmpty)
                    const SizedBox(
                      height: 290,
                      child: JisrLoadingState(
                        message:
                            'جاري تحميل شكاوى الشركة...',
                      ),
                    )
                  else if (controller
                          .errorMessage.value.isNotEmpty &&
                      complaints.isEmpty)
                    JisrErrorState(
                      title: 'تعذّر تحميل الشكاوى',
                      message:
                          controller.errorMessage.value,
                      onRetry: controller.fetchComplaints,
                    )
                  else if (complaints.isEmpty)
                    JisrEmptyState(
                      icon: Icons.mark_email_read_outlined,
                      title: hasFilters
                          ? 'لا توجد نتائج'
                          : 'لا توجد شكاوى',
                      message: hasFilters
                          ? 'لا توجد شكاوى مطابقة للفلاتر المحددة.'
                          : 'ستظهر هنا الشكاوى التي ترسلها من تفاصيل المهمة أو المقابلة.',
                      actionText:
                          hasFilters ? 'مسح الفلاتر' : null,
                      onActionPressed: hasFilters
                          ? controller.clearFilters
                          : null,
                    )
                  else ...<Widget>[
                    ...complaints.map(
                      (complaint) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: CompanyComplaintCard(
                          complaint: complaint,
                          statusLabel:
                              controller.statusLabel(
                            complaint.status,
                          ),
                          contextLabel:
                              controller.contextLabel(
                            complaint.context.type,
                          ),
                          createdAtText:
                              controller.dateTimeText(
                            complaint.createdAt,
                          ),
                          onTap: () {
                            showCompanyComplaintDetails(
                              context: context,
                              complaint: complaint,
                              statusLabel:
                                  controller.statusLabel(
                                complaint.status,
                              ),
                              contextLabel:
                                  controller.contextLabel(
                                complaint.context.type,
                              ),
                              createdAtText:
                                  controller.dateTimeText(
                                complaint.createdAt,
                              ),
                              resolvedAtText:
                                  controller.dateTimeText(
                                complaint.resolvedAt,
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
                            controller.isLoading.value ||
                                    controller
                                        .isLoadingMore.value
                                ? null
                                : () {
                                    controller.fetchComplaints(
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
                        child:
                            controller.isLoadingMore.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors
                                          .primaryBlue,
                                    ),
                                  )
                                : const Text(
                                    'عرض المزيد',
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.w800,
                                    ),
                                  ),
                      ),
                    ],
                  ],
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ComplaintsOverviewHeader extends StatelessWidget {
  final int total;

  const _ComplaintsOverviewHeader({
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color:
                AppColors.primaryBlue.withOpacity(0.16),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color:
                  AppColors.cardWhite.withOpacity(0.15),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: AppColors.actionYellow,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'تابع شكاوى الشركة',
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  total == 0
                      ? 'لا توجد شكاوى مرسلة حتى الآن'
                      : 'يوجد $total شكوى ضمن العرض الحالي',
                  style: const TextStyle(
                    color: AppColors.onPrimaryMuted,
                    fontSize: 11.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
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

class _FiltersSection extends StatelessWidget {
  final String title;
  final List<_ComplaintFilter> filters;
  final String selectedValue;
  final bool enabled;
  final ValueChanged<String> onSelected;

  const _FiltersSection({
    required this.title,
    required this.filters,
    required this.selectedValue,
    required this.enabled,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsetsDirectional.only(start: 3),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 39,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: filters.length,
            separatorBuilder: (_, __) {
              return const SizedBox(width: 7);
            },
            itemBuilder: (_, index) {
              final filter = filters[index];
              final selected =
                  selectedValue == filter.value;

              return ChoiceChip(
                selected: selected,
                label: Text(filter.label),
                onSelected: enabled
                    ? (_) => onSelected(filter.value)
                    : null,
                selectedColor: AppColors.primaryBlue
                    .withOpacity(0.11),
                backgroundColor: AppColors.cardWhite,
                disabledColor: AppColors.cardWhite,
                side: BorderSide(
                  color: selected
                      ? AppColors.primaryBlue
                          .withOpacity(0.28)
                      : AppColors.textGrey
                          .withOpacity(0.13),
                ),
                labelStyle: TextStyle(
                  color: selected
                      ? AppColors.primaryBlue
                      : AppColors.textGrey,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(30),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ComplaintFilter {
  final String value;
  final String label;

  const _ComplaintFilter(
    this.value,
    this.label,
  );
}