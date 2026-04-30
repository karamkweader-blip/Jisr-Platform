import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;

  Future<void> sendOtp() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      await Future.delayed(const Duration(seconds: 1));

      JisrSnackbar.show(
        title: 'تم إرسال الرمز',
        message: 'تحقق من بريدك الإلكتروني لإدخال رمز التحقق',
        type: JisrSnackbarType.success,
      );

      Get.toNamed(
        Routes.otpVerification,
        arguments: {
          'email': emailController.text.trim(),
        },
      );
    } catch (_) {
      JisrSnackbar.show(
        title: 'حدث خطأ',
        message: 'تعذر إرسال رمز التحقق، حاول مرة أخرى',
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