import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/tasks/student_task_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class StudentTaskService {
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

  Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) return {};

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'message': 'استجابة غير مفهومة من الخادم'};
    }
  }

  Future<StudentTasksResponse> exploreTasks({String? title}) async {
    final uri = title == null || title.trim().isEmpty
        ? Uri.parse(ApiLinks.exploreTasks)
        : Uri.parse(
            ApiLinks.exploreTasks,
          ).replace(queryParameters: {'title': title.trim()});

    final response = await http
        .get(uri, headers: await _headers())
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال بجلب التاسكات');
          },
        );

    print('EXPLORE TASKS STATUS: ${response.statusCode}');
    print('EXPLORE TASKS BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      return StudentTasksResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب التاسكات');
  }

  Future<StudentTasksResponse> recommendedTasks() async {
    final response = await http
        .get(Uri.parse(ApiLinks.recommendedTasks), headers: await _headers())
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال بجلب التاسكات المقترحة');
          },
        );

    print('RECOMMENDED TASKS STATUS: ${response.statusCode}');
    print('RECOMMENDED TASKS BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      return StudentTasksResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب التاسكات المقترحة');
  }

  Future<StudentTaskDetailsResponse> taskDetails(int taskId) async {
    final response = await http
        .get(Uri.parse(ApiLinks.taskDetails(taskId)), headers: await _headers())
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال بجلب تفاصيل التاسك');
          },
        );

    print('TASK DETAILS STATUS: ${response.statusCode}');
    print('TASK DETAILS BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      return StudentTaskDetailsResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب تفاصيل التاسك');
  }
}
