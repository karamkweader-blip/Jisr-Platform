import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String tokenKey = 'token';
  static const String roleKey = 'role';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(roleKey);
  }

  Future<Map<String, String?>> getAuthData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'token': prefs.getString(tokenKey),
      'role': prefs.getString(roleKey),
    };
  }

  Future<void> saveAuthData({
    required String token,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(tokenKey, token);
    await prefs.setString(roleKey, role);
  }

  Future<void> removeAuthData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(tokenKey);
    await prefs.remove(roleKey);
  }

  Future<Map<String, dynamic>> logout() async {
    final authData = await getAuthData();
    final token = authData['token'];

    print('AUTH LOGOUT TOKEN: $token');

    try {
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

      // مهما كان الرد، نمسح التوكن من الجهاز
      await removeAuthData();

      return {
        'statusCode': response.statusCode,
        'data': response.body.isNotEmpty ? jsonDecode(response.body) : {},
      };
    } catch (e) {
      // لو السيرفر رفض أو التوكن قديم، برضو نمسح محلياً
      await removeAuthData();

      return {
        'statusCode': 401,
        'data': {'message': 'تم تسجيل الخروج محلياً'},
      };
    }
  }

  Future<Map<String, dynamic>> logoutAllSessions() async {
    final authData = await getAuthData();
    final token = authData['token'];

    print('AUTH LOGOUT ALL TOKEN: $token');

    try {
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

      await removeAuthData();

      return {
        'statusCode': response.statusCode,
        'data': response.body.isNotEmpty ? jsonDecode(response.body) : {},
      };
    } catch (e) {
      await removeAuthData();

      return {
        'statusCode': 401,
        'data': {'message': 'تم تسجيل الخروج محلياً'},
      };
    }
  }
}
