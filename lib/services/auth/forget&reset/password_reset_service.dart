import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_exception.dart';
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/core/api/api_response_handler.dart';

class PasswordResetService {
  Future<String> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiLinks.verifyResetOtp),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': email.trim(),
              'code': code.trim(),
            }),
          )
          .timeout(const Duration(seconds: 20));

      final data = ApiResponseHandler.handleResponse(
        response,
        operation: ApiOperation.verifyResetOtp,
      );

      final token = data['token']?.toString().trim() ?? '';

      if (token.isEmpty) {
        throw const ApiException(
          operation: ApiOperation.verifyResetOtp,
          type: ApiFailureType.invalidResponse,
        );
      }

      return token;
    } catch (error) {
      throw ApiResponseHandler.fromError(
        error,
        operation: ApiOperation.verifyResetOtp,
      );
    }
  }

  Future<void> resendOtp({
    required String email,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiLinks.resendResetOtp),
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
        operation: ApiOperation.resendOtp,
      );
    } catch (error) {
      throw ApiResponseHandler.fromError(
        error,
        operation: ApiOperation.resendOtp,
      );
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiLinks.resetPassword),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'new_password': newPassword,
              'new_password_confirmation':
                  newPasswordConfirmation,
            }),
          )
          .timeout(const Duration(seconds: 20));

      ApiResponseHandler.handleResponse(
        response,
        operation: ApiOperation.resetPassword,
      );
    } catch (error) {
      throw ApiResponseHandler.fromError(
        error,
        operation: ApiOperation.resetPassword,
      );
    }
  }
}