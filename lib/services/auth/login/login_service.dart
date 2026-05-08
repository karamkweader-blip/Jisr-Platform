import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/auth/login_request.dart';

class LoginService {
  Future<String> login(LoginRequest request) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiLinks.login),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(
            const Duration(seconds: 35),
            onTimeout: () {
              throw Exception('انتهت مهلة الاتصال بالخادم');
            },
          );

      print('LOGIN STATUS CODE: ${response.statusCode}');
      print('LOGIN RESPONSE BODY: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data['message']?.toString() ??
            'تم تسجيل الدخول، تحقق من الرمز المرسل إلى بريدك';
      }

      throw data['message']?.toString() ?? 'فشل تسجيل الدخول';
    } catch (e) {
      print('LOGIN ERROR: $e');
      throw e.toString().replaceFirst('Exception: ', '');
    }
  }
}