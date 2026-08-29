import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/search/company_search_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/company/Loading-Empty-Error/jisr_empty_state.dart';
import 'package:jisr_platform/core/widgets/company/Loading-Empty-Error/jisr_error_state.dart';
import 'package:jisr_platform/core/widgets/company/Loading-Empty-Error/jisr_loading_state.dart';
import 'package:jisr_platform/models/company/students/company_student_model.dart';

class CompanySearchView
    extends GetView<CompanySearchController> {
  const CompanySearchView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(() {
          final students = controller.students;

          return RefreshIndicator(
            color: AppColors.primaryBlue,
            onRefresh: controller.refresh,
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior
                      .onDrag,
              padding: const EdgeInsets.fromLTRB(
                18,
                14,
                18,
                125,
              ),
              children: <Widget>[
                const _SearchHero(),
                const SizedBox(height: 18),

                _StudentNameSearchField(
                  controller: controller,
                ),

                const SizedBox(height: 12),

                _SkillFilterTile(
                  label:
                      controller.selectedSkillLabel,
                  isSelected:
                      controller.selectedSkill.value !=
                          null,
                  isLoading:
                      controller.isLoadingSkills.value,
                  onTap: () {
                    _showSkillsSheet(context);
                  },
                  onClear:
                      controller.selectedSkill.value ==
                              null
                          ? null
                          : () {
                              controller
                                  .selectSkill(null);
                            },
                ),

                if (controller.skillsErrorMessage
                    .value.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  _InlineMessage(
                    message: controller
                        .skillsErrorMessage.value,
                    actionLabel: 'إعادة المحاولة',
                    onAction:
                        controller.fetchSkills,
                  ),
                ],

                if (controller
                    .hasActiveFilters) ...<Widget>[
                  const SizedBox(height: 10),
                  Align(
                    alignment: AlignmentDirectional
                        .centerStart,
                    child: TextButton.icon(
                      onPressed:
                          controller.isLoading.value
                              ? null
                              : controller.clearFilters,
                      icon: const Icon(
                        Icons
                            .filter_alt_off_rounded,
                        size: 17,
                      ),
                      label: const Text(
                        'مسح البحث والفلاتر',
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            AppColors.primaryBlue,
                        textStyle:
                            const TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],

                if (controller.isLoading.value &&
                    students.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.all(
                      Radius.circular(10),
                    ),
                    child: SizedBox(
                      height: 3,
                      child:
                          LinearProgressIndicator(
                        color:
                            AppColors.primaryBlue,
                        backgroundColor:
                            Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                // لا نعرض أي طالب قبل البحث.
                if (!controller.hasActiveFilters)
                  const JisrEmptyState(
                    icon:
                        Icons.manage_search_rounded,
                    title: 'ابدأ البحث عن طالب',
                    message:
                        'اكتب اسم الطالب أو اختر مهارة '
                        'لعرض النتائج المطابقة.',
                  )
                else ...<Widget>[
                  _ResultsHeader(
                    total: controller
                        .totalStudents.value,
                  ),

                  const SizedBox(height: 12),

                  if (controller.isLoading.value &&
                      students.isEmpty)
                    const SizedBox(
                      height: 280,
                      child: JisrLoadingState(
                        message:
                            'جاري البحث عن الطلاب...',
                      ),
                    )
                  else if (controller
                          .errorMessage
                          .value
                          .isNotEmpty &&
                      students.isEmpty)
                    JisrErrorState(
                      title:
                          'تعذّر البحث عن الطلاب',
                      message: controller
                          .errorMessage.value,
                      onRetry:
                          controller.fetchStudents,
                    )
                  else if (students.isEmpty)
                    JisrEmptyState(
                      icon: Icons
                          .person_search_rounded,
                      title:
                          'لا توجد نتائج مطابقة',
                      message:
                          'جرّب كتابة اسم آخر أو '
                          'اختيار مهارة مختلفة.',
                      actionText:
                          'مسح الفلاتر',
                      onActionPressed:
                          controller.clearFilters,
                    )
                  else ...<Widget>[
                    ...students.map(
                      (student) => Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: _StudentCard(
                          student: student,
                          onTap: () {
                            controller.openStudent(
                              student,
                            );
                          },
                        ),
                      ),
                    ),

                    if (controller.hasMore) ...<
                        Widget>[
                      const SizedBox(height: 4),
                      OutlinedButton.icon(
                        onPressed: controller
                                .isLoadingMore.value
                            ? null
                            : () {
                                controller
                                    .fetchStudents(
                                  loadMore: true,
                                );
                              },
                        icon: controller
                                .isLoadingMore.value
                            ? const SizedBox(
                                width: 17,
                                height: 17,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors
                                      .primaryBlue,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .expand_more_rounded,
                              ),
                        label: Text(
                          controller
                                  .isLoadingMore.value
                              ? 'جاري تحميل المزيد...'
                              : 'عرض المزيد',
                        ),
                        style:
                            OutlinedButton.styleFrom(
                          minimumSize:
                              const Size.fromHeight(
                            48,
                          ),
                          foregroundColor:
                              AppColors.primaryBlue,
                          side: BorderSide(
                            color: AppColors
                                .primaryBlue
                                .withValues(
                              alpha: 0.24,
                            ),
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              15,
                            ),
                          ),
                          textStyle:
                              const TextStyle(
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<void> _showSkillsSheet(
    BuildContext context,
  ) async {
    var query = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Theme.of(context).colorScheme.surface,
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
            child: SizedBox(
              height:
                  MediaQuery.sizeOf(sheetContext)
                          .height *
                      0.72,
              child: StatefulBuilder(
                builder:
                    (context, setSheetState) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      18,
                      10,
                      18,
                      16 +
                          MediaQuery.viewInsetsOf(
                            context,
                          ).bottom,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: Container(
                            width: 44,
                            height: 4,
                            decoration:
                                BoxDecoration(
                              color: Theme.of(
                                context,
                              )
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withValues(
                                alpha: 0.22,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 17),

                        Text(
                          'فلترة الطلاب حسب المهارة',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'اختر مهارة واحدة لعرض '
                          'الطلاب الذين يمتلكونها.',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            )
                                .colorScheme
                                .onSurfaceVariant,
                            fontSize: 12.5,
                            height: 1.45,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 14),

                        TextField(
                          textInputAction:
                              TextInputAction.search,
                          onChanged: (value) {
                            setSheetState(() {
                              query = value
                                  .trim()
                                  .toLowerCase();
                            });
                          },
                          decoration:
                              _fieldDecoration(
                            context,
                            hint:
                                'ابحث عن مهارة...',
                            icon: Icons
                                .manage_search_rounded,
                          ),
                        ),

                        const SizedBox(height: 13),

                        Expanded(
                          child: Obx(() {
                            if (controller
                                    .isLoadingSkills
                                    .value &&
                                controller
                                    .skills.isEmpty) {
                              return const JisrLoadingState(
                                message:
                                    'جاري تحميل المهارات...',
                              );
                            }

                            if (controller
                                    .skillsErrorMessage
                                    .value
                                    .isNotEmpty &&
                                controller
                                    .skills.isEmpty) {
                              return JisrErrorState(
                                title:
                                    'تعذّر تحميل المهارات',
                                message: controller
                                    .skillsErrorMessage
                                    .value,
                                onRetry: controller
                                    .fetchSkills,
                              );
                            }

                            final filteredSkills =
                                controller.skills
                                    .where(
                              (skill) {
                                if (query.isEmpty) {
                                  return true;
                                }

                                return skill.name
                                        .toLowerCase()
                                        .contains(
                                          query,
                                        ) ||
                                    skill.category
                                        .toLowerCase()
                                        .contains(
                                          query,
                                        );
                              },
                            ).toList();

                            return ListView(
                              physics:
                                  const BouncingScrollPhysics(),
                              children: <Widget>[
                                _SkillOption(
                                  title:
                                      'كل المهارات',
                                  subtitle:
                                      'إزالة فلتر المهارة',
                                  selected: controller
                                          .selectedSkill
                                          .value ==
                                      null,
                                  icon: Icons
                                      .people_alt_outlined,
                                  onTap: () {
                                    Navigator.pop(
                                      sheetContext,
                                    );

                                    controller
                                        .selectSkill(
                                      null,
                                    );
                                  },
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                if (filteredSkills
                                    .isEmpty)
                                  Padding(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      vertical: 38,
                                    ),
                                    child: Text(
                                      'لا توجد مهارة '
                                      'مطابقة للبحث.',
                                      textAlign:
                                          TextAlign
                                              .center,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        )
                                            .colorScheme
                                            .onSurfaceVariant,
                                        fontSize: 13,
                                        fontWeight:
                                            FontWeight
                                                .w600,
                                      ),
                                    ),
                                  )
                                else
                                  ...filteredSkills
                                      .map(
                                    (skill) =>
                                        Padding(
                                      padding:
                                          const EdgeInsets
                                              .only(
                                        bottom: 8,
                                      ),
                                      child:
                                          _SkillOption(
                                        title:
                                            skill.name,
                                        subtitle: skill
                                                .category
                                                .isEmpty
                                            ? 'مهارة'
                                            : skill
                                                .category,
                                        selected: controller
                                                .selectedSkill
                                                .value
                                                ?.id ==
                                            skill.id,
                                        icon: Icons
                                            .auto_awesome_rounded,
                                        onTap: () {
                                          Navigator
                                              .pop(
                                            sheetContext,
                                          );

                                          controller
                                              .selectSkill(
                                            skill,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SearchHero extends StatelessWidget {
  const _SearchHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primaryBlue.withValues(
              alpha: 0.16,
            ),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          _HeroIcon(),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'اكتشف المواهب المناسبة',
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'ابحث باسم الطالب أو اختر مهارة '
                  'للوصول إلى أصحاب الخبرات المناسبة.',
                  style: TextStyle(
                    color:
                        AppColors.onPrimaryMuted,
                    fontSize: 12.5,
                    height: 1.5,
                    fontWeight:
                        FontWeight.w600,
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

class _HeroIcon extends StatelessWidget {
  const _HeroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(
          alpha: 0.13,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.onPrimary.withValues(
            alpha: 0.16,
          ),
        ),
      ),
      child: const Icon(
        Icons.person_search_rounded,
        color: AppColors.actionYellow,
        size: 27,
      ),
    );
  }
}

class _StudentNameSearchField
    extends StatelessWidget {
  final CompanySearchController controller;

  const _StudentNameSearchField({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<
        TextEditingValue>(
      valueListenable:
          controller.nameController,
      builder: (context, value, _) {
        return TextField(
          controller:
              controller.nameController,
          onChanged:
              controller.onNameChanged,
          textInputAction:
              TextInputAction.search,
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onSurface,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
          decoration: _fieldDecoration(
            context,
            hint: 'ابحث باسم الطالب...',
            icon: Icons.search_rounded,
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'مسح الاسم',
                    onPressed:
                        controller.clearName,
                    icon: Icon(
                      Icons.close_rounded,
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _SkillFilterTile
    extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _SkillFilterTile({
    required this.label,
    required this.isSelected,
    required this.isLoading,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primaryBlue.withValues(
              alpha: 0.055,
            )
          : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 58,
          ),
          padding:
              const EdgeInsetsDirectional
                  .fromSTEB(
            14,
            10,
            10,
            10,
          ),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(17),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryBlue
                      .withValues(
                      alpha: 0.28,
                    )
                  : Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(
                        alpha: 0.14,
                      ),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.actionYellow
                          .withValues(
                          alpha: 0.14,
                        )
                      : AppColors.primaryBlue
                          .withValues(
                          alpha: 0.08,
                        ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: isSelected
                      ? AppColors.actionYellow
                      : AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisSize:
                      MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'المهارة',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        )
                            .colorScheme
                            .onSurfaceVariant,
                        fontSize: 10.5,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isLoading
                          ? 'جاري تحميل المهارات...'
                          : label,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors
                                .primaryBlue
                            : Theme.of(
                                context,
                              )
                                  .colorScheme
                                  .onSurface,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (onClear != null)
                IconButton(
                  tooltip:
                      'إزالة فلتر المهارة',
                  onPressed: onClear,
                  icon: Icon(
                    Icons.close_rounded,
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .onSurfaceVariant,
                    size: 20,
                  ),
                )
              else
                const Padding(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: Icon(
                    Icons
                        .keyboard_arrow_down_rounded,
                    color:
                        AppColors.primaryBlue,
                    size: 23,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  final int total;

  const _ResultsHeader({
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'نتائج البحث',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue
                .withValues(
              alpha: 0.07,
            ),
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Text(
            '$total طالب',
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _StudentCard extends StatelessWidget {
  final CompanyStudentModel student;
  final VoidCallback onTap;

  const _StudentCard({
    required this.student,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryBlue
                  .withValues(
                alpha: 0.075,
              ),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primaryBlue
                    .withValues(
                  alpha: 0.045,
                ),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              _StudentAvatar(
                name: student.name,
                imageUrl: student
                    .profilePictureUrl,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      student.name.isEmpty
                          ? 'طالب'
                          : student.name,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons
                              .alternate_email_rounded,
                          color: Theme.of(
                            context,
                          )
                              .colorScheme
                              .onSurfaceVariant,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            student.email.isEmpty
                                ? 'البريد غير متوفر'
                                : student.email,
                            maxLines: 1,
                            overflow: TextOverflow
                                .ellipsis,
                            textDirection:
                                TextDirection.ltr,
                            textAlign:
                                TextAlign.right,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              )
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 11.5,
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors
                      .actionYellow
                      .withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color:
                      AppColors.actionYellow,
                  size: 19,
                ),
              ),
            ],
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
    final letter = name.trim().isEmpty
        ? 'ط'
        : name.trim().characters.first;

    final fallback =
        _InitialAvatar(letter: letter);

    if (imageUrl == null ||
        imageUrl!.isEmpty) {
      return fallback;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imageUrl!,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return fallback;
        },
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String letter;

  const _InitialAvatar({
    required this.letter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        letter,
        style: const TextStyle(
          color: AppColors.onPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SkillOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  const _SkillOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primaryBlue.withValues(
              alpha: 0.07,
            )
          : Theme.of(context)
              .scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16),
          side: BorderSide(
            color: selected
                ? AppColors.primaryBlue
                    .withValues(
                    alpha: 0.2,
                  )
                : Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(
                      alpha: 0.08,
                    ),
          ),
        ),
        leading: Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.actionYellow
                    .withValues(
                    alpha: 0.14,
                  )
                : AppColors.primaryBlue
                    .withValues(
                    alpha: 0.07,
                  ),
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: selected
                ? AppColors.actionYellow
                : AppColors.primaryBlue,
            size: 19,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected
                ? AppColors.primaryBlue
                : Theme.of(context)
                    .colorScheme
                    .onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          selected
              ? Icons.check_circle_rounded
              : Icons.circle_outlined,
          color: selected
              ? AppColors.primaryBlue
              : Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(
                    alpha: 0.35,
                  ),
          size: 21,
        ),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _InlineMessage({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsetsDirectional.fromSTEB(
        12,
        8,
        8,
        8,
      ),
      decoration: BoxDecoration(
        color: AppColors.actionYellow.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.actionYellow,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface,
                fontSize: 11,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

InputDecoration _fieldDecoration(
  BuildContext context, {
  required String hint,
  required IconData icon,
  Widget? suffixIcon,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(17),
    borderSide: BorderSide(
      color: Theme.of(context)
          .colorScheme
          .onSurfaceVariant
          .withValues(
            alpha: 0.14,
          ),
    ),
  );

  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: Theme.of(context)
          .colorScheme
          .onSurfaceVariant,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    prefixIcon: Icon(
      icon,
      color: AppColors.primaryBlue,
      size: 21,
    ),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor:
        Theme.of(context).colorScheme.surface,
    contentPadding:
        const EdgeInsets.symmetric(
      horizontal: 15,
      vertical: 15,
    ),
    enabledBorder: border,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: const BorderSide(
        color: AppColors.primaryBlue,
        width: 1.4,
      ),
    ),
  );
}