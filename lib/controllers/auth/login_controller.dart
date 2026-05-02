import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/models/auth/login_request.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/auth/login_service.dart';

class LoginController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final LoginService _loginService = LoginService();

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!(formKey.currentState?.validate() ?? false)) return;

    try {
      isLoading.value = true;

      final request = LoginRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final message = await _loginService.login(request);

      Get.snackbar(
        'تم',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.toNamed(
        Routes.loginOtp,
        arguments: {'email': emailController.text.trim()},
      );
    } catch (e) {
      Get.snackbar(
        'خطأ بالاتصال',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}