import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/task_applications/student_task_application_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class StudentTaskApplicationService {
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

  Future<AllMyTasksResponse> getAllMyTasks() async {
    final response = await http
        .get(Uri.parse(ApiLinks.allMyTasks), headers: await _headers())
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال بجلب كل التقديمات');
          },
        );

    print('ALL MY TASKS STATUS: ${response.statusCode}');
    print('ALL MY TASKS BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      return AllMyTasksResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب كل التقديمات');
  }

  Future<TaskApplicationsListResponse> getAppliedTasks() async {
    return _getList(ApiLinks.appliedTasks, 'فشل جلب التاسكات المقدّم عليها');
  }

  Future<TaskApplicationsListResponse> getAcceptedTasks() async {
    return _getList(ApiLinks.acceptedTasks, 'فشل جلب التاسكات المقبولة');
  }

  Future<TaskApplicationsListResponse> getRejectedTasks() async {
    return _getList(ApiLinks.rejectedTasks, 'فشل جلب التاسكات المرفوضة');
  }

  Future<TaskApplicationsListResponse> _getList(
    String url,
    String errorMessage,
  ) async {
    final response = await http
        .get(Uri.parse(url), headers: await _headers())
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال');
          },
        );

    print('TASK APPLICATIONS STATUS: ${response.statusCode}');
    print('TASK APPLICATIONS BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      return TaskApplicationsListResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? errorMessage);
  }
}
