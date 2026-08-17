import 'package:flutter/material.dart';
import 'package:jisr_platform/controllers/company/opportunities/company_opportunities_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class OpportunitiesHeader extends StatelessWidget {
  final VoidCallback onCreate;

  const OpportunitiesHeader({
    super.key,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الفرص',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'تابع المهام وفرص التدريب والعمل',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onCreate,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
        ),
      ],
    );
  }
}

class OpportunitiesSearchField extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  const OpportunitiesSearchField({
    super.key,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onSearchChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(
        color: AppColors.textDark,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: 'ابحث بعنوان الفرصة أو موقعها...',
        hintStyle: const TextStyle(
          color: AppColors.textGrey,
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.textGrey,
        ),
        filled: true,
        fillColor: AppColors.cardWhite,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.primaryBlue.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class OpportunitiesDisplayFilterPanel extends StatelessWidget {
  final CompanyOpportunityTypeFilter selectedType;
  final CompanyOpportunityStatusFilter selectedStatus;
  final ValueChanged<CompanyOpportunityTypeFilter> onTypeChanged;
  final VoidCallback onStatusPressed;

  const OpportunitiesDisplayFilterPanel({
    super.key,
    required this.selectedType,
    required this.selectedStatus,
    required this.onTypeChanged,
    required this.onStatusPressed,
  });

  @override
  Widget build(BuildContext context) {
    final hasStatusFilter =
        selectedStatus != CompanyOpportunityStatusFilter.all;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.dashboard_customize_outlined,
                  color: AppColors.primaryBlue,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خيارات العرض',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'اختر النوع والحالة',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: hasStatusFilter
                    ? AppColors.primaryBlue
                    : AppColors.background,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: onStatusPressed,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: hasStatusFilter
                            ? AppColors.primaryBlue
                            : AppColors.primaryBlue.withOpacity(0.09),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_alt_outlined,
                          size: 18,
                          color: hasStatusFilter
                              ? Colors.white
                              : AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 6),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الحالة',
                              style: TextStyle(
                                color: hasStatusFilter
                                    ? Colors.white70
                                    : AppColors.textGrey,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              selectedStatus.label,
                              style: TextStyle(
                                color: hasStatusFilter
                                    ? Colors.white
                                    : AppColors.textDark,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: hasStatusFilter
                              ? Colors.white
                              : AppColors.primaryBlue,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          OpportunitiesTypeSelector(
            selectedType: selectedType,
            onChanged: onTypeChanged,
          ),
        ],
      ),
    );
  }
}

class OpportunitiesTypeSelector extends StatelessWidget {
  final CompanyOpportunityTypeFilter selectedType;
  final ValueChanged<CompanyOpportunityTypeFilter> onChanged;

  const OpportunitiesTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: CompanyOpportunityTypeFilter.values.map((type) {
          final isSelected = selectedType == type;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 2,
              ),
              child: Material(
                color: isSelected
                    ? AppColors.primaryBlue
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: isSelected
                      ? null
                      : () {
                          onChanged(type);
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Text(
                      type.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class OpportunitiesSectionTitle extends StatelessWidget {
  final String title;
  final int count;

  const OpportunitiesSectionTitle({
    super.key,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
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
            color: AppColors.primaryBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}