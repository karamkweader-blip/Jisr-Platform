import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/opportunity_applications/student_opportunity_application_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class StudentOpportunityApplicationService {
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

  Future<StudentOpportunityApplicationsResponse> getApplications() async {
    final response = await http
        .get(
          Uri.parse(ApiLinks.studentOpportunityApplications),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال بجلب تقديمات الفرص');
          },
        );

    print('OPPORTUNITY APPLICATIONS STATUS: ${response.statusCode}');
    print('OPPORTUNITY APPLICATIONS BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      return StudentOpportunityApplicationsResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب تقديمات الفرص');
  }

  Future<StudentOpportunityApplicationDetailsResponse> getApplicationDetails(
    int applicationId,
  ) async {
    final response = await http
        .get(
          Uri.parse(
            ApiLinks.studentOpportunityApplicationDetails(applicationId),
          ),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال بجلب تفاصيل طلب التقديم');
          },
        );

    print('OPPORTUNITY APPLICATION DETAILS STATUS: ${response.statusCode}');
    print('OPPORTUNITY APPLICATION DETAILS BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      return StudentOpportunityApplicationDetailsResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب تفاصيل طلب التقديم');
  }

  Future<StudentOpportunityApplicationDetailsResponse> withdrawApplication(
    int applicationId,
  ) async {
    final response = await http
        .patch(
          Uri.parse(
            ApiLinks.withdrawStudentOpportunityApplication(applicationId),
          ),
          headers: await _headers(),
          body: jsonEncode({}),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال أثناء سحب طلب التقديم');
          },
        );

    print('WITHDRAW OPPORTUNITY APPLICATION STATUS: ${response.statusCode}');
    print('WITHDRAW OPPORTUNITY APPLICATION BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return StudentOpportunityApplicationDetailsResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل سحب طلب التقديم');
  }
}
