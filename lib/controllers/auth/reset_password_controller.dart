import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/login_controller.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/auth/forget&reset/password_reset_service.dart';

class ResetPasswordController extends GetxController {
  final PasswordResetService _passwordResetService = PasswordResetService();

  final formKey = GlobalKey<FormState>();

  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  final isLoading = false.obs;

  late final String token;

  @override
  void onInit() {
    super.onInit();
    token = Get.arguments?['token'] ?? '';
  }

  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    if (token.isEmpty) {
      JisrSnackbar.show(
        title: 'خطأ',
        message: 'انتهت صلاحية الجلسة، يرجى إعادة المحاولة',
        type: JisrSnackbarType.error,
      );
      Get.offAllNamed(Routes.login);
      return;
    }

    try {
      isLoading.value = true;

      await _passwordResetService.resetPassword(
        token: token,
        newPassword: passwordController.text,
        newPasswordConfirmation: confirmController.text,
      );

      JisrSnackbar.show(
        title: 'تم بنجاح',
        message: 'تم تغيير كلمة المرور، يمكنك تسجيل الدخول الآن',
        type: JisrSnackbarType.success,
      );
if (Get.isRegistered<LoginController>()) {
  Get.find<LoginController>().clearFields();
}
Get.until((route) => route.settings.name == Routes.login);

    } catch (_) {
      JisrSnackbar.show(
        title: 'تعذر تغيير كلمة المرور',
        message: 'حدث خطأ أثناء تغيير كلمة المرور، حاول مرة أخرى',
        type: JisrSnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى تأكيد كلمة المرور';
    }

    if (value.trim() != passwordController.text.trim()) {
      return 'كلمتا المرور غير متطابقتين';
    }

    return null;
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmController.dispose();
    super.onClose();
  }
}