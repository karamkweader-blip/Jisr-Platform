import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/login_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/validators/app_validators.dart';
import 'package:jisr_platform/core/widgets/auth_header.dart';
import 'package:jisr_platform/core/widgets/jisr_primary_button.dart';
import 'package:jisr_platform/core/widgets/jisr_text_field.dart';
import 'package:jisr_platform/routes/app_routes.dart';
class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                const AuthHeader(
  title: 'مرحباً بك مجدداً',
  subtitle: 'سجل دخولك للمتابعة في منصة جسور',
  logoSize: 100,
  titleFontSize: 28,
  spaceAfterLogo: 30,
),

                const SizedBox(height: 45),

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
                    textInputAction: TextInputAction.done,
                    validator: AppValidators.password,
                    suffixIcon: IconButton(
                      onPressed: controller.togglePasswordVisibility,
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.primaryBlue.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => Get.toNamed(Routes.forgotPassword),
                    child: const Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),
Obx(
  () => JisrPrimaryButton(
    text: 'تسجيل الدخول',
    isLoading: controller.isLoading.value,
    onPressed: controller.login
   
  ),
),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                   
                    TextButton(
                      onPressed: () {
                        Get.toNamed(Routes.role);
                      },
                      child: const Text(
                        'أنشئ حسابك الآن',
                        style: TextStyle(
                          color: AppColors.actionYellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                     const Text(
                      'ليس لديك حساب؟',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}