import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/auth/password_reset_service.dart';

class OtpVerificationController extends GetxController {
  final PasswordResetService _passwordResetService = PasswordResetService();

  final otp = ''.obs;
  final isLoading = false.obs;
  final isResending = false.obs;

  late final String email;

  @override
  void onInit() {
    super.onInit();
    email = Get.arguments?['email'] ?? '';
  }

  Future<void> resendCode() async {
    if (isResending.value) return;

    try {
      isResending.value = true;

      await _passwordResetService.resendOtp(email: email);

      JisrSnackbar.show(
        title: 'تم الإرسال',
        message: 'تم إرسال رمز تحقق جديد إلى بريدك الإلكتروني',
        type: JisrSnackbarType.success,
      );
    } catch (_) {
      JisrSnackbar.show(
        title: 'تعذر الإرسال',
        message: 'تعذر إعادة إرسال الرمز، حاول مرة أخرى',
        type: JisrSnackbarType.error,
      );
    } finally {
      isResending.value = false;
    }
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

      final token = await _passwordResetService.verifyOtp(
        email: email,
        code: otp.value,
      );

      Get.toNamed(
        Routes.resetPassword,
        arguments: {
          'email': email,
          'token': token,
        },
      );
    } catch (_) {
      JisrSnackbar.show(
        title: 'رمز غير صحيح',
        message: 'تعذر التحقق من الرمز، حاول مرة أخرى',
        type: JisrSnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}