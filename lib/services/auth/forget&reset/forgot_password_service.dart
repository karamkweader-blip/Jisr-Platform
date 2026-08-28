import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_exception.dart';
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/core/api/api_response_handler.dart';

class ForgotPasswordService {
  Future<void> sendOtp(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiLinks.forgotPassword),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': email.trim(),
            }),
          )
          .timeout(const Duration(seconds: 20));

      ApiResponseHandler.handleResponse(
        response,
        operation: ApiOperation.forgotPassword,
      );
    } catch (error) {
      throw ApiResponseHandler.fromError(
        error,
        operation: ApiOperation.forgotPassword,
      );
    }
  }
}