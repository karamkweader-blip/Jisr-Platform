import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LoginController extends GetxController {

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  
  var isPasswordVisible = false.obs;
  var isLoading = false.obs;

  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("خطأ", "يرجى ملء جميع الحقول", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading(true);
    await Future.delayed(const Duration(seconds: 2));
    isLoading(false);
    
    // Get.offAllNamed(Routes.home);
  }
}