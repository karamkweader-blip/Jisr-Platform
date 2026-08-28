import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_exception.dart';
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/core/api/api_response_handler.dart';

class LoginOtpService {
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiLinks.verifyLoginOtp),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': email.trim(),
              'code': code.trim(),
            }),
          )
          .timeout(
            const Duration(seconds: 20),
          );

      return ApiResponseHandler.handleResponse(
        response,
        operation: ApiOperation.loginOtp,
      );
    } catch (error) {
      throw ApiResponseHandler.fromError(
        error,
        operation: ApiOperation.loginOtp,
      );
    }
  }
}