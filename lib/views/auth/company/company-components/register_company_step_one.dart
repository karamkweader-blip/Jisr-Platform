import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/register_company_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/validators/app_validators.dart';
import 'package:jisr_platform/core/widgets/jisr_text_field.dart';


class RegisterCompanyStepOne extends GetView<RegisterCompanyController> {
  const RegisterCompanyStepOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.stepOneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'البيانات الأساسية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'أدخل معلومات الشركة الأساسية للبدء بإنشاء الحساب.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          JisrTextField(
            controller: controller.companyNameController,
            hintText: 'اسم الشركة',
            icon: Icons.business,
            textInputAction: TextInputAction.next,
            validator: AppValidators.companyName,
          ),
          JisrTextField(
            controller: controller.emailController,
            hintText: 'البريد الإلكتروني',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: AppValidators.email,
          ),
          Obx(
            () => JisrTextField(
              controller: controller.passwordController,
              hintText: 'كلمة المرور',
              icon: Icons.lock_outline,
              obscureText: !controller.isPasswordVisible.value,
              textInputAction: TextInputAction.next,
              validator: AppValidators.password,
              suffixIcon: IconButton(
                onPressed: controller.togglePasswordVisibility,
                icon: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          JisrTextField(
            controller: controller.phoneController,
            hintText: 'رقم الهاتف',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            validator: AppValidators.phone,
          ),
        ],
      ),
    );
  }
}