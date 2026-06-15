import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/company/tasks/company_task_application_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class CompanyTaskApplicantsService {
  final AuthService _authService;

  CompanyTaskApplicantsService(this._authService);

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

  Future<List<CompanyTaskApplicationModel>> getTaskApplications(
    int taskId,
  ) async {
    try {
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

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = decodedBody['data'];

        if (data is! List) {
          throw Exception('صيغة بيانات المتقدمين غير صحيحة');
        }

        return data
            .whereType<Map<String, dynamic>>()
            .map(CompanyTaskApplicationModel.fromJson)
            .toList();
      }

      throw Exception(
        decodedBody['message'] as String? ?? 'تعذر تحميل المتقدمين',
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
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