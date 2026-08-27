import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/supervisor_projects/student_supervisor_project_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class StudentSupervisorProjectService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = (await _authService.getToken())?.trim();
    if (token == null || token.isEmpty) {
      throw const StudentSupervisorProjectApiException(
        statusCode: 401,
        message: 'انتهت الجلسة، يرجى تسجيل الدخول من جديد',
      );
    }

    return <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<StudentSupervisorProjectsResponse> getProjects({
    String? search,
    String? level,
    int page = 1,
    int perPage = 15,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (level != null && level.trim().isNotEmpty) {
      query['level'] = level.trim();
    }

    final response = await http
        .get(
          Uri.parse(ApiLinks.studentSupervisorProjects).replace(
            queryParameters: query,
          ),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () => throw const StudentSupervisorProjectApiException(
            statusCode: 0,
            message: 'انتهت مهلة الاتصال عند جلب المشاريع',
          ),
        );

    final body = _decode(response);
    if (response.statusCode == 200 && body['status'] == true) {
      return StudentSupervisorProjectsResponse.fromJson(body);
    }
    throw _exception(response.statusCode, body, 'تعذر جلب المشاريع');
  }

  Future<StudentSupervisorProjectDetailsResponse> getProjectDetails(
    int projectTemplateId,
  ) async {
    _ensureValidId(projectTemplateId, 'معرّف المشروع غير صالح');
    final response = await http
        .get(
          Uri.parse(
            ApiLinks.studentSupervisorProjectDetails(projectTemplateId),
          ),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () => throw const StudentSupervisorProjectApiException(
            statusCode: 0,
            message: 'انتهت مهلة الاتصال عند جلب تفاصيل المشروع',
          ),
        );

    final body = _decode(response);
    if (response.statusCode == 200 && body['status'] == true) {
      return StudentSupervisorProjectDetailsResponse.fromJson(body);
    }
    throw _exception(response.statusCode, body, 'تعذر جلب تفاصيل المشروع');
  }

  Future<StudentSupervisorProjectApplyResponse> apply({
    required int projectTemplateId,
    String? message,
  }) async {
    _ensureValidId(projectTemplateId, 'معرّف المشروع غير صالح');
    final trimmedMessage = message?.trim();
    final payload = <String, dynamic>{};
    if (trimmedMessage != null && trimmedMessage.isNotEmpty) {
      payload['message'] = trimmedMessage;
    }

    final response = await http
        .post(
          Uri.parse(
            ApiLinks.applyToStudentSupervisorProject(projectTemplateId),
          ),
          headers: await _headers(),
          body: jsonEncode(payload),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () => throw const StudentSupervisorProjectApiException(
            statusCode: 0,
            message: 'انتهت مهلة الاتصال أثناء إرسال طلب التقديم',
          ),
        );

    final body = _decode(response);
    // This endpoint intentionally has no top-level status/success field.
    if (response.statusCode == 201) {
      return StudentSupervisorProjectApplyResponse.fromJson(body);
    }
    throw _exception(response.statusCode, body, 'فشل إرسال طلب التقديم');
  }

  Future<StudentSupervisorProjectApplicationsResponse> getApplications() async {
    final response = await http
        .get(
          Uri.parse(ApiLinks.studentSupervisorProjectApplications),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () => throw const StudentSupervisorProjectApiException(
            statusCode: 0,
            message: 'انتهت مهلة الاتصال عند جلب تقديمات المشاريع',
          ),
        );

    final body = _decode(response);
    if (response.statusCode == 200 && body['status'] == true) {
      return StudentSupervisorProjectApplicationsResponse.fromJson(body);
    }
    throw _exception(
      response.statusCode,
      body,
      'تعذر جلب تقديمات المشاريع',
    );
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.trim().isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      // A clear fallback error is returned below.
    }
    return <String, dynamic>{'message': 'استجابة غير مفهومة من الخادم'};
  }

  StudentSupervisorProjectApiException _exception(
    int statusCode,
    Map<String, dynamic> body,
    String fallback,
  ) {
    final fieldErrors = <String, String>{};
    final errors = body['errors'];
    if (errors is Map) {
      errors.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          fieldErrors[key.toString()] = value.first.toString();
        } else if (value != null) {
          fieldErrors[key.toString()] = value.toString();
        }
      });
    }

    final message = body['message']?.toString().trim();
    return StudentSupervisorProjectApiException(
      statusCode: statusCode,
      message: message == null || message.isEmpty ? fallback : message,
      fieldErrors: fieldErrors,
    );
  }

  void _ensureValidId(int id, String message) {
    if (id <= 0) {
      throw StudentSupervisorProjectApiException(
        statusCode: 0,
        message: message,
      );
    }
  }
}

class StudentSupervisorProjectApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, String> fieldErrors;

  const StudentSupervisorProjectApiException({
    required this.statusCode,
    required this.message,
    this.fieldErrors = const <String, String>{},
  });

  @override
  String toString() => message;
}
