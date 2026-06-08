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

  Future<List<StudentAssignedTaskModel>> getAssignedTasks() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [];
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
