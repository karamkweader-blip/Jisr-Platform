import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_details_model.dart';
import 'package:jisr_platform/views/company/tasks/widgets/assignments/assignment_match_score_indicator.dart';

class AssignmentOverviewSection extends StatelessWidget {
  final CompanyTaskAssignmentDetailsModel details;
  final String Function(String difficultyLevel) difficultyLabel;
  final String Function(DateTime? date) formatDate;

  const AssignmentOverviewSection({
    super.key,
    required this.details,
    required this.difficultyLabel,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final profile = details.student.profile;

    final profileItems = <MapEntry<String, String>>[];

    if (profile.university != null) {
      profileItems.add(MapEntry('الجامعة', profile.university!));
    }

    if (profile.major != null) {
      profileItems.add(MapEntry('التخصص', profile.major!));
    }

    if (profile.graduationYear != null) {
      profileItems.add(MapEntry('سنة التخرج', profile.graduationYear!));
    }

    if (profile.phone != null) {
      profileItems.add(MapEntry('رقم الهاتف', profile.phone!));
    }

    return Column(
      children: [
        _SectionCard(
          title: 'تفاصيل المهمة',
          icon: Icons.assignment_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (details.task.description.trim().isNotEmpty)
                Text(
                  details.task.description,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12.5,
                    height: 1.65,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                const _EmptyInline(
                  message: 'لا يوجد وصف متاح لهذه المهمة.',
                ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.speed_rounded,
                      label: 'المستوى',
                      value: difficultyLabel(details.task.difficultyLevel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.calendar_month_outlined,
                      label: 'الموعد النهائي',
                      value: formatDate(details.task.deadline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.play_circle_outline_rounded,
                      label: 'بدأ التنفيذ',
                      value: formatDate(details.assignment.startedAt),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.assignment_turned_in_outlined,
                      label: 'التسليم',
                      value: formatDate(details.assignment.submittedAt),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (details.application.companyNotes != null) ...[
          _SectionCard(
            title: 'ملاحظات الشركة عند القبول',
            icon: Icons.sticky_note_2_outlined,
            child: Text(
              details.application.companyNotes!,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 12.5,
                height: 1.65,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        _SectionCard(
          title: 'المهارات المطلوبة',
          icon: Icons.workspace_premium_outlined,
          child: details.task.requiredSkills.isEmpty
              ? const _EmptyInline(
                  message: 'لا توجد مهارات مطلوبة مسجلة لهذه المهمة.',
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: details.task.requiredSkills.map((skill) {
                    return _RequiredSkillPill(
                      name: skill.name,
                      level: skill.requiredLevel,
                      mandatory: skill.mandatory,
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 16),

        if (profileItems.isNotEmpty) ...[
          _SectionCard(
            title: 'بيانات الطالب',
            icon: Icons.person_outline_rounded,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: profileItems.map((item) {
                return SizedBox(
                  width: (MediaQuery.sizeOf(context).width - 70) / 2,
                  child: _ProfileInfoTile(
                    label: item.key,
                    value: item.value,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        _SectionCard(
          title: 'مهارات الطالب',
          icon: Icons.psychology_alt_outlined,
          child: details.student.skills.isEmpty
              ? const _EmptyInline(
                  message: 'لا توجد مهارات مسجلة في ملف الطالب.',
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: details.student.skills.map((skill) {
                    return _StudentSkillPill(
                      name: skill.name,
                      level: skill.proficiencyLevel,
                      verified: skill.verified,
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 16),

        _SectionCard(
          title: 'المشاريع السابقة',
          icon: Icons.folder_copy_outlined,
          child: details.student.portfolioProjects.isEmpty
              ? const _EmptyInline(
                  message: 'لا توجد مشاريع سابقة في ملف الطالب.',
                )
              : Column(
                  children: details.student.portfolioProjects.map((project) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PortfolioProjectCard(
                        title: project.title,
                        description: project.description,
                        grade: project.grade,
                        completionDate: formatDate(project.completionDate),
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 16),

     _SectionCard(
  title: 'تحليل توافق المهارات',
  icon: Icons.hub_outlined,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AssignmentMatchScoreIndicator(
        score: details.matching.score,
      ),
      const SizedBox(height: 18),
      const Text(
        'تفاصيل التحليل',
        style: TextStyle(
          color: AppColors.textDark,
          fontSize: 12.5,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 11),
      if (details.matching.reasons.isEmpty)
        const _EmptyInline(
          message: 'لا توجد تفاصيل إضافية لتحليل توافق المهارات.',
        )
      else
        Column(
          children: details.matching.reasons.map((reason) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MatchingReasonItem(reason: reason),
            );
          }).toList(),
        ),
    ],
  ),
),
      ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(23),
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryBlue,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 17,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
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

class _RequiredSkillPill extends StatelessWidget {
  final String name;
  final int level;
  final bool mandatory;

  const _RequiredSkillPill({
    required this.name,
    required this.level,
    required this.mandatory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: mandatory
            ? AppColors.primaryBlue.withOpacity(0.10)
            : AppColors.actionYellow.withOpacity(0.13),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$name · مستوى $level${mandatory ? ' · أساسية' : ''}',
        style: TextStyle(
          color: mandatory ? AppColors.primaryBlue : AppColors.textDark,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileInfoTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentSkillPill extends StatelessWidget {
  final String name;
  final int level;
  final bool verified;

  const _StudentSkillPill({
    required this.name,
    required this.level,
    required this.verified,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.10),
        ),
      ),
      child: Text(
        '$name · مستوى $level${verified ? ' · موثقة' : ''}',
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PortfolioProjectCard extends StatelessWidget {
  final String title;
  final String description;
  final double? grade;
  final String completionDate;

  const _PortfolioProjectCard({
    required this.title,
    required this.description,
    required this.grade,
    required this.completionDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (description.trim().isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 11,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 9),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.primaryBlue,
                size: 14,
              ),
              const SizedBox(width: 5),
              Text(
                completionDate,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (grade != null)
                Text(
                  'الدرجة: ${grade!.toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatchingReasonItem extends StatelessWidget {
  final String reason;

  const _MatchingReasonItem({
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = _isNegativeReason(reason);
    final color = isNegative ? Colors.red : Colors.green;
    final icon = isNegative ? Icons.close_rounded : Icons.check_rounded;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 15,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            _arabicReasonOnly(reason),
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 11.5,
              height: 1.55,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

String _arabicReasonOnly(String reason) {
  final arabicPart = reason.split('|').first.trim();

  return arabicPart.isEmpty ? reason.trim() : arabicPart;
}

bool _isNegativeReason(String reason) {
  final normalized = reason.toLowerCase();

  return normalized.contains('غير موجود') ||
      normalized.contains('لا يمتلك') ||
      normalized.contains('غير متطابق') ||
      normalized.contains('غير متوافقة') ||
      normalized.contains('missing') ||
      normalized.contains('not match') ||
      normalized.contains('not found');
}

class _EmptyInline extends StatelessWidget {
  final String message;

  const _EmptyInline({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        color: AppColors.textGrey,
        fontSize: 12,
        height: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}