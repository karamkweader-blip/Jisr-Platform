import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class RegisterCompanyStepThree extends StatelessWidget {
  const RegisterCompanyStepThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ملف التوثيق',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'يمكنك رفع ملف توثيق الشركة الآن أو إضافته لاحقًا بعد إنشاء الحساب.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textGrey,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  size: 36,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'ارفع ملف التوثيق',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'الملف اختياري في هذه المرحلة.\nيمكن دعمه لاحقًا بصيغة PDF أو صورة.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGrey,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.attach_file_rounded,
                  color: AppColors.primaryBlue,
                ),
                label: const Text(
                  'اختيار ملف',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  side: BorderSide(
                    color: AppColors.primaryBlue.withOpacity(0.16),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: AppColors.background,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}