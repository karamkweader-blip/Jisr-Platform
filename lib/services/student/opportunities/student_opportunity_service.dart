import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_exception.dart';
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/core/api/api_response_handler.dart';
import 'package:jisr_platform/models/student/opportunities/student_opportunity_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class StudentOpportunityService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = (await _authService.getToken())?.trim();

    if (token == null || token.isEmpty) {
      throw const ApiException(
        statusCode: 401,
        backendMessage:
            'انتهت الجلسة، يرجى تسجيل الدخول من جديد',
        operation: ApiOperation.opportunity,
      );
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<StudentOpportunitiesResponse>
      recommendedOpportunities() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              ApiLinks.studentRecommendedOpportunities,
            ),
            headers: await _headers(),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final data =
          ApiResponseHandler.handleResponse(
        response,
        operation: ApiOperation.opportunity,
      );

      return StudentOpportunitiesResponse.fromJson(
        data,
      );
    } catch (error) {
      throw ApiResponseHandler.fromError(
        error,
        operation: ApiOperation.opportunity,
      );
    }
  }

  Future<StudentOpportunitiesResponse>
      exploreOpportunities() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              ApiLinks.studentExploreOpportunities,
            ),
            headers: await _headers(),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final data =
          ApiResponseHandler.handleResponse(
        response,
        operation: ApiOperation.opportunity,
      );

      return StudentOpportunitiesResponse.fromJson(
        data,
      );
    } catch (error) {
      throw ApiResponseHandler.fromError(
        error,
        operation: ApiOperation.opportunity,
      );
    }
  }

  Future<StudentOpportunityDetailsResponse>
      opportunityDetails(
    int opportunityId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              ApiLinks.studentOpportunityDetails(
                opportunityId,
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
        operation: ApiOperation.opportunity,
      );

      return StudentOpportunityDetailsResponse
          .fromJson(data);
    } catch (error) {
      throw ApiResponseHandler.fromError(
        error,
        operation: ApiOperation.opportunity,
      );
    }
  }

  Future<StudentOpportunityApplyResponse>
      applyToOpportunity(
    int opportunityId,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              ApiLinks.applyToStudentOpportunity(
                opportunityId,
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

      return StudentOpportunityApplyResponse
          .fromJson(data);
    } catch (error) {
      throw ApiResponseHandler.fromError(
        error,
        operation: ApiOperation.application,
      );
    }
  }
}