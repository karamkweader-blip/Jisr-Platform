import 'dart:async';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:jisr_platform/controllers/app_theme_controller.dart';
import 'package:jisr_platform/controllers/auth/auth_actions_controller.dart';
import 'package:jisr_platform/controllers/company/company_main_controller.dart';
import 'package:jisr_platform/controllers/company/profile/company_profile_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyDrawerController extends GetxController {
  static const String contactEmail =
      'karamalah.kweader@gmail.com';

  static const String appVersion = '1.0.0';

  static const String _languagePreferenceKey =
      'company_language';

  final AuthActionsController authController;
  final CompanyMainController mainController;
  final CompanyProfileController profileController;
  final AppThemeController themeController;

  CompanyDrawerController({
    required this.authController,
    required this.mainController,
    required this.profileController,
    required this.themeController,
  });

  final RxString languageCode = 'ar'.obs;
  final Rx<DateTime> currentTime = DateTime.now().obs;

  Timer? _clockTimer;

  bool get isDarkMode {
    return themeController.isDarkMode;
  }

  String get appearanceValue {
    return themeController.appearanceValue;
  }

  String get languageLabel {
    return languageCode.value == 'ar'
        ? 'العربية'
        : 'English';
  }

  String get appearanceLabel {
    return isDarkMode
        ? 'الوضع الداكن'
        : 'الوضع النهاري';
  }

  String get formattedTime {
    final value = currentTime.value;

    final hour = value.hour % 12 == 0
        ? 12
        : value.hour % 12;

    final minute = value.minute
        .toString()
        .padLeft(2, '0');

    final period = value.hour >= 12 ? 'م' : 'ص';

    return '$hour:$minute $period';
  }

  String get formattedDate {
    const weekDays = <String>[
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    const months = <String>[
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    final value = currentTime.value;
    final weekDay = weekDays[value.weekday - 1];
    final month = months[value.month - 1];

    return '$weekDay، ${value.day} $month ${value.year}';
  }

  @override
  void onInit() {
    super.onInit();

    _loadLanguagePreference();

    _clockTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        currentTime.value = DateTime.now();
      },
    );
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    super.onClose();
  }

  Future<void> _loadLanguagePreference() async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      final savedLanguage = preferences.getString(
        _languagePreferenceKey,
      );

      if (savedLanguage != 'ar' &&
          savedLanguage != 'en') {
        return;
      }

      languageCode.value = savedLanguage!;

      Get.updateLocale(
        Locale(savedLanguage),
      );
    } catch (_) {
      languageCode.value = 'ar';
    }
  }

  Future<void> changeLanguage(String code) async {
    if (code != 'ar' && code != 'en') {
      return;
    }

    final previousLanguage = languageCode.value;

    languageCode.value = code;
    Get.updateLocale(Locale(code));

    try {
      final preferences =
          await SharedPreferences.getInstance();

      await preferences.setString(
        _languagePreferenceKey,
        code,
      );
    } catch (_) {
      languageCode.value = previousLanguage;
      Get.updateLocale(Locale(previousLanguage));

      Get.snackbar(
        'تعذر تغيير اللغة',
        'حدث خطأ أثناء حفظ اختيار اللغة.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> changeAppearance(String value) async {
    try {
      await themeController.changeTheme(value);
    } catch (_) {
      Get.snackbar(
        'تعذر تغيير المظهر',
        'حدث خطأ أثناء تغيير مظهر التطبيق.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void openProfile() {
    mainController.changeTab(
      CompanyMainController.profilePageIndex,
    );
  }

  void refreshProfileInBackground() {
    if (profileController.isLoading.value) {
      return;
    }

    profileController.fetchProfile();
  }

  Future<void> openContactEmail() async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: contactEmail,
      queryParameters: const <String, String>{
        'subject': 'تواصل من منصة جسور',
      },
    );

    try {
      final opened = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        _showEmailError();
      }
    } catch (_) {
      _showEmailError();
    }
  }

  void _showEmailError() {
    Get.snackbar(
      'تعذر فتح البريد',
      'يمكنك التواصل يدويًا عبر $contactEmail',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> logout({
    required bool logoutAllSessions,
  }) {
    return authController.companyLogout(
      logoutAllSessions: logoutAllSessions,
    );
  }
}