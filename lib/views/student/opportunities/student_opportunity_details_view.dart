import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/opportunities/student_opportunity_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/student/opportunities/student_opportunity_model.dart';

class StudentOpportunityDetailsView extends StatefulWidget {
  const StudentOpportunityDetailsView({super.key});

  @override
  State<StudentOpportunityDetailsView> createState() =>
      _StudentOpportunityDetailsViewState();
}

class _StudentOpportunityDetailsViewState
    extends State<StudentOpportunityDetailsView> {
  final StudentOpportunityController controller =
      Get.find<StudentOpportunityController>();

  @override
  void initState() {
    super.initState();

    final opportunityId = Get.arguments as int;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchOpportunityDetails(opportunityId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.primaryBlue),
          title: const Text(
            'تفاصيل الفرصة',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoadingDetails.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.actionYellow),
            );
          }

          final opportunity = controller.selectedOpportunity.value;

          if (opportunity == null) {
            return const Center(
              child: Text(
                'لم يتم العثور على الفرصة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textGrey,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
            child: Column(
              children: [
                _DetailsHero(opportunity: opportunity)
                    .animate()
                    .fadeIn(duration: 520.ms)
                    .slideY(begin: .20, curve: Curves.easeOutBack),

                const SizedBox(height: 16),

                _InfoCard(
                  icon: Icons.description_rounded,
                  title: 'وصف الفرصة',
                  value: opportunity.description,
                ).animate().fadeIn(delay: 90.ms).slideX(begin: .18),

                _InfoCard(
                  icon: Icons.business_rounded,
                  title: 'الشركة',
                  value:
                      '${controller.companyName(opportunity.company)}\n${opportunity.company.industry}',
                ).animate().fadeIn(delay: 150.ms).slideX(begin: .18),

                _InfoGrid(opportunity: opportunity)
                    .animate()
                    .fadeIn(delay: 210.ms)
                    .slideY(begin: .16),

                const SizedBox(height: 14),

                _SkillsSection(skills: opportunity.skills)
                    .animate()
                    .fadeIn(delay: 280.ms)
                    .slideY(begin: .18),

                _MatchedSkillsSection(skills: opportunity.matchedSkills)
                    .animate()
                    .fadeIn(delay: 350.ms)
                    .slideY(begin: .18),

                _ReasonsSection(reasons: opportunity.matchReasons)
                    .animate()
                    .fadeIn(delay: 420.ms)
                    .slideY(begin: .18),

                if (opportunity.missingMandatorySkills.isNotEmpty)
                  _MissingSkillsSection(
                    title: 'مهارات إلزامية ناقصة',
                    skills: opportunity.missingMandatorySkills,
                  ).animate().fadeIn(delay: 470.ms).slideY(begin: .18),

                if (opportunity.missingSkills.isNotEmpty)
                  _MissingSkillsSection(
                    title: 'مهارات ناقصة',
                    skills: opportunity.missingSkills,
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: .18),

                const SizedBox(height: 20),

                _ApplyOpportunityButton(opportunity: opportunity)
                    .animate()
                    .fadeIn(delay: 560.ms)
                    .slideY(begin: .22)
                    .scale(begin: const Offset(.96, .96)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _DetailsHero extends GetView<StudentOpportunityController> {
  final StudentOpportunityDetailsModel opportunity;

  const _DetailsHero({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryBlue, Color(0xFF0077B6)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.20),
            blurRadius: 24,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.14),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Icon(
                  opportunity.type == 'job'
                      ? Icons.work_rounded
                      : Icons.school_rounded,
                  color: AppColors.actionYellow,
                  size: 31,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.06, 1.06),
                    duration: 1700.ms,
                  ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.title,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      controller.companyName(opportunity.company),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white70,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroBadge(
                icon: Icons.auto_awesome_rounded,
                text: '${opportunity.matchScore}% تطابق',
              ),
              _HeroBadge(
                icon: Icons.category_rounded,
                text: controller.opportunityTypeLabel(opportunity.type),
              ),
              _HeroBadge(
                icon: Icons.event_rounded,
                text: controller.deadlineText(opportunity.deadline),
              ),
              _HeroBadge(
                icon: Icons.payments_rounded,
                text: controller.salaryRange(opportunity),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeroBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.14),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withOpacity(.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.actionYellow, size: 15),
          const SizedBox(width: 5),
          Text(
            text.isEmpty ? 'غير محدد' : text,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final shownValue = value.trim().isEmpty ? 'غير محدد' : value;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.actionYellow),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  shownValue,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textDark,
                    height: 1.55,
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

class _InfoGrid extends GetView<StudentOpportunityController> {
  final StudentOpportunityDetailsModel opportunity;

  const _InfoGrid({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 11,
      mainAxisSpacing: 11,
      childAspectRatio: 1.55,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _MiniInfoCard(
          icon: Icons.place_rounded,
          title: 'الموقع',
          value: opportunity.location,
        ),
        _MiniInfoCard(
          icon: Icons.trending_up_rounded,
          title: 'نوع التطابق',
          value: controller.matchLabel(opportunity.matchLabel),
        ),
        _MiniInfoCard(
          icon: Icons.people_alt_rounded,
          title: 'عدد المتقدمين',
          value: '${opportunity.applicationsCount}',
        ),
        _MiniInfoCard(
          icon: Icons.calendar_month_rounded,
          title: 'تاريخ النشر',
          value: controller.dateOnly(opportunity.postedAt),
        ),
      ],
    );
  }
}

class _MiniInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MiniInfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final shownValue = value.trim().isEmpty ? 'غير محدد' : value;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(.06)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.05),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.actionYellow, size: 24),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textGrey,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            shownValue,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillsSection extends StatelessWidget {
  final List<StudentOpportunitySkillModel> skills;

  const _SkillsSection({required this.skills});

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) return const SizedBox.shrink();

    return _SectionContainer(
      icon: Icons.psychology_rounded,
      title: 'المهارات المطلوبة',
      child: Column(
        children: skills.map((skill) => _RequiredSkillTile(skill: skill)).toList(),
      ),
    );
  }
}

class _RequiredSkillTile extends StatelessWidget {
  final StudentOpportunitySkillModel skill;

  const _RequiredSkillTile({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill.name,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  skill.category.isEmpty ? 'تصنيف غير محدد' : skill.category,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _TinyBadge(
            text: 'مستوى ${_prettyNumber(skill.requiredLevel)}',
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: 7),
          _TinyBadge(
            text: skill.mandatory ? 'إلزامية' : 'اختيارية',
            color: skill.mandatory ? AppColors.actionYellow : Colors.green,
          ),
        ],
      ),
    );
  }
}

