import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/register_company_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/auth_header.dart';
import 'package:jisr_platform/core/widgets/register_step_action_button.dart';
import 'package:jisr_platform/core/widgets/step_indicator.dart';
import 'package:jisr_platform/views/auth/company/company-components/register_company_step_one.dart';
import 'package:jisr_platform/views/auth/company/company-components/register_company_step_three.dart';
import 'package:jisr_platform/views/auth/company/company-components/register_company_step_two.dart';


class RegisterCompanyView extends GetView<RegisterCompanyController> {
  const RegisterCompanyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 18),
              const AuthHeader(
  title: 'إنشاء حساب شركة',
  subtitle: 'أكمل الخطوات التالية لإنشاء حساب شركتك على منصة جسور.',
  logoWithContainer: true,
  logoContainerSize: 78,
  logoSize: 58,
  titleFontSize: 24,
  spaceAfterLogo: 18,
),
              const SizedBox(height: 24),
              Obx(
                () => StepIndicator(
                  current: controller.currentStep.value,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: PageView(
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    children: const [
                      SingleChildScrollView(
                        child: RegisterCompanyStepOne(),
                      ),
                      SingleChildScrollView(
                        child: RegisterCompanyStepTwo(),
                      ),
                      SingleChildScrollView(
                        child: RegisterCompanyStepThree(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Obx(
                () => Row(
                  children: [
                    if (controller.currentStep.value > 0)
                      Expanded(
                        child: RegisterStepActionButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.prevStep(),
                          label: 'رجوع',
                          isPrimary: false,
                          icon: Icons.arrow_back_rounded,
                        ),
                      ),
                    if (controller.currentStep.value > 0)
                      const SizedBox(width: 12),
                    Expanded(
                      flex: controller.currentStep.value > 0 ? 1 : 2,
                      child: RegisterStepActionButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.currentStep.value == 2
                                ? () => controller.submit()
                                : () => controller.nextStep(),
                        label: controller.currentStep.value == 2
                            ? 'إرسال الطلب'
                            : 'التالي',
                        isPrimary: true,
                        isLoading: controller.isLoading.value,
                        icon: controller.currentStep.value == 2
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}