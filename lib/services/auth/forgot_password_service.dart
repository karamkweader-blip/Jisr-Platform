import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';

class ForgotPasswordService {
  Future<String> sendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiLinks.forgotPassword),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      print('STATUS: ${response.statusCode}');
      print('RESPONSE: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data['message']?.toString() ?? 'تم إرسال رمز التحقق';
      }

      throw data['message']?.toString() ?? 'تعذر إرسال رمز التحقق';
    } catch (e) {
      print('FORGOT PASSWORD ERROR: $e');
      throw e.toString().replaceFirst('Exception: ', '');
    }
  }
}