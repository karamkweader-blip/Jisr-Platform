import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class LoginController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future login() async {
    FocusManager.instance.primaryFocus?.unfocus();

    print('LOGIN BUTTON CLICKED');

    if (!(formKey.currentState?.validate() ?? false)) {
      print('LOGIN VALIDATION FAILED');
      return;
    }

    try {
      isLoading.value = true;

      final body = {
        'email': emailController.text.trim(),
        'password': passwordController.text,
      };

      print('LOGIN URL: ${ApiLinks.login}');
      print('LOGIN BODY: $body');

      final response = await http
          .post(
            Uri.parse(ApiLinks.login),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 35),
            onTimeout: () {
              throw Exception(
                'Login timeout: الباك تأخر بالرد، غالبًا إرسال OTP للإيميل عم يعلق',
              );
            },
          );
      print('LOGIN STATUS CODE: ${response.statusCode}');
      print('LOGIN RESPONSE BODY: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'تم',
          'تم تسجيل الدخول، تحقق من الرمز المرسل إلى بريدك',
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.toNamed(
          Routes.otpVerification,
          arguments: {'email': emailController.text.trim(), 'otpMode': 'login'},
        );
      } else {
        Get.snackbar(
          'فشل تسجيل الدخول',
          data['message']?.toString() ?? response.body,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('LOGIN ERROR: $e');

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
