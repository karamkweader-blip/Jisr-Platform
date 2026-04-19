import 'package:get/get.dart';

class AppValidators {
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }

    if (!GetUtils.isEmail(value.trim())) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }

    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال رقم الهاتف';
    }

    final cleanedValue = value.trim();

    if (cleanedValue.length < 8) {
      return 'رقم الهاتف قصير جدًا';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }

    if (value.trim().length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }

    return null;
  }

  static String? website(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final cleanedValue = value.trim();

    final hasValidStart = cleanedValue.startsWith('http://') ||
        cleanedValue.startsWith('https://') ||
        cleanedValue.startsWith('www.');

    if (!hasValidStart) {
      return 'أدخل رابطًا صحيحًا يبدأ بـ http:// أو https:// أو www.';
    }

    return null;
  }

  static String? companyName(String? value) {
    return requiredField(value, 'اسم الشركة');
  }

  static String? companyField(String? value) {
    return requiredField(value, 'مجال الشركة');
  }

  static String? location(String? value) {
    return requiredField(value, 'الموقع');
  }
}