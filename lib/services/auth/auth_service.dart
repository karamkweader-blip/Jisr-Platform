import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String tokenKey = 'token';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  Future<Map<String, dynamic>> logout() async {
    final token = await getToken();

    print('AUTH LOGOUT TOKEN: $token');

    final response = await http
        .post(
          Uri.parse(ApiLinks.logout),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال بالخادم');
          },
        );

    return {
      'statusCode': response.statusCode,
      'data': response.body.isNotEmpty ? jsonDecode(response.body) : {},
    };
  }

  Future<Map<String, dynamic>> logoutAllSessions() async {
    final token = await getToken();

    print('AUTH LOGOUT ALL TOKEN: $token');

    final response = await http
        .post(
          Uri.parse(ApiLinks.logoutAll),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال بالخادم');
          },
        );

    return {
      'statusCode': response.statusCode,
      'data': response.body.isNotEmpty ? jsonDecode(response.body) : {},
    };
  }
}
