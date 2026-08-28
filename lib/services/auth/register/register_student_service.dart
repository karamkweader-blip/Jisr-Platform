import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_exception.dart';
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/core/api/api_response_handler.dart';
import 'package:jisr_platform/models/auth/register_student_model.dart';

class RegisterStudentService {
  Future<void> register(
    RegisterStudentModel model,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiLinks.register),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(model.toJson()),
          )
          .timeout(const Duration(seconds: 20));

      ApiResponseHandler.handleResponse(
        response,
        operation: ApiOperation.registerStudent,
      );
    } catch (error) {
      throw ApiResponseHandler.fromError(
        error,
        operation: ApiOperation.registerStudent,
      );
    }
  }
}