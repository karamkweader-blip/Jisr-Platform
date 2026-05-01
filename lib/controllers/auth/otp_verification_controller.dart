import 'dart:async';

import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/routes/app_routes.dart';

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

  Future<void> verifyOtp() async {
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

      await Future.delayed(const Duration(seconds: 1));

      Get.toNamed(Routes.resetPassword);
    } catch (_) {
      JisrSnackbar.show(
        title: 'حدث خطأ',
        message: 'تعذر التحقق من الرمز، حاول مرة أخرى',
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
