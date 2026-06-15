import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/company/tasks/company_task_application_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_details_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class CompanyTaskDetailsService {
  final AuthService _authService;

  CompanyTaskDetailsService(this._authService);

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

  Future<CompanyTaskDetailsModel> getTaskDetails(int taskId) async {
    final response = await http
        .get(
          Uri.parse(ApiLinks.companyTaskDetails(taskId)),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
        );

    final decodedBody = _decodeBody(response.body);

    if (_isSuccess(response.statusCode)) {
      return CompanyTaskDetailsModel.fromJson(
        decodedBody['data'] as Map<String, dynamic>? ?? {},
      );
    }

    throw Exception(
      decodedBody['message'] as String? ?? 'تعذر تحميل تفاصيل المهمة',
    );
  }

  Future<List<CompanyTaskApplicationModel>> getTaskApplications(
    int taskId,
  ) async {
    final response = await http
        .get(
          Uri.parse(ApiLinks.companyTaskApplications(taskId)),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
        );

    final decodedBody = _decodeBody(response.body);

    if (_isSuccess(response.statusCode)) {
      final data = decodedBody['data'];

      if (data is! List) {
        return <CompanyTaskApplicationModel>[];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(CompanyTaskApplicationModel.fromJson)
          .toList();
    }

    throw Exception(
      decodedBody['message'] as String? ?? 'تعذر تحميل المتقدمين',
    );
  }

  Future<CompanyTaskDetailsModel> publishTask(int taskId) async {
    final response = await http
        .patch(
          Uri.parse(ApiLinks.publishCompanyTask(taskId)),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
        );

    final decodedBody = _decodeBody(response.body);

    if (_isSuccess(response.statusCode)) {
      return CompanyTaskDetailsModel.fromJson(
        decodedBody['data'] as Map<String, dynamic>? ?? {},
      );
    }

    throw Exception(
      decodedBody['message'] as String? ?? 'تعذر نشر المهمة',
    );
  }

  Future<CompanyTaskDetailsModel> updateTask({
    required int taskId,
    required CreateCompanyTaskRequest request,
  }) async {
    final response = await http
        .put(
          Uri.parse(ApiLinks.updateCompanyTask(taskId)),
          headers: await _headers(),
          body: jsonEncode(request.toJson()),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
        );

    final decodedBody = _decodeBody(response.body);

    if (_isSuccess(response.statusCode)) {
      return CompanyTaskDetailsModel.fromJson(
        decodedBody['data'] as Map<String, dynamic>? ?? {},
      );
    }

    throw Exception(
      decodedBody['message'] as String? ?? 'تعذر تعديل المهمة',
    );
  }

  Future<void> deleteTask(int taskId) async {
    final response = await http
        .delete(
          Uri.parse(ApiLinks.deleteCompanyTask(taskId)),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
        );

    final decodedBody = _decodeBody(response.body);

    if (_isSuccess(response.statusCode)) {
      return;
    }

    throw Exception(
      decodedBody['message'] as String? ?? 'تعذر حذف المهمة',
    );
  }

  bool _isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }
}