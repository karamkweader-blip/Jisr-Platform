import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/login_otp_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/auth_header.dart';
import 'package:jisr_platform/core/widgets/jisr_primary_button.dart';
import 'package:pinput/pinput.dart';

class LoginOtpView extends GetView<LoginOtpController> {
  const LoginOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 55,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryBlue,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    );

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

                  const SizedBox(height: 40),

                  /// 🔥 مربعات OTP
                  Pinput(
                    controller: controller.otpController,
                    length: 6,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(
                          color: AppColors.primaryBlue,
                          width: 1.5,
                        ),
                      ),
                    ),
                    submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(
                          color: AppColors.actionYellow,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onCompleted: (_) {
                      print('OTP COMPLETED');
                    },
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
