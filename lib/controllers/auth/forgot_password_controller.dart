import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final message = await _forgotPasswordService.sendOtp(
        emailController.text.trim(),
      );

      JisrSnackbar.show(
        title: 'تم إرسال الرمز',
        message: message,
        type: JisrSnackbarType.success,
      );

      Get.toNamed(
        Routes.otpVerification,
        arguments: {
          'email': emailController.text.trim(),
        },
      );
    } catch (e) {
      JisrSnackbar.show(
        title: 'حدث خطأ',
        message: e.toString(),
        type: JisrSnackbarType.error,
      );
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