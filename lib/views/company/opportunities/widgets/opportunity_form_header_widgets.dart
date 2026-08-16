part of '../company_opportunity_form_view.dart';

class _OpportunityHero extends StatelessWidget {
  final String type;
  final bool isEditing;

  const _OpportunityHero({required this.type, required this.isEditing});

  @override
  Widget build(BuildContext context) {
    final isJob = type == 'job';
    final isInternship = type == 'internship';
    final title = isEditing
        ? isJob
            ? 'تعديل فرصة العمل'
            : 'تعديل فرصة التدريب'
        : isJob
            ? 'أنشئ فرصة عمل واضحة وجاذبة'
            : isInternship
                ? 'قدّم تجربة تدريبية ذات أثر'
                : 'ابدأ بتحديد نوع الفرصة';
    final description = isJob
        ? 'عرّف الدور والمسؤوليات والتعويض ليسهل على المرشح المناسب اتخاذ قراره.'
        : isInternship
            ? 'وضّح ما سيتعلمه المتدرب والمهارات المطلوبة والمكافأة المتاحة.'
            : 'اختر بين وظيفة وتدريب، وسيتكيّف النموذج مع اختيارك.';
    final icon = isJob
        ? Icons.work_rounded
        : isInternship
            ? Icons.school_rounded
            : Icons.route_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.20)),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.86),
                    fontSize: 11.5,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
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

class _FormSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? action;

  const _FormSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7EDF2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF163047).withOpacity(0.045),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 41,
                height: 41,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: AppColors.primaryBlue, size: 21),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 11.3,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: 6),
                action!,
              ],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _OpportunityTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const _OpportunityTypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final job = _TypeCard(
      value: 'job',
      title: 'وظيفة',
      subtitle: 'منصب ومسؤوليات ضمن فريق الشركة',
      icon: Icons.work_outline_rounded,
      color: AppColors.primaryBlue,
      selected: selectedType == 'job',
      onTap: onChanged,
    );
    final internship = _TypeCard(
      value: 'internship',
      title: 'تدريب',
      subtitle: 'تجربة تعليمية لبناء الخبرة العملية',
      icon: Icons.school_outlined,
      color: AppColors.actionYellow,
      selected: selectedType == 'internship',
      onTap: onChanged,
    );

    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.maxWidth < 330) {
          return Column(
            children: [
              job,
              const SizedBox(height: 10),
              internship,
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: job),
              const SizedBox(width: 10),
              Expanded(child: internship),
            ],
          ),
        );
      },
    );
  }
}

class _TypeCard extends StatelessWidget {
  final String value;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool selected;
  final ValueChanged<String> onTap;

  const _TypeCard({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(value),
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.08) : AppColors.background,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected ? color : const Color(0xFFE0E8EE),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 39,
                    height: 39,
                    decoration: BoxDecoration(
                      color: selected ? color : color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: selected ? Colors.white : color,
                      size: 21,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: selected ? color : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? color : const Color(0xFFB8C4CE),
                      ),
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14,
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: selected ? color : AppColors.textDark,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 10.7,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

