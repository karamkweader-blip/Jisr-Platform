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
  required UpdateCompanyTaskRequest request,
}) async {
  if (taskId <= 0) {
    throw Exception('معرف المهمة غير صالح');
  }

  if (request.isEmpty) {
    throw Exception('لم يتم إجراء أي تعديل على المهمة');
  }

  try {
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
      final data = decodedBody['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception('صيغة بيانات المهمة المعدلة غير صحيحة');
      }

      return CompanyTaskDetailsModel.fromJson(data);
    }

    throw Exception(
      decodedBody['message']?.toString() ?? 'تعذر تعديل المهمة',
    );
  } on FormatException {
    throw Exception('تعذر قراءة استجابة الخادم');
  } catch (e) {
    throw Exception(
      e.toString().replaceFirst('Exception: ', ''),
    );
  }
}
  Future<CompanyTaskDetailsModel> cancelTask(int taskId) async {
  if (taskId <= 0) {
    throw Exception('معرف المهمة غير صالح');
  }

  try {
    final response = await http
        .patch(
          Uri.parse(ApiLinks.cancelCompanyTask(taskId)),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
        );

    final decodedBody = _decodeBody(response.body);

    if (_isSuccess(response.statusCode) &&
        decodedBody['status'] != false) {
      final data = decodedBody['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception('صيغة بيانات المهمة الملغاة غير صحيحة');
      }

      return CompanyTaskDetailsModel.fromJson(data);
    }

    throw Exception(
      decodedBody['message']?.toString() ?? 'تعذر إلغاء المهمة',
    );
  } on FormatException {
    throw Exception('تعذر قراءة استجابة الخادم');
  } catch (e) {
    throw Exception(
      e.toString().replaceFirst('Exception: ', ''),
    );
  }
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