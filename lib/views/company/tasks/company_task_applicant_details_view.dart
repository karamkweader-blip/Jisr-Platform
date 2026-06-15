import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/tasks/company_task_applicant_details_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/tasks/company_task_applicant_details_model.dart';

class CompanyTaskApplicantDetailsView
    extends GetView<CompanyTaskApplicantDetailsController> {
  const CompanyTaskApplicantDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const _ApplicantDetailsLoading();
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return _ApplicantDetailsError(
                message: controller.errorMessage.value,
                onRetry: controller.fetchApplicantDetails,
              );
            }

            final details = controller.applicantDetails.value;

            if (details == null) {
              return _ApplicantDetailsError(
                message: 'لا توجد بيانات لعرضها',
                onRetry: controller.fetchApplicantDetails,
              );
            }

            return RefreshIndicator(
              color: AppColors.primaryBlue,
              onRefresh: controller.refreshApplicantDetails,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                      child: _ApplicantTopBar(
                        studentName: details.student.displayName,
                        taskTitle: details.task.title,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: _ApplicantHeaderCard(
                        details: details,
                        statusLabel: controller.applicationStatusLabel(
                          details.application.status,
                        ),
                        difficultyLabel: controller.difficultyLabel(
                          details.task.difficultyLevel,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          _ApplicationMessageCard(
                            application: details.application,
                            appliedAt: controller.formatDate(
                              details.application.appliedAt,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _RequiredSkillsSection(controller: controller),
                          const SizedBox(height: 16),
                          _StudentSkillsSection(details: details),
                          const SizedBox(height: 16),
                          _MatchingReasonsSection(details: details),
                          const SizedBox(height: 16),
                          _PortfolioProjectsSection(
                            details: details,
                            formatDate: controller.formatDate,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        bottomNavigationBar: Obx(() {
          final details = controller.applicantDetails.value;

          if (details == null || !details.application.isPending) {
            return const SizedBox.shrink();
          }

          return _DecisionBottomBar(
  notesController: controller.companyNotesController,
  decisionType: controller.decisionType.value,
  notesError: controller.notesError.value,
  decisionMessage: controller.decisionMessage.value,
  isAccepting: controller.isAccepting.value,
  isRejecting: controller.isRejecting.value,
  onStartAccept: controller.startAcceptDecision,
  onStartReject: controller.startRejectDecision,
  onSubmit: controller.submitDecision,
  onCancel: controller.cancelDecision,
);
        }),
      ),
    );
  }
}

class _ApplicantTopBar extends StatelessWidget {
  final String studentName;
  final String taskTitle;

  const _ApplicantTopBar({
    required this.studentName,
    required this.taskTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: Get.back,
            borderRadius: BorderRadius.circular(16),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تفاصيل المتقدم',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$studentName · $taskTitle',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ApplicantHeaderCard extends StatelessWidget {
  final CompanyTaskApplicantDetailsModel details;
  final String statusLabel;
  final String difficultyLabel;

  const _ApplicantHeaderCard({
    required this.details,
    required this.statusLabel,
    required this.difficultyLabel,
  });

  @override
  Widget build(BuildContext context) {
    final score = details.matching.score.round();
    final imageUrl = details.student.profile.user.profilePictureUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _ApplicantAvatar(
                name: details.student.displayName,
                imageUrl: imageUrl,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.student.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.cardWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      details.student.profile.user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.cardWhite.withOpacity(0.82),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _ScoreBadge(score: score),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeaderInfoChip(
                  icon: Icons.assignment_turned_in_outlined,
                  label: 'الحالة',
                  value: statusLabel,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderInfoChip(
                  icon: Icons.speed_rounded,
                  label: 'الصعوبة',
                  value: difficultyLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _HeaderInfoChip(
                  icon: Icons.code_rounded,
                  label: 'المهارات',
                  value: '${details.student.skills.length}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderInfoChip(
                  icon: Icons.work_outline_rounded,
                  label: 'المشاريع',
                  value: '${details.student.portfolioProjects.length}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApplicantAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _ApplicantAvatar({
    required this.name,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 32,
        backgroundImage: NetworkImage(imageUrl!),
      );
    }

    final firstLetter = name.trim().isNotEmpty ? name.trim()[0] : 'ط';

    return CircleAvatar(
      radius: 32,
      backgroundColor: AppColors.cardWhite.withOpacity(0.18),
      child: Text(
        firstLetter,
        style: const TextStyle(
          color: AppColors.cardWhite,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final value = score.clamp(0, 100) / 100;

    return SizedBox(
      width: 66,
      height: 66,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 5,
            backgroundColor: AppColors.cardWhite.withOpacity(0.18),
            color: AppColors.actionYellow,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score%',
                style: const TextStyle(
                  color: AppColors.cardWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'تطابق',
                style: TextStyle(
                  color: AppColors.cardWhite.withOpacity(0.82),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeaderInfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite.withOpacity(0.13),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.cardWhite.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.actionYellow,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.cardWhite.withOpacity(0.72),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.cardWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
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

class _ApplicationMessageCard extends StatelessWidget {
  final ApplicantApplicationModel application;
  final String appliedAt;

  const _ApplicationMessageCard({
    required this.application,
    required this.appliedAt,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'طلب التقديم',
      icon: Icons.description_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoLine(
            icon: Icons.calendar_month_outlined,
            label: 'تاريخ التقديم',
            value: appliedAt,
          ),
          if (application.githubUrl != null &&
              application.githubUrl!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoLine(
              icon: Icons.link_rounded,
              label: 'GitHub',
              value: application.githubUrl!,
            ),
          ],
          const SizedBox(height: 14),
          Text(
            application.message.isEmpty
                ? 'لا توجد رسالة من الطالب.'
                : application.message,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 13,
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequiredSkillsSection extends StatelessWidget {
  final CompanyTaskApplicantDetailsController controller;

  const _RequiredSkillsSection({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final details = controller.applicantDetails.value!;

    return _SectionCard(
      title: 'مطابقة المهارات المطلوبة',
      icon: Icons.rule_rounded,
      child: Column(
        children: details.task.requiredSkills.map((requiredSkill) {
          final matchedSkill = controller.matchedStudentSkill(requiredSkill);

          return _RequiredSkillTile(
            requiredSkill: requiredSkill,
            matchedSkill: matchedSkill,
            requiredLevelLabel: controller.skillLevelLabel(
              requiredSkill.requiredLevel,
            ),
            studentLevelLabel: matchedSkill == null
                ? 'غير موجودة'
                : controller.skillLevelLabel(matchedSkill.proficiencyLevel),
          );
        }).toList(),
      ),
    );
  }
}

class _RequiredSkillTile extends StatelessWidget {
  final ApplicantRequiredSkillModel requiredSkill;
  final ApplicantStudentSkillModel? matchedSkill;
  final String requiredLevelLabel;
  final String studentLevelLabel;

  const _RequiredSkillTile({
    required this.requiredSkill,
    required this.matchedSkill,
    required this.requiredLevelLabel,
    required this.studentLevelLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isMatched = matchedSkill != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isMatched
            ? AppColors.primaryBlue.withOpacity(0.06)
            : AppColors.actionYellow.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isMatched
              ? AppColors.primaryBlue.withOpacity(0.10)
              : AppColors.actionYellow.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isMatched ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            color: isMatched ? AppColors.primaryBlue : AppColors.actionYellow,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  requiredSkill.name,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'المطلوب: $requiredLevelLabel · الطالب: $studentLevelLabel',
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (requiredSkill.mandatory)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.actionYellow.withOpacity(0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'إلزامية',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StudentSkillsSection extends StatelessWidget {
  final CompanyTaskApplicantDetailsModel details;

  const _StudentSkillsSection({
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    if (details.student.skills.isEmpty) {
      return const _SectionCard(
        title: 'مهارات الطالب',
        icon: Icons.psychology_outlined,
        child: _EmptySectionText('لا توجد مهارات مسجلة لهذا الطالب.'),
      );
    }

    return _SectionCard(
      title: 'مهارات الطالب',
      icon: Icons.psychology_outlined,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: details.student.skills.map((skill) {
          return _SkillChip(skill: skill);
        }).toList(),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final ApplicantStudentSkillModel skill;

  const _SkillChip({
    required this.skill,
  });

  @override
  Widget build(BuildContext context) {
    final confidence = (skill.confidenceScore * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '${skill.name} · مستوى ${skill.proficiencyLevel} · $confidence%',
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MatchingReasonsSection extends StatelessWidget {
  final CompanyTaskApplicantDetailsModel details;

  const _MatchingReasonsSection({
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    if (details.matching.reasons.isEmpty) {
      return const _SectionCard(
        title: 'أسباب التطابق',
        icon: Icons.auto_awesome_rounded,
        child: _EmptySectionText('لا توجد أسباب تطابق متاحة.'),
      );
    }

    return _SectionCard(
      title: 'أسباب التطابق',
      icon: Icons.auto_awesome_rounded,
      child: Column(
        children: details.matching.reasons.map((reason) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.primaryBlue,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reason,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PortfolioProjectsSection extends StatelessWidget {
  final CompanyTaskApplicantDetailsModel details;
  final String Function(DateTime? date) formatDate;

  const _PortfolioProjectsSection({
    required this.details,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    if (details.student.portfolioProjects.isEmpty) {
      return const _SectionCard(
        title: 'مشاريع البورتفوليو',
        icon: Icons.workspaces_outline,
        child: _EmptySectionText('لا توجد مشاريع بورتفوليو لهذا الطالب.'),
      );
    }

    return _SectionCard(
      title: 'مشاريع البورتفوليو',
      icon: Icons.workspaces_outline,
      child: Column(
        children: details.student.portfolioProjects.map((project) {
          return _ProjectTile(
            project: project,
            completionDate: formatDate(project.completionDate),
          );
        }).toList(),
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  final ApplicantPortfolioProjectModel project;
  final String completionDate;

  const _ProjectTile({
    required this.project,
    required this.completionDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (project.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              project.description,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SmallInfoChip(
                label: 'التاريخ: $completionDate',
                icon: Icons.calendar_month_outlined,
              ),
              if (project.grade != null)
                _SmallInfoChip(
                  label: 'التقييم: ${project.grade}',
                  icon: Icons.star_border_rounded,
                ),
              if (project.projectUrl != null && project.projectUrl!.isNotEmpty)
                _SmallInfoChip(
                  label: 'رابط المشروع',
                  icon: Icons.link_rounded,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryBlue,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SmallInfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SmallInfoChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySectionText extends StatelessWidget {
  final String text;

  const _EmptySectionText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textGrey,
        fontSize: 13,
        height: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _DecisionBottomBar extends StatelessWidget {
  final TextEditingController notesController;
  final String decisionType;
  final String notesError;
  final String decisionMessage;
  final bool isAccepting;
  final bool isRejecting;
  final VoidCallback onStartAccept;
  final VoidCallback onStartReject;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const _DecisionBottomBar({
    required this.notesController,
    required this.decisionType,
    required this.notesError,
    required this.decisionMessage,
    required this.isAccepting,
    required this.isRejecting,
    required this.onStartAccept,
    required this.onStartReject,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isBusy = isAccepting || isRejecting;
    final isWritingNotes = decisionType.isNotEmpty;
    final isAcceptMode = decisionType == 'accept';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: isWritingNotes
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAcceptMode ? 'ملاحظات القبول' : 'ملاحظات الرفض',
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      textDirection: TextDirection.rtl,
                      enabled: !isBusy,
                      decoration: InputDecoration(
                        hintText: isAcceptMode
                            ? 'اكتب ملاحظة القبول...'
                            : 'اكتب سبب الرفض أو ملاحظة داخلية...',
                        errorText: notesError.isEmpty ? null : notesError,
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.textGrey.withOpacity(0.18),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.textGrey.withOpacity(0.18),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isBusy ? null : onCancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textDark,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('إلغاء'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isBusy ? null : onSubmit,
                            icon: isBusy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.cardWhite,
                                    ),
                                  )
                                : Icon(
                                    isAcceptMode
                                        ? Icons.check_rounded
                                        : Icons.close_rounded,
                                  ),
                            label: Text(
                              isBusy
                                  ? 'جاري التنفيذ...'
                                  : isAcceptMode
                                      ? 'تأكيد القبول'
                                      : 'تأكيد الرفض',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAcceptMode
                                  ? AppColors.primaryBlue
                                  : AppColors.actionYellow,
                              foregroundColor: isAcceptMode
                                  ? AppColors.cardWhite
                                  : AppColors.textDark,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (decisionMessage.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          decisionMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isBusy ? null : onStartReject,
                            icon: const Icon(Icons.close_rounded),
                            label: const Text('رفض'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textDark,
                              side: BorderSide(
                                color: AppColors.textGrey.withOpacity(0.25),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isBusy ? null : onStartAccept,
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('قبول'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: AppColors.cardWhite,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
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
class _ApplicantDetailsLoading extends StatelessWidget {
  const _ApplicantDetailsLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryBlue,
      ),
    );
  }
}

class _ApplicantDetailsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ApplicantDetailsError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: Get.back,
                borderRadius: BorderRadius.circular(16),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.actionYellow,
                  size: 44,
                ),
                const SizedBox(height: 12),
                const Text(
                  'تعذر تحميل تفاصيل المتقدم',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}