import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/register_company_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class RegisterCompanyStepThree
    extends GetView<RegisterCompanyController> {
  const RegisterCompanyStepThree({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'ملف التوثيق',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'قم برفع ملف ترخيص الشركة أو السجل التجاري',
          style: TextStyle(
            fontSize: 14,
            color:
                colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 28,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius:
                BorderRadius.circular(24),
            border: Border.all(
              color:
                  colorScheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black
                        .withOpacity(0.18)
                    : AppColors.primaryBlue
                        .withOpacity(0.05),
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
                  color: AppColors.primaryBlue
                      .withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  size: 36,
                  color:
                      AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'ارفع ملف التوثيق',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: controller.pickFile,
                icon: const Icon(
                  Icons.attach_file_rounded,
                  color:
                      AppColors.primaryBlue,
                ),
                label: const Text(
                  'اختيار ملف',
                  style: TextStyle(
                    color:
                        AppColors.primaryBlue,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                style:
                    OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  side: BorderSide(
                    color: AppColors.primaryBlue
                        .withOpacity(0.16),
                  ),
                  backgroundColor: theme
                      .scaffoldBackgroundColor,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => Text(
                  controller.selectedFilePath
                              .value ==
                          null
                      ? 'لم يتم اختيار ملف'
                      : 'تم اختيار ملف التوثيق',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme
                        .onSurfaceVariant,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}