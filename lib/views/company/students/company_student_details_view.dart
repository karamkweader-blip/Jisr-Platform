import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/students/company_student_details_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/company/Loading-Empty-Error/jisr_error_state.dart';
import 'package:jisr_platform/core/widgets/company/Loading-Empty-Error/jisr_loading_state.dart';
import 'package:jisr_platform/models/company/students/company_student_details_model.dart';

class CompanyStudentDetailsView
    extends GetView<
        CompanyStudentDetailsController> {
  const CompanyStudentDetailsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          backgroundColor:
              Get.theme.scaffoldBackgroundColor,
          surfaceTintColor:
              Colors.transparent,
          foregroundColor:
              AppColors.primaryBlue,
          title: const Text(
            'ملف الطالب',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Obx(
            () {
              final student =
                  controller.student.value;

              if (controller
                      .isLoading.value &&
                  student == null) {
                return const JisrLoadingState(
                  message:
                      'جاري تحميل ملف الطالب...',
                );
              }

              if (controller
                      .errorMessage
                      .value
                      .isNotEmpty &&
                  student == null) {
                return JisrErrorState(
                  title:
                      'تعذّر تحميل ملف الطالب',
                  message: controller
                      .errorMessage.value,
                  onRetry: controller
                      .fetchStudentDetails,
                );
              }

              if (student == null) {
                return const JisrErrorState(
                  title:
                      'بيانات الطالب غير متاحة',
                  message:
                      'لم نتمكن من العثور على بيانات هذا الطالب.',
                );
              }

              return RefreshIndicator(
                color: AppColors.primaryBlue,
                onRefresh: controller
                    .fetchStudentDetails,
                child: ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(
                    parent:
                        BouncingScrollPhysics(),
                  ),
                  padding:
                      const EdgeInsets.fromLTRB(
                    18,
                    12,
                    18,
                    30,
                  ),
                  children: <Widget>[
                    _ProfileHeader(
                      student: student,
                    ),

                    if (controller
                        .isLoading.value) ...<
                        Widget>[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius:
                            const BorderRadius
                                .all(
                          Radius.circular(10),
                        ),
                        child: SizedBox(
                          height: 3,
                          child:
                              LinearProgressIndicator(
                            color: AppColors
                                .primaryBlue,
                            backgroundColor:
                                AppColors
                                    .textGrey
                                    .withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                      ),
                    ],

                    if (student.bio != null) ...<
                        Widget>[
                      const SizedBox(height: 15),
                      _DetailsSection(
                        icon: Icons
                            .format_quote_rounded,
                        title:
                            'نبذة عن الطالب',
                        child: Text(
                          student.bio!,
                          style:
                              const TextStyle(
                            color: AppColors
                                .textDark,
                            fontSize: 13,
                            height: 1.65,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 15),

                    _AcademicSection(
                      student: student,
                    ),

                    const SizedBox(height: 15),

                    _SkillsSection(
                      skills: student.skills,
                      sourceLabel:
                          controller.sourceLabel,
                    ),

                    const SizedBox(height: 15),

                    _CvsSection(
                      cvs: student.cvs,
                      formatDate:
                          controller.formatDate,
                      onOpen: controller
                          .openExternalUrl,
                    ),

                    const SizedBox(height: 15),

                    _PortfolioSection(
                      projects: student
                          .portfolioProjects,
                      onOpen: controller
                          .openExternalUrl,
                    ),
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

class _ProfileHeader extends StatelessWidget {
  final CompanyStudentDetailsModel student;

  const _ProfileHeader({
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primaryBlue
                .withValues(
              alpha: 0.17,
            ),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              _ProfileAvatar(
                name: student.name,
                imageUrl:
                    student.profilePictureUrl,
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      student.name.isEmpty
                          ? 'طالب'
                          : student.name,
                      style: const TextStyle(
                        color:
                            AppColors.onPrimary,
                        fontSize: 19,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    SelectableText(
                      student.email.isEmpty
                          ? 'البريد الإلكتروني غير متوفر'
                          : student.email,
                      textDirection:
                          TextDirection.ltr,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppColors
                            .onPrimaryMuted,
                        fontSize: 11.5,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    _VerificationBadge(
                      isVerified: student
                          .isVerifiedByAdmin,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          Row(
            children: <Widget>[
              Expanded(
                child: _HeaderStat(
                  icon: Icons
                      .auto_awesome_rounded,
                  value:
                      '${student.skills.length}',
                  label: 'مهارة',
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: _HeaderStat(
                  icon: Icons
                      .description_outlined,
                  value:
                      '${student.cvs.length}',
                  label: 'سيرة ذاتية',
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: _HeaderStat(
                  icon: Icons
                      .folder_special_outlined,
                  value:
                      '${student.portfolioProjects.length}',
                  label: 'مشروع',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar
    extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _ProfileAvatar({
    required this.name,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter = name.trim().isEmpty
        ? 'ط'
        : name.trim().characters.first;

    final fallback =
        _ProfileInitial(letter: firstLetter);

    if (imageUrl == null ||
        imageUrl!.isEmpty) {
      return fallback;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(19),
      child: Image.network(
        imageUrl!,
        width: 62,
        height: 62,
        fit: BoxFit.cover,
        errorBuilder: (
          _,
          __,
          ___,
        ) {
          return fallback;
        },
      ),
    );
  }
}

class _ProfileInitial
    extends StatelessWidget {
  final String letter;

  const _ProfileInitial({
    required this.letter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.onPrimary
            .withValues(
          alpha: 0.14,
        ),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.onPrimary
              .withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Text(
        letter,
        style: const TextStyle(
          color: AppColors.actionYellow,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _VerificationBadge
    extends StatelessWidget {
  final bool isVerified;

  const _VerificationBadge({
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.onPrimary
            .withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            isVerified
                ? Icons.verified_rounded
                : Icons
                    .info_outline_rounded,
            color: isVerified
                ? AppColors.actionYellow
                : AppColors
                    .onPrimaryMuted,
            size: 15,
          ),

          const SizedBox(width: 5),

          Text(
            isVerified
                ? 'حساب موثّق'
                : 'بانتظار التحقق',
            style: const TextStyle(
              color: AppColors.onPrimary,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _HeaderStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.onPrimary
            .withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            color: AppColors.actionYellow,
            size: 18,
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: const TextStyle(
              color: AppColors.onPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 1),

          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color:
                  AppColors.onPrimaryMuted,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AcademicSection
    extends StatelessWidget {
  final CompanyStudentDetailsModel student;

  const _AcademicSection({
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return _DetailsSection(
      icon: Icons.school_outlined,
      title:
          'المعلومات الأكاديمية والتواصل',
      child: Column(
        children: <Widget>[
          _InfoRow(
            icon: Icons
                .account_balance_outlined,
            label: 'الجامعة',
            value: student.profile.university,
          ),

          _InfoRow(
            icon: Icons.menu_book_outlined,
            label: 'التخصص',
            value: student.profile.major,
          ),

          _InfoRow(
            icon: Icons
                .event_available_outlined,
            label: 'سنة التخرج',
            value:
                student.profile.graduationYear,
          ),

          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'رقم الهاتف',
            value: student.profile.phone,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _SkillsSection
    extends StatelessWidget {
  final List<CompanyStudentSkillModel>
      skills;

  final String Function(String)
      sourceLabel;

  const _SkillsSection({
    required this.skills,
    required this.sourceLabel,
  });

  @override
  Widget build(BuildContext context) {
    return _DetailsSection(
      icon: Icons.auto_awesome_rounded,
      title: 'المهارات والخبرات',
      trailing: _CountBadge(
        count: skills.length,
      ),
      child: skills.isEmpty
          ? const _CompactEmptyMessage(
              icon:
                  Icons.psychology_outlined,
              message:
                  'لم يضف الطالب مهارات حتى الآن.',
            )
          : Column(
              children: skills
                  .map(
                    (skill) => Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 9,
                      ),
                      child: _SkillCard(
                        skill: skill,
                        sourceLabel:
                            sourceLabel(
                          skill.source,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final CompanyStudentSkillModel skill;
  final String sourceLabel;

  const _SkillCard({
    required this.skill,
    required this.sourceLabel,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedLevel =
        skill.proficiencyLevel.clamp(
      0,
      5,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Get.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.primaryBlue
              .withValues(
            alpha: 0.07,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue
                      .withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color:
                      AppColors.primaryBlue,
                  size: 19,
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      skill.name.isEmpty
                          ? 'مهارة'
                          : skill.name,
                      style:
                           TextStyle(
                        color:
                            Get.theme.colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    if (skill.category
                        .isNotEmpty) ...<Widget>[
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        skill.category,
                        style:
                            const TextStyle(
                          color: AppColors
                              .textGrey,
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (skill.verified)
                const Icon(
                  Icons.verified_rounded,
                  color:
                      AppColors.successGreen,
                  size: 19,
                ),
            ],
          ),

          const SizedBox(height: 11),

          Row(
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(10),
                  child: SizedBox(
                    height: 6,
                    child:
                        LinearProgressIndicator(
                      value:
                          normalizedLevel / 5,
                      color: AppColors
                          .actionYellow,
                      backgroundColor:
                          Get.theme.colorScheme.onSurfaceVariant
                              .withValues(
                        alpha: 0.1,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 9),

              Text(
                '$normalizedLevel/5',
                style: const TextStyle(
                  color:
                      AppColors.primaryBlue,
                  fontSize: 10.5,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: <Widget>[
               Icon(
                Icons.travel_explore_rounded,
                color: Get.theme.colorScheme.onSurfaceVariant,
                size: 14,
              ),

              const SizedBox(width: 5),

              Expanded(
                child: Text(
                  sourceLabel,
                  style:  TextStyle(
                    color:
                        Get.theme.colorScheme.onSurfaceVariant,
                    fontSize: 9.5,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),

              if (skill.confidenceScore > 0)
                Text(
                  'الثقة ${(skill.confidenceScore * 100).round()}%',
                  style:  TextStyle(
                    color:
                        Get.theme.colorScheme.onSurfaceVariant,
                    fontSize: 9.5,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CvsSection extends StatelessWidget {
  final List<CompanyStudentCvModel> cvs;

  final String Function(DateTime?)
      formatDate;

  final ValueChanged<String> onOpen;

  const _CvsSection({
    required this.cvs,
    required this.formatDate,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return _DetailsSection(
      icon: Icons.description_outlined,
      title: 'السيرة الذاتية',
      trailing: _CountBadge(
        count: cvs.length,
      ),
      child: cvs.isEmpty
          ? const _CompactEmptyMessage(
              icon:
                  Icons.file_present_outlined,
              message:
                  'لا توجد سيرة ذاتية متاحة لهذا الطالب.',
            )
          : Column(
              children: cvs
                  .map(
                    (cv) => Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 9,
                      ),
                      child: _CvCard(
                        cv: cv,
                        uploadedAt:
                            formatDate(
                          cv.uploadedAt,
                        ),
                        onOpen:
                            cv.fileUrl.isEmpty
                                ? null
                                : () {
                                    onOpen(
                                      cv.fileUrl,
                                    );
                                  },
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _CvCard extends StatelessWidget {
  final CompanyStudentCvModel cv;
  final String uploadedAt;
  final VoidCallback? onOpen;

  const _CvCard({
    required this.cv,
    required this.uploadedAt,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Get.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.primaryBlue
              .withValues(
            alpha: 0.07,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.dangerRed
                  .withValues(
                alpha: 0.08,
              ),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: AppColors.dangerRed,
              size: 22,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Flexible(
                      child: Text(
                        'السيرة الذاتية',
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style: TextStyle(
                          color: AppColors
                              .textDark,
                          fontSize: 12.5,
                          fontWeight:
                              FontWeight
                                  .w900,
                        ),
                      ),
                    ),

                    if (cv.isPrimary) ...<
                        Widget>[
                      const SizedBox(width: 7),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration:
                            BoxDecoration(
                          color: AppColors
                              .actionYellow
                              .withValues(
                            alpha: 0.13,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),
                        ),
                        child: const Text(
                          'الأساسية',
                          style: TextStyle(
                            color: AppColors
                                .actionYellow,
                            fontSize: 8.5,
                            fontWeight:
                                FontWeight
                                    .w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  'تاريخ الرفع: $uploadedAt',
                  style:  TextStyle(
                    color:
                        Get.theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          IconButton(
            tooltip:
                'فتح السيرة الذاتية',
            onPressed: onOpen,
            style: IconButton.styleFrom(
              backgroundColor:
                  AppColors.primaryBlue
                      .withValues(
                alpha: 0.08,
              ),
            ),
            icon: const Icon(
              Icons.open_in_new_rounded,
              color: AppColors.primaryBlue,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioSection
    extends StatelessWidget {
  final List<
          CompanyStudentPortfolioProjectModel>
      projects;

  final ValueChanged<String> onOpen;

  const _PortfolioSection({
    required this.projects,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return _DetailsSection(
      icon: Icons.folder_special_outlined,
      title: 'المشاريع العملية',
      trailing: _CountBadge(
        count: projects.length,
      ),
      child: projects.isEmpty
          ? const _CompactEmptyMessage(
              icon:
                  Icons.folder_off_outlined,
              message:
                  'لم يضف الطالب مشاريع إلى ملفه بعد.',
            )
          : Column(
              children: projects
                  .map(
                    (project) => Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 9,
                      ),
                      child: _ProjectCard(
                        project: project,
                        onOpen: project
                                    .projectUrl ==
                                null
                            ? null
                            : () {
                                onOpen(
                                  project
                                      .projectUrl!,
                                );
                              },
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final CompanyStudentPortfolioProjectModel
      project;

  final VoidCallback? onOpen;

  const _ProjectCard({
    required this.project,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Get.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.primaryBlue
              .withValues(
            alpha: 0.07,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue
                      .withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons
                      .rocket_launch_outlined,
                  color:
                      AppColors.primaryBlue,
                  size: 19,
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  project.title,
                  style:  TextStyle(
                    color:
                        Get.theme.colorScheme.onSurface,
                    fontSize: 12.5,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),

              if (onOpen != null)
                IconButton(
                  tooltip: 'فتح المشروع',
                  onPressed: onOpen,
                  icon: const Icon(
                    Icons.open_in_new_rounded,
                    color: AppColors
                        .primaryBlue,
                    size: 18,
                  ),
                ),
            ],
          ),

          if (project.description !=
              null) ...<Widget>[
            const SizedBox(height: 8),

            Text(
              project.description!,
              style:  TextStyle(
                color: Get.theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          if (project
              .technologies.isNotEmpty) ...<
              Widget>[
            const SizedBox(height: 9),

            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: project.technologies
                  .map(
                    (technology) =>
                        Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration:
                          BoxDecoration(
                        color: AppColors
                            .primaryBlue
                            .withValues(
                          alpha: 0.07,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          16,
                        ),
                      ),
                      child: Text(
                        technology,
                        style:
                            const TextStyle(
                          color: AppColors
                              .primaryBlue,
                          fontSize: 9.5,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailsSection
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  const _DetailsSection({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBlue
              .withValues(
            alpha: 0.07,
          ),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primaryBlue
                .withValues(
              alpha: 0.035,
            ),
            blurRadius: 15,
            offset: const Offset(0, 6),
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
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue
                      .withValues(
                    alpha: 0.08,
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

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  title,
                  style:  TextStyle(
                    color:
                        Get.theme.colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),

              if (trailing != null)
                trailing!,
            ],
          ),

          const SizedBox(height: 13),

          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool showDivider;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue =
        value == null ||
                value!.trim().isEmpty
            ? 'غير محدد'
            : value!;

    return Column(
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.symmetric(
            vertical: 9,
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                icon,
                color:
                    AppColors.primaryBlue,
                size: 18,
              ),

              const SizedBox(width: 9),

              SizedBox(
                width: 90,
                child: Text(
                  label,
                  style:  TextStyle(
                    color:
                        Get.theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),

              Expanded(
                child: SelectableText(
                  displayValue,
                  style: TextStyle(
                    color: displayValue ==
                            'غير محدد'
                        ? Get.theme.colorScheme.onSurfaceVariant
                        : Get.theme.colorScheme.onSurface,
                    fontSize: 11.5,
                    height: 1.4,
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
            color: Get.theme.colorScheme.onSurfaceVariant
                .withValues(
              alpha: 0.1,
            ),
          ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.actionYellow
            .withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: AppColors.actionYellow,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CompactEmptyMessage
    extends StatelessWidget {
  final IconData icon;
  final String message;

  const _CompactEmptyMessage({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Get.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: Get.theme.colorScheme.onSurfaceVariant
                .withValues(
              alpha: 0.7,
            ),
            size: 21,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              message,
              style:  TextStyle(
                color: Get.theme.colorScheme.onSurfaceVariant,
                fontSize: 11.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}