class _MatchedSkillsSection extends StatelessWidget {
  final List<StudentOpportunityMatchedSkillModel> skills;

  const _MatchedSkillsSection({required this.skills});

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) return const SizedBox.shrink();

    return _SectionContainer(
      icon: Icons.verified_rounded,
      title: 'المهارات المتطابقة',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: skills.map((skill) {
          final isFull = skill.matchType == 'full';
          return _SkillChip(
            label:
                '${skill.name} · ${isFull ? 'كامل' : 'جزئي'} · ${_prettyNumber(skill.studentLevel)}',
            color: isFull ? Colors.green : AppColors.actionYellow,
          );
        }).toList(),
      ),
    );
  }
}

class _ReasonsSection extends StatelessWidget {
  final List<String> reasons;

  const _ReasonsSection({required this.reasons});

  @override
  Widget build(BuildContext context) {
    if (reasons.isEmpty) return const SizedBox.shrink();

    return _SectionContainer(
      icon: Icons.lightbulb_rounded,
      title: 'أسباب الترشيح',
      child: Column(
        children: reasons
            .map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.actionYellow,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reason,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textDark,
                          height: 1.55,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MissingSkillsSection extends StatelessWidget {
  final String title;
  final List<StudentOpportunityMissingSkillModel> skills;

  const _MissingSkillsSection({
    required this.title,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      icon: Icons.warning_rounded,
      title: title,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: skills.map((skill) {
          return _SkillChip(
            label: '${skill.name} · مطلوب ${_prettyNumber(skill.requiredLevel)}',
            color: Colors.redAccent,
          );
        }).toList(),
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionContainer({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 13),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.06),
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
              Icon(icon, color: AppColors.actionYellow),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.primaryBlue,
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }
}

class _TinyBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _TinyBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Cairo',
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SkillChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ApplyOpportunityButton extends GetView<StudentOpportunityController> {
  final StudentOpportunityDetailsModel opportunity;

  const _ApplyOpportunityButton({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final disabled = opportunity.alreadyApplied || !opportunity.canApply;
    final text = opportunity.alreadyApplied
        ? 'تم التقديم مسبقاً'
        : !opportunity.canApply
            ? 'غير متاحة للتقديم'
            : 'تقديم على الفرصة';

    return Obx(
      () => ElevatedButton.icon(
        onPressed: disabled || controller.isApplying.value
            ? null
            : () => controller.applyToOpportunity(opportunity.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          disabledBackgroundColor: AppColors.textGrey.withOpacity(.25),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        icon: controller.isApplying.value
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.send_rounded),
        label: Text(
          controller.isApplying.value ? 'جار إرسال الطلب...' : text,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

String _prettyNumber(double value) {
  if (value == value.roundToDouble()) return value.round().toString();
  return value.toStringAsFixed(1);
}
