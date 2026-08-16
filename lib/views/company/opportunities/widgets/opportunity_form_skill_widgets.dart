import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_model.dart';

class OpportunitySkillCard extends StatelessWidget {
  final CompanyOpportunitySkill skill;
  final ValueChanged<bool> onMandatoryChanged;
  final ValueChanged<int> onLevelChanged;
  final ValueChanged<double> onWeightChanged;
  final VoidCallback onDelete;

  const OpportunitySkillCard({
    super.key,
    required this.skill,
    required this.onMandatoryChanged,
    required this.onLevelChanged,
    required this.onWeightChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE0E8EE),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  skill.name,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Text(
                'إلزامية',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
  value: skill.mandatory,
  activeColor: AppColors.primaryBlue,
  onChanged: onMandatoryChanged,
),
              IconButton(
                onPressed: onDelete,
                tooltip: 'حذف المهارة',
                visualDensity: VisualDensity.compact,
                color: const Color(0xFFC94141),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                ),
              ),
            ],
          ),
          const Divider(
            height: 18,
            color: Color(0xFFE0E8EE),
          ),
          OpportunitySkillSlider(
            title: 'المستوى المطلوب',
            label: '${skill.requiredLevel}%',
            value: skill.requiredLevel
                .toDouble()
                .clamp(0, 100)
                .toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            onChanged: (value) {
              onLevelChanged(value.round());
            },
          ),
          OpportunitySkillSlider(
            title: 'أهمية المهارة',
            label: skill.weight.toStringAsFixed(1),
            value: skill.weight.clamp(0.5, 5).toDouble(),
            min: 0.5,
            max: 5,
            divisions: 9,
            onChanged: onWeightChanged,
          ),
        ],
      ),
    );
  }
}

class OpportunitySkillSlider extends StatelessWidget {
  final String title;
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const OpportunitySkillSlider({
    super.key,
    required this.title,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 8,
            ),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 15,
            ),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppColors.primaryBlue,
            inactiveColor: const Color(0xFFDCE5EC),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class EmptyOpportunitySkills extends StatelessWidget {
  final VoidCallback onAdd;

  const EmptyOpportunitySkills({
    super.key,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 21,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E8EE),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: AppColors.primaryBlue,
            size: 31,
          ),
          const SizedBox(height: 8),
          const Text(
            'أضف مهارة واحدة على الأقل',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onAdd,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: const BorderSide(
                color: AppColors.primaryBlue,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(
              Icons.add_rounded,
              size: 18,
            ),
            label: const Text(
              'اختيار مهارة',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OpportunitySkillsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const OpportunitySkillsError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFC64040),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class SelectOpportunityTypePrompt extends StatelessWidget {
  const SelectOpportunityTypePrompt({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 27,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE4EBF1),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.touch_app,
            color: AppColors.primaryBlue,
            size: 34,
          ),
          SizedBox(height: 10),
          Text(
            'اختر وظيفة أو تدريب للمتابعة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'ستظهر الحقول بصياغة مناسبة للنوع الذي تختاره.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}