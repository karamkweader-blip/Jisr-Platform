import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_exception.dart';
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/core/api/api_response_handler.dart';
import 'package:jisr_platform/models/auth/login_request.dart';

class LoginService {
  Future<void> login(LoginRequest request) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiLinks.login),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 20));

      ApiResponseHandler.handleResponse(
        response,
        operation: ApiOperation.login,
      );
    } catch (error) {
      throw ApiResponseHandler.fromError(
        error,
        operation: ApiOperation.login,
      );
    }
  }
}