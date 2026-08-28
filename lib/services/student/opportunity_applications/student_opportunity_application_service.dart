import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_exception.dart';
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/core/api/api_response_handler.dart';
import 'package:jisr_platform/models/student/opportunity_applications/student_opportunity_application_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class StudentOpportunityApplicationService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token =
        (await _authService.getToken())?.trim();

    if (token == null || token.isEmpty) {
      throw const ApiException(
        statusCode: 401,
        backendMessage:
            'انتهت الجلسة، يرجى تسجيل الدخول من جديد',
        operation: ApiOperation.application,
      );
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<StudentOpportunityApplicationsResponse>
      getApplications() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              ApiLinks.studentOpportunityApplications,
            ),
            headers: await _headers(),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final data =
          ApiResponseHandler.handleResponse(
        response,
        operation: ApiOperation.application,
      );

      return StudentOpportunityApplicationsResponse
          .fromJson(data);
    } catch (error) {
      throw ApiResponseHandler.fromError(
        error,
        operation: ApiOperation.application,
      );
    }
  }

  Future<
          StudentOpportunityApplicationDetailsResponse>
      getApplicationDetails(
    int applicationId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              ApiLinks
                  .studentOpportunityApplicationDetails(
                applicationId,
              ),
            ),
            headers: await _headers(),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final data =
          ApiResponseHandler.handleResponse(
        response,
        operation: ApiOperation.application,
      );

      return StudentOpportunityApplicationDetailsResponse
          .fromJson(data);
    } catch (error) {
      throw ApiResponseHandler.fromError(
        error,
        operation: ApiOperation.application,
      );
    }
  }

  Future<
          StudentOpportunityApplicationDetailsResponse>
      withdrawApplication(
    int applicationId,
  ) async {
    try {
      final response = await http
          .patch(
            Uri.parse(
              ApiLinks
                  .withdrawStudentOpportunityApplication(
                applicationId,
              ),
            ),
            headers: await _headers(),
            body: jsonEncode(
              <String, dynamic>{},
            ),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final data =
          ApiResponseHandler.handleResponse(
        response,
        operation: ApiOperation.application,
      );

      return StudentOpportunityApplicationDetailsResponse
          .fromJson(data);
    } catch (error) {
      throw ApiResponseHandler.fromError(
        error,
        operation: ApiOperation.application,
      );
    }
  }
}