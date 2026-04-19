import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    try {
      isLoading.value = true;

      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'تم',
        'تم تسجيل الدخول بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تسجيل الدخول',
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