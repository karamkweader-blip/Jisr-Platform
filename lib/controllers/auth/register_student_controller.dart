import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class RegisterStudentController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;

  late final String role;

  @override
  void onInit() {
    super.onInit();
    role = Get.arguments?['role'] ?? 'student';
  }

  Future registerStudent() async {
    FocusManager.instance.primaryFocus?.unfocus();

    print('REGISTER BUTTON CLICKED');

    if (!(formKey.currentState?.validate() ?? false)) {
      print('VALIDATION FAILED');
      return;
    }

    try {
      isLoading.value = true;

      final body = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'password_confirmation': confirmPasswordController.text,
        'role': role,
      };

      print('REGISTER URL: ${ApiLinks.register}');
      print('REGISTER BODY: $body');

      final response = await http
          .post(
            Uri.parse(ApiLinks.register),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timeout: الخادم ما رد خلال 15 ثانية');
            },
          );

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.offAllNamed(Routes.login);

        Get.snackbar(
          'تم إنشاء الحساب بنجاح',
          'قم الآن بتسجيل الدخول',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'فشل إنشاء الحساب',
          data['message']?.toString() ?? response.body,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('REGISTER ERROR: $e');

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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
