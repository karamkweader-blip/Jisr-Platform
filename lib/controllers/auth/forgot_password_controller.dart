import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/api/api_error_presenter.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/auth/forget&reset/forgot_password_service.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  final ForgotPasswordService _forgotPasswordService =
      ForgotPasswordService();

  Future<void> sendOtp() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      isLoading.value = true;

      await _forgotPasswordService.sendOtp(
        emailController.text.trim(),
      );

      JisrSnackbar.show(
        title: 'تم إرسال الرمز',
        message:
            'تم إرسال رمز التحقق إلى بريدك الإلكتروني.',
        type: JisrSnackbarType.success,
      );

      Get.toNamed(
        Routes.otpVerification,
        arguments: {
          'email': emailController.text.trim(),
        },
      );
    } catch (error) {
      ApiErrorPresenter.show(error);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}