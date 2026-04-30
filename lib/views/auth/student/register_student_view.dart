import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/register_student_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/validators/app_validators.dart';
import 'package:jisr_platform/core/widgets/auth_header.dart';
import 'package:jisr_platform/core/widgets/jisr_primary_button.dart';
import 'package:jisr_platform/core/widgets/jisr_text_field.dart';

class RegisterStudentView extends GetView<RegisterStudentController> {
  const RegisterStudentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 35),

                  const AuthHeader(
  title: 'إنشاء حساب طالب',
  subtitle: 'أدخل بياناتك الأساسية للبدء في منصة جسور',
  logoSize: 95,
  titleFontSize: 26,
  spaceAfterLogo: 28,
),

                    const SizedBox(height: 38),

                    JisrTextField(
                      controller: controller.nameController,
                      hintText: 'الاسم الكامل',
                      icon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          AppValidators.requiredField(value, 'الاسم الكامل'),
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
                          onPressed: controller.isPasswordVisible.toggle,
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.primaryBlue.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),

                    Obx(
                      () => JisrTextField(
                        controller: controller.confirmPasswordController,
                        hintText: 'تأكيد كلمة المرور',
                        icon: Icons.verified_user_outlined,
                        obscureText:
                            !controller.isConfirmPasswordVisible.value,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          final passwordError =
                              AppValidators.password(value);

                          if (passwordError != null) {
                            return passwordError;
                          }

                          if (value != controller.passwordController.text) {
                            return 'كلمتا المرور غير متطابقتين';
                          }

                          return null;
                        },
                        suffixIcon: IconButton(
                          onPressed:
                              controller.isConfirmPasswordVisible.toggle,
                          icon: Icon(
                            controller.isConfirmPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.primaryBlue.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'سيتم إرسال رمز تحقق OTP إلى بريدك الإلكتروني.',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                   Obx(
  () => JisrPrimaryButton(
    text: 'إنشاء الحساب',
    isLoading: controller.isLoading.value,
    onPressed: controller.registerStudent,
  ),
),

                    const SizedBox(height: 34),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}