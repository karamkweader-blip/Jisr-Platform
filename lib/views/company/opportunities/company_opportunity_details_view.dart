import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/opportunities/company_opportunity_details_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_model.dart';

class CompanyOpportunityDetailsView
    extends GetView<CompanyOpportunityDetailsController> {
  const CompanyOpportunityDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final blueContainer = baseTheme.brightness == Brightness.dark
        ? const Color(0xFF123F5E)
        : const Color(0xFFDCEFFD);

    return Theme(
      data: baseTheme.copyWith(
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: AppColors.primaryBlue,
          onPrimary: Colors.white,
          primaryContainer: blueContainer,
          onPrimaryContainer: AppColors.primaryBlue,
          secondary: AppColors.primaryBlue,
          onSecondary: Colors.white,
          secondaryContainer: blueContainer,
          onSecondaryContainer: AppColors.primaryBlue,
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.close();
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Obx(() {
              final opportunity = controller.opportunity.value;

              if (controller.isLoading.value && opportunity == null) {
                return _LoadingView(onBack: controller.close);
              }

              if (controller.errorMessage.value.isNotEmpty &&
                  opportunity == null) {
                return _ErrorView(
                  message: controller.errorMessage.value,
                  onBack: controller.close,
                  onRetry: controller.fetchDetails,
                );
              }

              if (opportunity == null) {
                return _ErrorView(
                  message: 'لا توجد بيانات لعرضها',
                  onBack: controller.close,
                  onRetry: controller.fetchDetails,
                );
              }

              return RefreshIndicator(
                color: AppColors.primaryBlue,
                onRefresh: controller.fetchDetails,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  children: [
                    _TopBar(
                      opportunity: opportunity,
                      isBusy: controller.isChangingStatus.value,
                      onBack: controller.close,
                      onRefresh: controller.fetchDetails,
                      onEdit: controller.edit,
                      onPublish: controller.publish,
                      onClose: controller.closeOpportunity,
                      onCancel: controller.cancel,
                    ),
                    const SizedBox(height: 18),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.95, end: 1),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          alignment: Alignment.topCenter,
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: _OpportunityHeaderCard(
                        opportunity: opportunity,
                        typeLabel: controller.typeLabel(
                          opportunity.type,
                        ),
                        statusLabel: controller.statusLabel(
                          opportunity.status,
                        ),
                        salary: controller.salaryRange(opportunity),
                        deadline: controller.formatDate(
                          opportunity.deadline,
                        ),
                        isBusy: controller.isChangingStatus.value,
                        onPublish: controller.publish,
                        onCandidates: controller.openCandidates,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _StatusMessageCard(
                      opportunity: opportunity,
                      isBusy: controller.isChangingStatus.value,
                      onPublish: controller.publish,
                      onCandidates: controller.openCandidates,
                    ),
                    const SizedBox(height: 18),
                    _SectionCard(
                      icon: Icons.description_outlined,
                      title: 'وصف الفرصة',
                      children: [
                        Text(
                          opportunity.description.trim().isEmpty
                              ? 'لا يوجد وصف مضاف لهذه الفرصة.'
                              : opportunity.description,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 14,
                            height: 1.7,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _SectionCard(
                      icon: Icons.info_outline_rounded,
                      title: 'تفاصيل الفرصة',
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _InfoTile(
                              icon: Icons.location_on_outlined,
                              title: 'الموقع',
                              value: opportunity.location.trim().isEmpty
                                  ? 'غير محدد'
                                  : opportunity.location,
                            ),
                            _InfoTile(
                              icon: Icons.payments_outlined,
                              title: 'نطاق الراتب',
                              value: controller.salaryRange(
                                opportunity,
                              ),
                            ),
                            _InfoTile(
                              icon: Icons.event_outlined,
                              title: 'آخر موعد',
                              value: controller.formatDate(
                                opportunity.deadline,
                              ),
                            ),
                            _InfoTile(
                              icon: Icons.campaign_outlined,
                              title: 'تاريخ النشر',
                              value: controller.formatDate(
                                opportunity.postedAt,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _SkillsSection(
                      skills: opportunity.skills,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final CompanyOpportunityModel opportunity;
  final bool isBusy;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final VoidCallback onEdit;
  final VoidCallback onPublish;
  final VoidCallback onClose;
  final VoidCallback onCancel;

  const _TopBar({
    required this.opportunity,
    required this.isBusy,
    required this.onBack,
    required this.onRefresh,
    required this.onEdit,
    required this.onPublish,
    required this.onClose,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: onBack,
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تفاصيل الفرصة',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'إدارة ومراجعة معلومات الفرصة',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          enabled: !isBusy,
          color: AppColors.cardWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          onSelected: (value) {
            switch (value) {
              case 'refresh':
                onRefresh();
                break;

              case 'edit':
                onEdit();
                break;

              case 'publish':
                onPublish();
                break;

              case 'close':
                onClose();
                break;

              case 'cancel':
                onCancel();
                break;
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'refresh',
              child: _MenuItem(
                icon: Icons.refresh_rounded,
                label: 'تحديث البيانات',
              ),
            ),
            if (opportunity.canEdit)
              const PopupMenuItem(
                value: 'edit',
                child: _MenuItem(
                  icon: Icons.edit_outlined,
                  label: 'تعديل الفرصة',
                ),
              ),
            if (opportunity.canPublish)
              const PopupMenuItem(
                value: 'publish',
                child: _MenuItem(
                  icon: Icons.rocket_launch_outlined,
                  label: 'نشر الفرصة',
                ),
              ),
            if (opportunity.canClose)
              const PopupMenuItem(
                value: 'close',
                child: _MenuItem(
                  icon: Icons.lock_outline_rounded,
                  label: 'إغلاق الفرصة',
                ),
              ),
            if (opportunity.canCancel)
              const PopupMenuItem(
                value: 'cancel',
                child: _MenuItem(
                  icon: Icons.cancel_outlined,
                  label: 'إلغاء الفرصة',
                  destructive: true,
                ),
              ),
          ],
          child: _CircleIconButton(
            icon: isBusy
                ? Icons.hourglass_top_rounded
                : Icons.more_horiz_rounded,
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool destructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? Colors.red
        : AppColors.textDark;

    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: color,
        ),
        const SizedBox(width: 9),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleIconButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _OpportunityHeaderCard extends StatelessWidget {
  final CompanyOpportunityModel opportunity;
  final String typeLabel;
  final String statusLabel;
  final String salary;
  final String deadline;
  final bool isBusy;
  final VoidCallback onPublish;
  final VoidCallback onCandidates;

  const _OpportunityHeaderCard({
    required this.opportunity,
    required this.typeLabel,
    required this.statusLabel,
    required this.salary,
    required this.deadline,
    required this.isBusy,
    required this.onPublish,
    required this.onCandidates,
  });

  @override
  Widget build(BuildContext context) {
    final isDraft = opportunity.isDraft;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderPill(
                label: statusLabel,
              ),
              _HeaderPill(
                label: typeLabel,
                icon: opportunity.type == 'job'
                    ? Icons.work_outline_rounded
                    : Icons.school_outlined,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            opportunity.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              height: 1.35,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  opportunity.location.trim().isEmpty
                      ? 'الموقع غير محدد'
                      : opportunity.location,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _HeaderStat(
                  value: '${opportunity.applicationsCount}',
                  label: 'متقدم',
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _HeaderStat(
                  value: salary,
                  label: 'الراتب',
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _HeaderStat(
                  value: deadline,
                  label: 'آخر موعد',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: isDraft
                ? ElevatedButton.icon(
                    onPressed: isBusy ? null : onPublish,
                    icon: isBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textDark,
                            ),
                          )
                        : const Icon(
                            Icons.rocket_launch_outlined,
                          ),
                    label: Text(
                      isBusy
                          ? 'جاري التنفيذ...'
                          : 'نشر الفرصة',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.actionYellow,
                      foregroundColor: AppColors.textDark,
                      disabledBackgroundColor:
                          AppColors.actionYellow.withOpacity(0.65),
                      disabledForegroundColor:
                          AppColors.textDark,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: isBusy
                        ? null
                        : onCandidates,
                    icon: const Icon(
                      Icons.groups_2_outlined,
                    ),
                    label: Text(
                      opportunity.isPublished
                          ? 'مراجعة المرشحين'
                          : 'عرض المرشحين',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white60,
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.55),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _HeaderPill({
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 15,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;

  const _HeaderStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.white.withOpacity(0.20),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusMessageCard extends StatelessWidget {
  final CompanyOpportunityModel opportunity;
  final bool isBusy;
  final VoidCallback onPublish;
  final VoidCallback onCandidates;

  const _StatusMessageCard({
    required this.opportunity,
    required this.isBusy,
    required this.onPublish,
    required this.onCandidates,
  });

  @override
  Widget build(BuildContext context) {
    final status = opportunity.status;
    final isDraft = status == 'draft';
    final isPublished = status == 'published';

    final icon = isDraft
        ? Icons.lightbulb_outline_rounded
        : isPublished
            ? Icons.groups_2_outlined
            : status == 'closed'
                ? Icons.lock_outline_rounded
                : Icons.info_outline_rounded;

    final message = isDraft
        ? 'الفرصة محفوظة كمسودة. انشرها عندما تصبح المعلومات جاهزة ليتمكن الطلاب من التقديم.'
        : isPublished
            ? 'الفرصة منشورة وتستقبل الطلبات. يمكنك الآن مراجعة المرشحين ومتابعة طلباتهم.'
            : status == 'closed'
                ? 'تم إغلاق الفرصة وتوقّف استقبال الطلبات الجديدة، ويمكنك مراجعة الطلبات السابقة.'
                : 'هذه الفرصة ملغاة ولا تستقبل طلبات جديدة.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.actionYellow.withOpacity(0.26),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.actionYellow.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.actionYellow.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: AppColors.actionYellow,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 12.5,
                height: 1.55,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (isDraft || isPublished) ...[
            const SizedBox(width: 6),
            TextButton(
              onPressed: isBusy
                  ? null
                  : isDraft
                      ? onPublish
                      : onCandidates,
              child: Text(
                isDraft
                    ? 'نشر'
                    : 'المرشحون',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final width =
        (MediaQuery.sizeOf(context).width - 86) / 2;

    return Container(
      width: width,
      constraints: const BoxConstraints(
        minHeight: 116,
      ),
      padding: const EdgeInsets.all(14),
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
          Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 21,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 13.5,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillsSection extends StatelessWidget {
  final List<CompanyOpportunitySkill> skills;

  const _SkillsSection({
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.bolt_outlined,
      title: 'المهارات المطلوبة',
      children: [
        if (skills.isEmpty)
          const _EmptySkills()
        else
          ...skills.map(
            (skill) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SkillTile(
                skill: skill,
              ),
            ),
          ),
      ],
    );
  }
}

class _SkillTile extends StatelessWidget {
  final CompanyOpportunitySkill skill;

  const _SkillTile({
    required this.skill,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        skill.requiredLevel.clamp(0, 100) / 100.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.06),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.name,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'الوزن ${skill.weight.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: skill.mandatory
                      ? AppColors.actionYellow.withOpacity(0.13)
                      : AppColors.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  skill.mandatory
                      ? 'إلزامية'
                      : 'اختيارية',
                  style: TextStyle(
                    color: skill.mandatory
                        ? AppColors.actionYellow
                        : AppColors.primaryBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Text(
                'المستوى المطلوب ${skill.requiredLevel}%',
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    color: AppColors.primaryBlue,
                    backgroundColor:
                        AppColors.primaryBlue.withOpacity(0.10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptySkills extends StatelessWidget {
  const _EmptySkills();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.layers_clear_outlined,
            color: AppColors.textGrey,
            size: 32,
          ),
          SizedBox(height: 9),
          Text(
            'لا توجد مهارات مضافة لهذه الفرصة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  final VoidCallback onBack;

  const _LoadingView({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              _CircleIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: onBack,
              ),
              const SizedBox(width: 12),
              const Text(
                'تفاصيل الفرصة',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onBack,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              _CircleIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: onBack,
              ),
              const SizedBox(width: 12),
              const Text(
                'تفاصيل الفرصة',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 38,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.cloud_off_rounded,
                        color: AppColors.primaryBlue,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'تعذّر تحميل التفاصيل',
                      style: TextStyle(
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
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),
                      label: const Text(
                        'إعادة المحاولة',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
