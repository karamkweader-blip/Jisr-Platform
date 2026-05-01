import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/login_otp_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/auth_header.dart';
import 'package:jisr_platform/core/widgets/jisr_primary_button.dart';
import 'package:jisr_platform/core/widgets/jisr_text_field.dart';

class LoginOtpView extends GetView<LoginOtpController> {
  const LoginOtpView({super.key});

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
              child: Column(
                children: [
                  const SizedBox(height: 0.1),

                  const AuthHeader(
                    title: 'تحقق من الرمز',
                    subtitle: 'أدخل رمز التحقق المرسل إلى بريدك الإلكتروني',
                    logoSize: 95,
                    titleFontSize: 26,
                    spaceAfterLogo: 28,
                  ),

                  const SizedBox(height: 90),

                  Text(
                    controller.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 30),

                  JisrTextField(
                    controller: controller.otpController,
                    hintText: 'رمز التحقق',
                    icon: Icons.verified_outlined,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                  ),

                  const SizedBox(height: 50),

                  Obx(
                    () => JisrPrimaryButton(
                      text: 'تأكيد الرمز',
                      isLoading: controller.isLoading.value,
                      onPressed: () {
                        if (controller.isLoading.value) return;

                        print('LOGIN OTP VIEW BUTTON PRESSED');
                        controller.verifyLoginOtp();
                      },
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
