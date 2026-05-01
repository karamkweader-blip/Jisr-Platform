import 'dart:async';

import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';

class OtpVerificationController extends GetxController {
  final otp = ''.obs;
  final isLoading = false.obs;
  final seconds = 45.obs;

  Timer? _timer;
  late final String email;

  bool get canResend => seconds.value == 0;

  @override
  void onInit() {
    super.onInit();
    email = Get.arguments?['email'] ?? '';
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    seconds.value = 45;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds.value > 0) {
        seconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> resendCode() async {
    if (!canResend) return;

    JisrSnackbar.show(
      title: 'تم الإرسال',
      message: 'تم إعادة إرسال رمز التحقق إلى بريدك الإلكتروني',
      type: JisrSnackbarType.success,
    );

    startTimer();
  }

  Future verifyOtp() async {
    if (otp.value.length != 6) {
      JisrSnackbar.show(
        title: 'رمز غير مكتمل',
        message: 'يرجى إدخال رمز التحقق المكون من 6 أرقام',
        type: JisrSnackbarType.error,
      );
      return;
    }

    try {
      isLoading.value = true;

      final body = {'email': email, 'code': otp.value};

      print('VERIFY OTP BUTTON CLICKED');
      print('VERIFY OTP URL: ${ApiLinks.verifyLoginOtp}');
      print('VERIFY OTP BODY: $body');

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

      print('VERIFY OTP STATUS CODE: ${response.statusCode}');
      print('VERIFY OTP RESPONSE BODY: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        JisrSnackbar.show(
          title: 'تم تسجيل الدخول',
          message: 'تم التحقق من الرمز بنجاح',
          type: JisrSnackbarType.success,
        );

        // مؤقتاً لسا ما عنا Home
        // Get.offAllNamed(Routes.home);
      } else {
        JisrSnackbar.show(
          title: 'فشل التحقق',
          message: data['message']?.toString() ?? response.body,
          type: JisrSnackbarType.error,
        );
      }
    } catch (e) {
      print('VERIFY OTP ERROR: $e');

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
    _timer?.cancel();
    super.onClose();
  }
}
