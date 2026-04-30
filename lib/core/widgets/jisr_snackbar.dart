import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

enum JisrSnackbarType {
  success,
  error,
  warning,
  info,
}

class JisrSnackbar {
  static void show({
    required String title,
    required String message,
    required JisrSnackbarType type,
  }) {
    final config = _getConfig(type);

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: config.backgroundColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 18,
      duration: const Duration(seconds: 3),
      icon: Icon(
        config.icon,
        color: Colors.white,
      ),
      shouldIconPulse: false,
      boxShadows: [
        BoxShadow(
          color: config.backgroundColor.withOpacity(0.25),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
      titleText: Text(
        title,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
          fontFamily: 'Cairo',
        ),
      ),
      messageText: Text(
        message,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  static _SnackbarConfig _getConfig(JisrSnackbarType type) {
    switch (type) {
      case JisrSnackbarType.success:
        return _SnackbarConfig(
          backgroundColor: const Color(0xFF16A34A),
          icon: Icons.check_circle_outline,
        );
      case JisrSnackbarType.error:
        return _SnackbarConfig(
          backgroundColor: const Color(0xFFDC2626),
          icon: Icons.error_outline,
        );
      case JisrSnackbarType.warning:
        return _SnackbarConfig(
          backgroundColor: const Color(0xFFF59E0B),
          icon: Icons.warning_amber_rounded,
        );
      case JisrSnackbarType.info:
        return _SnackbarConfig(
          backgroundColor: AppColors.primaryBlue,
          icon: Icons.info_outline,
        );
    }
  }
}

class _SnackbarConfig {
  final Color backgroundColor;
  final IconData icon;

  _SnackbarConfig({
    required this.backgroundColor,
    required this.icon,
  });
}