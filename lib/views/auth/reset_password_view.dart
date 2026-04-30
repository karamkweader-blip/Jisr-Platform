import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/reset_password_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/auth_header.dart';
import 'package:jisr_platform/core/widgets/jisr_primary_button.dart';
import 'package:jisr_platform/core/widgets/jisr_text_field.dart';

class ResetPasswordView extends GetView<ResetPasswordController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 55),

                const AuthHeader(
                  title: 'كلمة مرور جديدة',
                  subtitle: 'اختر كلمة مرور آمنة لحسابك',
                  logoSize: 80,
                ),

                const SizedBox(height: 25),
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.primaryBlue.withOpacity(0.06),
    borderRadius: BorderRadius.circular(18),
  ),
  child: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'نصائح لكلمة مرور قوية',
        style: TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 12),
      _PasswordHint(text: 'استخدم 6 أحرف على الأقل'),
      _PasswordHint(text: 'اجمع بين أحرف وأرقام إن أمكن'),
      _PasswordHint(text: 'تجنب استخدام كلمة مرور قديمة'),
    ],
  ),
),

                const SizedBox(height: 25),

                JisrTextField(
                  controller: controller.passwordController,
                  hintText: 'كلمة المرور',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),

                JisrTextField(
                  controller: controller.confirmController,
                  hintText: 'تأكيد كلمة المرور',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),

                const SizedBox(height: 45),

                Obx(
                  () => JisrPrimaryButton(
                    text: 'تغيير كلمة المرور',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.resetPassword,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _PasswordHint extends StatelessWidget {
  final String text;

  const _PasswordHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 17,
            color: Color(0xFF16A34A),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}





