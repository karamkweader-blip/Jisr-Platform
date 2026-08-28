import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/api/api_error_presenter.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/auth/login/login_otp_service.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/notifications/notification_service.dart';

class LoginOtpController extends GetxController {
  final TextEditingController otpController =
      TextEditingController();

  final RxBool isLoading = false.obs;

  final LoginOtpService _loginOtpService =
      LoginOtpService();

  late final String email;

  @override
  void onInit() {
    super.onInit();
    email = Get.arguments?['email'] ?? '';
  }

  Future<void> verifyLoginOtp() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final code = otpController.text.trim();

    if (code.length != 6) {
      JisrSnackbar.show(
        title: 'رمز غير مكتمل',
        message:
            'يرجى إدخال رمز التحقق المكون من 6 أرقام.',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    try {
      isLoading.value = true;

      final data = await _loginOtpService.verifyOtp(
        email: email,
        code: code,
      );

      final token = data['token']?.toString();
      final roleName = _extractUserRole(data);
      final userId = _extractUserId(data);

      if (token == null || token.trim().isEmpty) {
        JisrSnackbar.show(
          title: 'تعذر تسجيل الدخول',
          message:
              'لم يتم استلام رمز الدخول من الخادم. يرجى المحاولة مرة أخرى.',
          type: JisrSnackbarType.error,
        );
        return;
      }

      if (roleName == null) {
        JisrSnackbar.show(
          title: 'نوع الحساب غير معروف',
          message:
              'تعذر تحديد نوع حسابك. يرجى تسجيل الدخول مرة أخرى.',
          type: JisrSnackbarType.error,
        );
        return;
      }

      if (userId == null) {
        JisrSnackbar.show(
          title: 'تعذر تسجيل الدخول',
          message:
              'تعذر الحصول على بيانات المستخدم. يرجى المحاولة مرة أخرى.',
          type: JisrSnackbarType.error,
        );
        return;
      }

      await AuthService().saveAuthData(
        token: token,
        role: roleName,
        userId: userId,
      );

      await NotificationService.instance
          .syncDeviceToken();

      if (roleName == 'student') {
        Get.offAllNamed(Routes.studentHome);
        return;
      }

      if (roleName == 'company') {
        Get.offAllNamed(Routes.companyMain);
        return;
      }

      JisrSnackbar.show(
        title: 'نوع الحساب غير مدعوم',
        message:
            'هذا النوع من الحسابات غير متاح ضمن التطبيق.',
        type: JisrSnackbarType.error,
      );
    } catch (error) {
      ApiErrorPresenter.show(error);
    } finally {
      isLoading.value = false;
    }
  }

  String? _extractUserRole(
    Map<String, dynamic> data,
  ) {
    final user = data['user'];

    if (user is! Map) {
      return null;
    }

    final roles = user['roles'];

    if (roles is List && roles.isNotEmpty) {
      final firstRole = roles.first;

      if (firstRole is Map) {
        return firstRole['name']?.toString();
      }
    }

    return null;
  }

  int? _extractUserId(
    Map<String, dynamic> data,
  ) {
    final user = data['user'];

    if (user is! Map) {
      return null;
    }

    final rawId = user['id'];

    if (rawId is int) {
      return rawId;
    }

    return int.tryParse(
      rawId?.toString() ?? '',
    );
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}