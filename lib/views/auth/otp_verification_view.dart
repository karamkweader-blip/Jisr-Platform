import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:jisr_platform/controllers/auth/otp_verification_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/auth_header.dart';
import 'package:jisr_platform/core/widgets/jisr_primary_button.dart';

class OtpVerificationView extends GetView<OtpVerificationController> {
  const OtpVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.18),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 42),

                const AuthHeader(
                  title: 'تحقق من بريدك',
                  subtitle: 'أدخل رمز التحقق المرسل إلى بريدك الإلكتروني',
                  logoSize: 76,
                  titleFontSize: 24,
                  spaceAfterLogo: 22,
                ),

                const SizedBox(height: 34),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'تم إرسال الرمز إلى',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        controller.email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 26),

                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Pinput(
                          length: 6,
                          defaultPinTheme: defaultTheme,
                          focusedPinTheme: defaultTheme.copyWith(
                            decoration: defaultTheme.decoration!.copyWith(
                              color: Colors.white,
                              border: Border.all(
                                color: AppColors.primaryBlue,
                                width: 1.6,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withOpacity(0.10),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                          ),
                          submittedPinTheme: defaultTheme.copyWith(
                            decoration: defaultTheme.decoration!.copyWith(
                              border: Border.all(
                                color: AppColors.primaryBlue.withOpacity(0.45),
                              ),
                            ),
                          ),
                          onChanged: (value) => controller.otp.value = value,
                        ),
                      ),

                      const SizedBox(height: 22),

                      Obx(
                        () => AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: controller.canResend
                              ? TextButton.icon(
                                  key: const ValueKey('resend_button'),
                                  onPressed: controller.resendCode,
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    color: AppColors.actionYellow,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    'إعادة إرسال الرمز',
                                    style: TextStyle(
                                      color: AppColors.actionYellow,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Container(
                                  key: const ValueKey('timer_box'),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primaryBlue.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    'إعادة الإرسال بعد ${controller.seconds.value} ثانية',
                                    style: const TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Obx(
                  () => JisrPrimaryButton(
                    text: 'تحقق من الرمز',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.verifyOtp,
                  ),
                ),

                const SizedBox(height: 24),

                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'تعديل البريد الإلكتروني',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}