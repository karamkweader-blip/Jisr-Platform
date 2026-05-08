import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/auth/auth_service.dart';

class AuthActionsController extends GetxController {
  final AuthService _authService = AuthService();

  final isLoading = false.obs;

  Future<void> logout() async {
    final confirm = await _showConfirmDialog(
      title: 'تسجيل الخروج',
      message: 'هل أنت متأكد من تسجيل الخروج؟',
      confirmColor: AppColors.primaryBlue,
    );

    if (!confirm) return;

    await _handleAuthAction(
      request: _authService.logout,
      successTitle: 'تم تسجيل الخروج',
      fallbackSuccessMessage: 'تم تسجيل خروجك بنجاح',
      errorTitle: 'فشل تسجيل الخروج',
    );
  }

  Future<void> logoutAllSessions() async {
    final confirm = await _showConfirmDialog(
      title: 'إنهاء جميع الجلسات',
      message: 'هل أنت متأكد من إنهاء جميع الجلسات على كل الأجهزة؟',
      confirmColor: AppColors.actionYellow,
    );

    if (!confirm) return;

    await _handleAuthAction(
      request: _authService.logoutAllSessions,
      successTitle: 'تم إنهاء الجلسات',
      fallbackSuccessMessage: 'تم إنهاء جميع الجلسات بنجاح',
      errorTitle: 'فشل إنهاء الجلسات',
    );
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required Color confirmColor,
  }) async {
    final result = await Get.dialog<bool>(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(color: AppColors.textDark, fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text(
                'لا',
                style: TextStyle(color: AppColors.textGrey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Get.back(result: true),
              child: const Text('نعم', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    return result == true;
  }

  Future<void> _handleAuthAction({
    required Future<Map<String, dynamic>> Function() request,
    required String successTitle,
    required String fallbackSuccessMessage,
    required String errorTitle,
  }) async {
    try {
      isLoading.value = true;

      final response = await request();

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        await _authService.removeToken();

        Get.offAllNamed(Routes.login);

        Get.snackbar(
          successTitle,
          response['data']['message']?.toString() ?? fallbackSuccessMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          errorTitle,
          response['data']['message']?.toString() ?? 'حدث خطأ',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('خطأ', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
