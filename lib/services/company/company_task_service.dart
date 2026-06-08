import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/company/company_task_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class CompanyTaskService {
  final AuthService _authService;

  CompanyTaskService(this._authService);

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('انتهت الجلسة، يرجى تسجيل الدخول مجددًا');
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<CompanyTaskModel>> getCompanyTasks() async {
    final response = await http
        .get(
          Uri.parse(ApiLinks.companyTasks),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
        );

    final decodedBody = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = decodedBody['data'] as List? ?? [];

      return data
          .map(
            (item) => CompanyTaskModel.fromJson(
              item as Map<String, dynamic>? ?? {},
            ),
          )
          .toList();
    }

    throw Exception(
      decodedBody['message'] as String? ?? 'تعذر تحميل المهام',
    );
  }

  Future<CompanyTaskModel> createTask(CreateCompanyTaskRequest request) async {
    final response = await http
        .post(
          Uri.parse(ApiLinks.companyTasks),
          headers: await _headers(),
          body: jsonEncode(request.toJson()),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
        );

    final decodedBody = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return CompanyTaskModel.fromJson(
        decodedBody['data'] as Map<String, dynamic>? ?? {},
      );
    }

    throw Exception(
      decodedBody['message'] as String? ?? 'تعذر إنشاء المهمة',
    );
  }

  Future<CompanyTaskModel> publishTask(int taskId) async {
    final response = await http
        .patch(
          Uri.parse(ApiLinks.publishCompanyTask(taskId)),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
        );

    final decodedBody = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return CompanyTaskModel.fromJson(
        decodedBody['data'] as Map<String, dynamic>? ?? {},
      );
    }

    throw Exception(
      decodedBody['message'] as String? ?? 'تعذر نشر المهمة',
    );
  }

  Future<List<AvailableSkillModel>> getAvailableSkills() async {
    final response = await http
        .get(
          Uri.parse(ApiLinks.skills),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
        );

    final decodedBody = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = decodedBody['data'] as List? ?? [];

      return data
          .map(
            (item) => AvailableSkillModel.fromJson(
              item as Map<String, dynamic>? ?? {},
            ),
          )
          .toList();
    }

    throw Exception(
      decodedBody['message'] as String? ?? 'تعذر تحميل المهارات',
    );
  }
}