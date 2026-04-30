import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class ResetPasswordController extends GetxController {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  final isLoading = false.obs;

  void resetPassword() async {
    if (passwordController.text.length < 6) {
      JisrSnackbar.show(
        title: 'خطأ',
        message: 'كلمة المرور ضعيفة',
        type: JisrSnackbarType.error,
      );
      return;
    }

    if (passwordController.text != confirmController.text) {
      JisrSnackbar.show(
        title: 'خطأ',
        message: 'كلمتا المرور غير متطابقتين',
        type: JisrSnackbarType.error,
      );
      return;
    }

    isLoading.value = true;

    await Future.delayed(const Duration(seconds: 1));

    isLoading.value = false;

    JisrSnackbar.show(
      title: 'تم بنجاح',
      message: 'تم تغيير كلمة المرور',
      type: JisrSnackbarType.success,
    );

    Get.offAllNamed(Routes.login);
  }
}