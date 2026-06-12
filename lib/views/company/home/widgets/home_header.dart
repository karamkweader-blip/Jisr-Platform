import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/company_home_model.dart';

class HomeHeader extends StatelessWidget {
  final CompanyHomeModel home;

  const HomeHeader({
    super.key,
    required this.home,
  });

  @override
  Widget build(BuildContext context) {
    final companyName = home.company.name.trim().isEmpty 
        ? 'شركتك' 
        : home.company.name.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مرحباً، $companyName',
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          home.hasAnyActivity
              ? 'إليك ملخص نشاط شركتك اليوم'
              : 'ابدأ بنشر أول مهمة لاستقبال الطلاب المناسبين',
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}