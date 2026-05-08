import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';

class PasswordResetService {
  Future<String> verifyOtp({
    required String email,
    required String code,
  }) async {
    final response = await http.post(
      Uri.parse(ApiLinks.verifyResetOtp),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
        'code': code.trim(),
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = data['token']?.toString() ?? '';

      if (token.isEmpty) {
        throw Exception('لم يتم استلام رمز الأمان');
      }

      return token;
    }

    throw Exception(
      data['message']?.toString() ?? 'تعذر التحقق من رمز التأكيد',
    );
  }

  Future<void> resendOtp({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse(ApiLinks.resendResetOtp),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
      }),
    );

    if (response.statusCode == 200) return;

    final data = jsonDecode(response.body);

    throw Exception(
      data['message']?.toString() ?? 'تعذر إعادة إرسال الرمز',
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse(ApiLinks.resetPassword),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'new_password': newPassword.trim(),
        'new_password_confirmation': newPasswordConfirmation.trim(),
      }),
    );

    if (response.statusCode == 200) return;

    final data = jsonDecode(response.body);

    throw Exception(
      data['message']?.toString() ?? 'تعذر تغيير كلمة المرور',
    );
  }
}