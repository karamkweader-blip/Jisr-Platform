import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/complaints/company_complaint_model.dart';

class CompanyComplaintCard extends StatelessWidget {
  final CompanyComplaintModel complaint;
  final String statusLabel;
  final String contextLabel;
  final String createdAtText;
  final VoidCallback onTap;

  const CompanyComplaintCard({
    super.key,
    required this.complaint,
    required this.statusLabel,
    required this.contextLabel,
    required this.createdAtText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardWhite,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.textGrey.withOpacity(0.10),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primaryBlue
                    .withOpacity(0.035),
                blurRadius: 16,
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
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue
                          .withOpacity(0.08),
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                    child: Icon(
                      _contextIcon(
                        complaint.context.type,
                      ),
                      color: AppColors.primaryBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          complaint.targetName,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: <Widget>[
                            Icon(
                              _contextIcon(
                                complaint.context.type,
                              ),
                              color:
                                  AppColors.textGrey,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                contextLabel,
                                maxLines: 1,
                                overflow: TextOverflow
                                    .ellipsis,
                                style:
                                    const TextStyle(
                                  color: AppColors
                                      .textGrey,
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  CompanyComplaintStatusBadge(
                    status: complaint.status,
                    label: statusLabel,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Text(
                  complaint.reason,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 11.5,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (complaint.hasResolution) ...<Widget>[
                const SizedBox(height: 11),
                const Row(
                  children: <Widget>[
                    Icon(
                      Icons.fact_check_outlined,
                      color: AppColors.primaryBlue,
                      size: 17,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'تتوفر نتيجة مراجعة من الإدارة',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 10.5,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 13),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.schedule_rounded,
                    color: AppColors.textGrey,
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    createdAtText,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'عرض التفاصيل',
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

class CompanyComplaintStatusBadge
    extends StatelessWidget {
  final String status;
  final String label;

  const CompanyComplaintStatusBadge({
    super.key,
    required this.status,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final palette =
        _ComplaintStatusPalette.fromStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: palette.color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            palette.icon,
            color: palette.color,
            size: 13,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: palette.color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showCompanyComplaintDetails({
  required BuildContext context,
  required CompanyComplaintModel complaint,
  required String statusLabel,
  required String contextLabel,
  required String createdAtText,
  required String resolvedAtText,
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
          initialChildSize: 0.78,
          minChildSize: 0.48,
          maxChildSize: 0.94,
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
                28,
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
                    Container(
                      width: 53,
                      height: 53,
                      decoration: BoxDecoration(
                        gradient:
                            AppColors.primaryGradient,
                        borderRadius:
                            BorderRadius.circular(17),
                      ),
                      child: Icon(
                        _contextIcon(
                          complaint.context.type,
                        ),
                        color: AppColors.onPrimary,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            complaint.targetName,
                            style: const TextStyle(
                              color:
                                  AppColors.textDark,
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            contextLabel,
                            style: const TextStyle(
                              color:
                                  AppColors.textGrey,
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CompanyComplaintStatusBadge(
                            status:
                                complaint.status,
                            label: statusLabel,
                          ),
                        ],
                      ),
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
                _ComplaintDetailsSection(
                  icon: Icons.description_outlined,
                  title: 'سبب الشكوى',
                  child: SelectableText(
                    complaint.reason,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 12.5,
                      height: 1.65,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                _ComplaintDetailsSection(
                  icon: Icons.info_outline_rounded,
                  title: 'معلومات الشكوى',
                  child: Column(
                    children: <Widget>[
                      _ComplaintDetailRow(
                        label: 'رقم الشكوى',
                        value: '#${complaint.id}',
                      ),
                      _ComplaintDetailRow(
                        label: 'النوع',
                        value: contextLabel,
                      ),
                      _ComplaintDetailRow(
                        label: 'تاريخ الإرسال',
                        value: createdAtText,
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                if (complaint
                    .targetEmail.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 13),
                  _ComplaintDetailsSection(
                    icon:
                        Icons.person_outline_rounded,
                    title: 'الطرف المبلّغ عنه',
                    child: _ComplaintDetailRow(
                      label: 'البريد',
                      value: complaint.targetEmail,
                      showDivider: false,
                    ),
                  ),
                ],
                if (complaint.status ==
                        CompanyComplaintStatuses
                            .resolved ||
                    complaint.status ==
                        CompanyComplaintStatuses
                            .rejected) ...<Widget>[
                  const SizedBox(height: 13),
                  _ComplaintDetailsSection(
                    icon:
                        Icons.fact_check_outlined,
                    title: 'نتيجة مراجعة الإدارة',
                    highlighted: true,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: <Widget>[
                        SelectableText(
                          complaint.resolutionNotes
                                      ?.trim()
                                      .isNotEmpty ==
                                  true
                              ? complaint
                                  .resolutionNotes!
                                  .trim()
                              : 'لم تضف الإدارة ملاحظات إضافية.',
                          style: const TextStyle(
                            color:
                                AppColors.textDark,
                            fontSize: 12.5,
                            height: 1.65,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons
                                  .event_available_outlined,
                              color: AppColors
                                  .textGrey,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              resolvedAtText,
                              textDirection:
                                  TextDirection.ltr,
                              style:
                                  const TextStyle(
                                color: AppColors
                                    .textGrey,
                                fontSize: 10.5,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      );
    },
  );
}

class _ComplaintDetailsSection
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final bool highlighted;

  const _ComplaintDetailsSection({
    required this.icon,
    required this.title,
    required this.child,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.primaryBlue
                .withOpacity(0.055)
            : AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlighted
              ? AppColors.primaryBlue
                  .withOpacity(0.12)
              : AppColors.textGrey
                  .withOpacity(0.08),
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
                color: AppColors.primaryBlue,
                size: 19,
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: const TextStyle(
                  color:
                      AppColors.primaryBlue,
                  fontSize: 12.5,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          child,
        ],
      ),
    );
  }
}

class _ComplaintDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _ComplaintDetailRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.symmetric(
            vertical: 8,
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 105,
                child: Text(
                  label,
                  style: const TextStyle(
                    color:
                        AppColors.textGrey,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: SelectableText(
                  value,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 11.5,
                    height: 1.45,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: AppColors.textGrey
                .withOpacity(0.11),
          ),
      ],
    );
  }
}

IconData _contextIcon(String contextType) {
  switch (contextType) {
    case CompanyComplaintContextTypes
        .taskAssignment:
      return Icons.assignment_outlined;

    case CompanyComplaintContextTypes
        .opportunityInterview:
      return Icons.event_note_outlined;

    default:
      return Icons.report_outlined;
  }
}

class _ComplaintStatusPalette {
  final Color color;
  final IconData icon;

  const _ComplaintStatusPalette(
    this.color,
    this.icon,
  );

  factory _ComplaintStatusPalette.fromStatus(
    String status,
  ) {
    switch (status) {
      case CompanyComplaintStatuses.underReview:
        return const _ComplaintStatusPalette(
          AppColors.primaryBlue,
          Icons.manage_search_rounded,
        );

      case CompanyComplaintStatuses.resolved:
        return const _ComplaintStatusPalette(
          AppColors.successGreen,
          Icons.check_circle_outline_rounded,
        );

      case CompanyComplaintStatuses.rejected:
        return const _ComplaintStatusPalette(
          AppColors.dangerRed,
          Icons.cancel_outlined,
        );

      default:
        return const _ComplaintStatusPalette(
          AppColors.actionYellow,
          Icons.hourglass_top_rounded,
        );
    }
  }
}