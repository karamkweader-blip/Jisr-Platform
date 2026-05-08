import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/forgot_password_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/validators/app_validators.dart';
import 'package:jisr_platform/core/widgets/auth_header.dart';
import 'package:jisr_platform/core/widgets/jisr_primary_button.dart';
import 'package:jisr_platform/core/widgets/jisr_text_field.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                      const SizedBox(height: 65),

                  const AuthHeader(
                    title: 'استعادة كلمة المرور',
                    subtitle:
                        'أدخل بريدك الإلكتروني للمتابعة',
                    logoSize: 100,
                  ),
          
                  const SizedBox(height: 30),
          Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.primaryBlue.withOpacity(0.06),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: AppColors.primaryBlue.withOpacity(0.08),
    ),
  ),
  child: const Row(
    children: [
      Icon(
        Icons.mark_email_read_outlined,
        color: AppColors.primaryBlue,
      ),
      SizedBox(width: 12),
      Expanded(
        child: Text(
          'سنرسل رمز تحقق مكوّن من 6 أرقام إلى بريدك الإلكتروني. تأكد من إدخال البريد المرتبط بحسابك.',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ),
    ],
  ),
),
                  const SizedBox(height: 30),

                  JisrTextField(
                    controller: controller.emailController,
                    hintText: 'البريد الإلكتروني',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    validator: AppValidators.email,
                  ),
          
                  const SizedBox(height: 38),
          
                  Obx(
                    () => JisrPrimaryButton(
                      text: 'إرسال رمز التحقق',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.sendOtp,
                    ),
                  ),
          
                  const SizedBox(height: 60),
        
                  TextButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: 18,
                      color: AppColors.primaryBlue,
                    ),
                    label: const Text(
                      'العودة إلى تسجيل الدخول',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}