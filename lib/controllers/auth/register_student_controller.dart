import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterStudentController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;

  Future<void> registerStudent() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      isLoading.value = true;

      await Future.delayed(const Duration(milliseconds: 800));

      Get.snackbar(
        'نجاح',
        'تم إنشاء الحساب مبدئيًا، سيتم إرسال رمز التحقق إلى البريد الإلكتروني',
        snackPosition: SnackPosition.BOTTOM,
      );

      // TODO: API Register Student
      // TODO: Navigate to OTP page
      
//       if (Get.isRegistered<LoginController>()) {
//   Get.delete<LoginController>(force: true);
// }
// Get.offAllNamed(Routes.login);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إنشاء الحساب',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}