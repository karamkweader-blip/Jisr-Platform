import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/mentor/company_mentor_constants.dart';
import 'package:jisr_platform/models/company/mentor/company_mentor_nomination_model.dart';

class CompanyMentorNominationCard extends StatelessWidget {
  final CompanyMentorNominationModel nomination;
  final String createdAtText;
  final VoidCallback onTap;

  const CompanyMentorNominationCard({
    super.key,
    required this.nomination,
    required this.createdAtText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardWhite,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.textGrey.withOpacity(0.1),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.035),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _initials(nomination.fullName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          nomination.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nomination.professionalTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 11.5,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  CompanyMentorStatusBadge(
                    status: nomination.status,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      CompanyMentorSpecializations.label(
                        nomination.specialization,
                      ),
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'أُرسل في',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 9.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        createdAtText,
                        textDirection: TextDirection.ltr,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 9.8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (nomination.status ==
                      CompanyMentorNominationStatuses.rejected &&
                  nomination.rejectionReason != null) ...<Widget>[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.055),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    nomination.rejectionReason!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 10.8,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 13),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Divider(
                      color: AppColors.textGrey.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'عرض الطلب',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 10.8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 5),
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

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();

    if (parts.isEmpty) {
      return '؟';
    }

    return parts
        .map((part) => part.substring(0, 1))
        .join();
  }
}

class CompanyMentorStatusBadge extends StatelessWidget {
  final String status;

  const CompanyMentorStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _StatusPalette.fromStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: palette.color.withOpacity(0.1),
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
            CompanyMentorNominationStatuses.label(status),
            style: TextStyle(
              color: palette.color,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showCompanyMentorNominationDetails({
  required BuildContext context,
  required CompanyMentorNominationModel nomination,
  required String createdAtText,
  required String reviewedAtText,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
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
          initialChildSize: 0.82,
          minChildSize: 0.55,
          maxChildSize: 0.94,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                28,
              ),
              children: <Widget>[
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textGrey.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.volunteer_activism_rounded,
                        color: AppColors.cardWhite,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            nomination.fullName,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nomination.professionalTitle,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 9),
                          CompanyMentorStatusBadge(
                            status: nomination.status,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (nomination.status ==
                        CompanyMentorNominationStatuses.rejected &&
                    nomination.rejectionReason != null) ...<Widget>[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'سبب الرفض',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          nomination.rejectionReason!,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 12.5,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _DetailsSection(
                  title: 'معلومات التواصل',
                  children: <Widget>[
                    _DetailRow(
                      icon: Icons.email_outlined,
                      label: 'البريد الإلكتروني',
                      value: nomination.email,
                    ),
                    _DetailRow(
                      icon: Icons.phone_outlined,
                      label: 'WhatsApp',
                      value: nomination.whatsappNumber,
                    ),
                    _DetailRow(
                      icon: Icons.link_rounded,
                      label: 'LinkedIn',
                      value: nomination.linkedinUrl,
                    ),
                    _DetailRow(
                      icon: Icons.code_rounded,
                      label: 'GitHub أو Portfolio',
                      value: nomination.githubOrPortfolioUrl,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _DetailsSection(
                  title: 'الخبرة المهنية',
                  children: <Widget>[
                    _DetailRow(
                      icon: Icons.category_outlined,
                      label: 'التخصص',
                      value:
                          CompanyMentorSpecializations.label(
                        nomination.specialization,
                      ),
                    ),
                    _DetailRow(
                      icon: Icons.workspace_premium_outlined,
                      label: 'الخبرات',
                      value: nomination.expertise,
                    ),
                    _DetailRow(
                      icon: Icons.person_outline_rounded,
                      label: 'النبذة',
                      value: nomination.bio,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _DetailsSection(
                  title: 'مواضيع الإرشاد',
                  children: <Widget>[
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: nomination.mentoringTopics
                          .map(
                            (topic) => Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue
                                    .withOpacity(0.07),
                                borderRadius:
                                    BorderRadius.circular(30),
                              ),
                              child: Text(
                                CompanyMentorTopics.label(topic),
                                style: const TextStyle(
                                  color:
                                      AppColors.primaryBlue,
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _DetailsSection(
                  title: 'حالة المراجعة',
                  children: <Widget>[
                    _DetailRow(
                      icon: Icons.event_note_rounded,
                      label: 'تاريخ الترشيح',
                      value: createdAtText,
                    ),
                    _DetailRow(
                      icon: Icons.fact_check_outlined,
                      label: 'تاريخ المراجعة',
                      value: reviewedAtText,
                      showDivider: false,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

class _DetailsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 18,
              ),
              const SizedBox(width: 9),
              SizedBox(
                width: 105,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: SelectableText(
                  value.isEmpty ? 'غير محدد' : value,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 11.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: AppColors.textGrey.withOpacity(0.12),
          ),
      ],
    );
  }
}

class _StatusPalette {
  final Color color;
  final IconData icon;

  const _StatusPalette(
    this.color,
    this.icon,
  );

  factory _StatusPalette.fromStatus(String status) {
    switch (status) {
      case CompanyMentorNominationStatuses.approved:
        return const _StatusPalette(
          Colors.green,
          Icons.check_circle_outline_rounded,
        );

      case CompanyMentorNominationStatuses.rejected:
        return const _StatusPalette(
          Colors.red,
          Icons.cancel_outlined,
        );

      default:
        return const _StatusPalette(
          AppColors.actionYellow,
          Icons.hourglass_top_rounded,
        );
    }
  }
}