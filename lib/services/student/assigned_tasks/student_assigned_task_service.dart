import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/assigned_tasks/student_assigned_task_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class StudentAssignedTaskService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = (await _authService.getToken())?.trim();

    if (token == null || token.isEmpty) {
      throw Exception('انتهت الجلسة، يرجى تسجيل الدخول من جديد');
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<ProjectAssignmentTasksResponse> getAssignedTasks({
    String? status,
    int? projectAssignmentId,
    int page = 1,
    int perPage = 15,
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (status != null && status.trim().isNotEmpty) {
      queryParameters['status'] = status.trim();
    }
    if (projectAssignmentId != null && projectAssignmentId > 0) {
      queryParameters['project_assignment_id'] = projectAssignmentId.toString();
    }

    final uri = Uri.parse(
      ApiLinks.projectAssignmentTasks,
    ).replace(queryParameters: queryParameters);
    final response = await http
        .get(uri, headers: await _headers())
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال عند جلب المهام المسندة');
          },
        );

    final data = _decodeBody(response);

    if (response.statusCode == 200 && data['success'] == true) {
      return ProjectAssignmentTasksResponse.fromJson(data);
    }

    throw StudentAssignedTaskApiException(
      statusCode: response.statusCode,
      message: _errorMessage(data, 'فشل جلب المهام المسندة'),
    );
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) return <String, dynamic>{};

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      // The backend response is handled below with a clear user-facing error.
    }

    return <String, dynamic>{
      'message': 'استجابة غير مفهومة من الخادم',
    };
  }

  String _errorMessage(Map<String, dynamic> data, String fallback) {
    final errors = data['errors'];
    if (errors is Map) {
      final appealErrors = errors['appeal'];
      if (appealErrors is List && appealErrors.isNotEmpty) {
        return appealErrors.first.toString();
      }

      final reasonErrors = errors['reason'];
      if (reasonErrors is List && reasonErrors.isNotEmpty) {
        return reasonErrors.first.toString();
      }
    }

    final message = data['message']?.toString().trim();
    if (message != null && message.isNotEmpty) return message;

    return fallback;
  }

  Future<StudentEvaluationAppealsResponse> getEvaluationAppeals({
    String? status,
    int? projectAssignmentId,
    int page = 1,
    int perPage = 15,
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (status != null && status.trim().isNotEmpty) {
      queryParameters['status'] = status.trim();
    }
    if (projectAssignmentId != null && projectAssignmentId > 0) {
      queryParameters['project_assignment_id'] = projectAssignmentId.toString();
    }

    final uri = Uri.parse(
      ApiLinks.studentEvaluationAppeals,
    ).replace(queryParameters: queryParameters);
    final response = await http
        .get(uri, headers: await _headers())
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال عند جلب الاعتراضات');
          },
        );

    final data = _decodeBody(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return StudentEvaluationAppealsResponse.fromJson(data);
    }

    throw StudentAssignedTaskApiException(
      statusCode: response.statusCode,
      message: _errorMessage(data, 'تعذر جلب الاعتراضات'),
    );
  }

  Future<StudentProjectEvaluationResponse> getProjectEvaluation(
    int projectAssignmentId,
  ) async {
    if (projectAssignmentId <= 0) {
      throw const StudentAssignedTaskApiException(
        statusCode: 0,
        message: 'معرّف إسناد المشروع غير صالح',
      );
    }

    final response = await http
        .get(
          Uri.parse(
            ApiLinks.studentProjectAssignmentEvaluation(projectAssignmentId),
          ),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال عند جلب تقييم المشروع');
          },
        );

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      return StudentProjectEvaluationResponse.fromJson(data);
    }

    throw StudentAssignedTaskApiException(
      statusCode: response.statusCode,
      message: _errorMessage(data, 'تعذر جلب تقييم المشروع'),
    );
  }

  Future<ProjectEvaluationAppealModel> submitProjectEvaluationAppeal({
    required int evaluationId,
    required String reason,
  }) async {
    if (evaluationId <= 0) {
      throw const StudentAssignedTaskApiException(
        statusCode: 0,
        message: 'معرّف التقييم غير صالح',
      );
    }

    final response = await http
        .post(
          Uri.parse(ApiLinks.studentProjectEvaluationAppeals(evaluationId)),
          headers: await _headers(),
          body: jsonEncode(<String, dynamic>{'reason': reason}),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال عند إرسال الاعتراض');
          },
        );

    final data = _decodeBody(response);

    if (response.statusCode == 201 && data['success'] == true) {
      return ProjectEvaluationAppealModel.fromJson(
        data['data'] is Map
            ? Map<String, dynamic>.from(data['data'])
            : <String, dynamic>{},
      );
    }

    throw StudentAssignedTaskApiException(
      statusCode: response.statusCode,
      message: _errorMessage(data, 'فشل إرسال الاعتراض'),
    );
  }

  Future<StudentAssignedTaskModel> startTask(int taskId) async {
    final response = await http
        .patch(
          Uri.parse(ApiLinks.startAssignedTask(taskId)),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال عند بدء المهمة');
          },
        );

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AssignedTaskResponse.fromJson(data).data;
    }

    throw Exception(data['message'] ?? 'فشل بدء المهمة');
  }

  Future<StudentAssignedTaskModel> submitTask(int taskId) async {
    final response = await http
        .patch(
          Uri.parse(ApiLinks.submitAssignedTask(taskId)),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال عند تسليم المهمة');
          },
        );

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AssignedTaskResponse.fromJson(data).data;
    }

    throw Exception(data['message'] ?? 'فشل تسليم المهمة');
  }
}

class StudentAssignedTaskApiException implements Exception {
  final int statusCode;
  final String message;

  const StudentAssignedTaskApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => message;
}
