import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_exception.dart';
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/core/api/api_response_handler.dart';
import 'package:jisr_platform/models/company/tasks/company_task_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class CompanyTaskService {
  final AuthService _authService;

  CompanyTaskService(this._authService);

  static const Set<String> _allowedTaskStatuses = {
    'draft',
    'published',
    'in_progress',
    'closed',
    'cancelled',
  };

  Future<Map<String, String>> _headers() async {
    final token =
        (await _authService.getToken())?.trim();

    if (token == null || token.isEmpty) {
      throw const ApiException(
        statusCode: 401,
        backendMessage:
            'انتهت الجلسة، يرجى تسجيل الدخول مجددًا',
        operation: ApiOperation.task,
      );
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<CompanyTaskModel>> getCompanyTasks({
    String? status,
  }) async {
    final normalizedStatus = status?.trim();

    if (normalizedStatus != null &&
        normalizedStatus.isNotEmpty &&
        !_allowedTaskStatuses
            .contains(normalizedStatus)) {
      throw const ApiException(
        backendMessage:
            'حالة المهمة المحددة غير صالحة',
        operation: ApiOperation.task,
      );
    }

    try {
      final response = await http
          .post(
            Uri.parse(
              ApiLinks.companyTasksIndex,
            ),
            headers: await _headers(),
            body: normalizedStatus == null ||
                    normalizedStatus.isEmpty
                ? null
                : jsonEncode({
                    'status': normalizedStatus,
                  }),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final decoded =
          ApiResponseHandler.handleResponse(
        response,
        operation: ApiOperation.task,
      );

      final data = decoded['data'];

      if (data == null) {
        return <CompanyTaskModel>[];
      }

      if (data is! List) {
        throw const ApiException(
          operation: ApiOperation.task,
          type: ApiFailureType.invalidResponse,
        );
      }

      return data
          .whereType<Map>()
          .map(
            (item) => CompanyTaskModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (error) {
      throw ApiResponseHandler.fromError(
        error,
        operation: ApiOperation.task,
      );
    }
  }

  Future<CompanyTaskModel> createTask(
    CreateCompanyTaskRequest request,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiLinks.companyTasks),
            headers: await _headers(),
            body: jsonEncode(
              request.toJson(),
            ),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final decoded =
          ApiResponseHandler.handleResponse(
        response,
        operation: ApiOperation.task,
      );

      final data = decoded['data'];

      if (data is! Map) {
        throw const ApiException(
          operation: ApiOperation.task,
          type: ApiFailureType.invalidResponse,
        );
      }

      return CompanyTaskModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } catch (error) {
      throw ApiResponseHandler.fromError(
        error,
        operation: ApiOperation.task,
      );
    }
  }

  Future<CompanyTaskModel> publishTask(
    int taskId,
  ) async {
    try {
      final response = await http
          .patch(
            Uri.parse(
              ApiLinks.publishCompanyTask(taskId),
            ),
            headers: await _headers(),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final decoded =
          ApiResponseHandler.handleResponse(
        response,
        operation: ApiOperation.task,
      );

      final data = decoded['data'];

      if (data is! Map) {
        throw const ApiException(
          operation: ApiOperation.task,
          type: ApiFailureType.invalidResponse,
        );
      }

      return CompanyTaskModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } catch (error) {
      throw ApiResponseHandler.fromError(
        error,
        operation: ApiOperation.task,
      );
    }
  }

  Future<List<AvailableSkillModel>>
      getAvailableSkills() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiLinks.skills),
            headers: await _headers(),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final decoded =
          ApiResponseHandler.handleResponse(
        response,
        operation: ApiOperation.task,
      );

      final data = decoded['data'];

      if (data is! List) {
        throw const ApiException(
          operation: ApiOperation.task,
          type: ApiFailureType.invalidResponse,
        );
      }

      return data
          .whereType<Map>()
          .map(
            (item) => AvailableSkillModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where(
            (skill) => skill.id > 0,
          )
          .toList();
    } catch (error) {
      throw ApiResponseHandler.fromError(
        error,
        operation: ApiOperation.task,
      );
    }
  }
}