import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeController extends GetxController {
  static const String _themePreferenceKey = 'app_theme_mode';

  // مفاتيح النسخة القديمة لاستخدامها مرة واحدة أثناء الترحيل.
  static const String _companyThemePreferenceKey =
      'company_appearance';

  static const String _studentThemePreferenceKey =
      'student_appearance';

  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  bool get isDarkMode {
    return themeMode.value == ThemeMode.dark;
  }

  String get appearanceValue {
    return isDarkMode ? 'dark' : 'light';
  }

  Future<AppThemeController> initialize() async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      final savedTheme =
          preferences.getString(_themePreferenceKey) ??
          preferences.getString(_companyThemePreferenceKey) ??
          preferences.getString(_studentThemePreferenceKey);

      themeMode.value = _parseThemeMode(savedTheme);

      // توحيد الإعداد القديم تحت مفتاح عام للتطبيق.
      await preferences.setString(
        _themePreferenceKey,
        appearanceValue,
      );
    } catch (_) {
      themeMode.value = ThemeMode.light;
    }

    return this;
  }

  Future<void> changeTheme(String value) async {
    if (value != 'light' && value != 'dark') {
      return;
    }

    final newThemeMode = _parseThemeMode(value);

    if (newThemeMode == themeMode.value) {
      return;
    }

    themeMode.value = newThemeMode;
    Get.changeThemeMode(newThemeMode);

    try {
      final preferences =
          await SharedPreferences.getInstance();

      await preferences.setString(
        _themePreferenceKey,
        value,
      );
    } catch (_) {
      Get.snackbar(
        'تعذر حفظ المظهر',
        'تم تغيير المظهر مؤقتاً، لكن تعذر حفظ اختيارك.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleTheme() {
    return changeTheme(
      isDarkMode ? 'light' : 'dark',
    );
  }

  ThemeMode _parseThemeMode(String? value) {
    return value == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light;
  }
}