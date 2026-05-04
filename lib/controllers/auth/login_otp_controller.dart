import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/auth/auth_service.dart';
import 'package:jisr_platform/services/home/home_service.dart';

class LoginOtpController extends GetxController {
  final otpController = TextEditingController();

  final isLoading = false.obs;
  late final String email;

  @override
  void onInit() {
    super.onInit();
    email = Get.arguments?['email'] ?? '';
    print('LOGIN OTP EMAIL: $email');
  }

  Future verifyLoginOtp() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final code = otpController.text.trim();

    print('VERIFY LOGIN OTP BUTTON CLICKED');

    if (code.length != 6) {
      JisrSnackbar.show(
        title: 'رمز غير مكتمل',
        message: 'يرجى إدخال رمز التحقق المكون من 6 أرقام',
        type: JisrSnackbarType.error,
      );
      return;
    }

    try {
      isLoading.value = true;

      final body = {'email': email, 'code': code};

      print('VERIFY LOGIN OTP URL: ${ApiLinks.verifyLoginOtp}');
      print('VERIFY LOGIN OTP BODY: $body');

      final response = await http
          .post(
            Uri.parse(ApiLinks.verifyLoginOtp),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Verify OTP timeout');
            },
          );

      print('VERIFY LOGIN OTP STATUS CODE: ${response.statusCode}');
      print('VERIFY LOGIN OTP RESPONSE BODY: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['token'] != null) {
          await AuthService().saveToken(data['token']);
          print('TOKEN SAVED: ${data['token']}');
        } else {
          print('NO TOKEN IN VERIFY OTP RESPONSE');
        }

        Get.offAllNamed(Routes.home);
      } else {
        JisrSnackbar.show(
          title: 'فشل التحقق',
          message: data['message']?.toString() ?? response.body,
          type: JisrSnackbarType.error,
        );
      }
    } catch (e) {
      print('VERIFY LOGIN OTP ERROR: $e');

      JisrSnackbar.show(
        title: 'خطأ',
        message: e.toString(),
        type: JisrSnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}
