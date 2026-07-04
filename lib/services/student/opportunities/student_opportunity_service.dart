import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/opportunities/student_opportunity_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class StudentOpportunityService {
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

  Future<StudentOpportunitiesResponse> recommendedOpportunities() async {
    final response = await http
        .get(
          Uri.parse(ApiLinks.studentRecommendedOpportunities),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال بجلب الفرص الموصى بها');
          },
        );

    print('RECOMMENDED OPPORTUNITIES STATUS: ${response.statusCode}');
    print('RECOMMENDED OPPORTUNITIES BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      return StudentOpportunitiesResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب الفرص الموصى بها');
  }

  Future<StudentOpportunitiesResponse> exploreOpportunities() async {
    final response = await http
        .get(
          Uri.parse(ApiLinks.studentExploreOpportunities),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال بجلب فرص الاستكشاف');
          },
        );

    print('EXPLORE OPPORTUNITIES STATUS: ${response.statusCode}');
    print('EXPLORE OPPORTUNITIES BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      return StudentOpportunitiesResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب فرص الاستكشاف');
  }

  Future<StudentOpportunityDetailsResponse> opportunityDetails(
    int opportunityId,
  ) async {
    final response = await http
        .get(
          Uri.parse(ApiLinks.studentOpportunityDetails(opportunityId)),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال بجلب تفاصيل الفرصة');
          },
        );

    print('OPPORTUNITY DETAILS STATUS: ${response.statusCode}');
    print('OPPORTUNITY DETAILS BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      return StudentOpportunityDetailsResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب تفاصيل الفرصة');
  }

  Future<StudentOpportunityApplyResponse> applyToOpportunity(
    int opportunityId, {
    required String coverLetter,
  }) async {
    final response = await http
        .post(
          Uri.parse(ApiLinks.applyToStudentOpportunity(opportunityId)),
          headers: await _headers(),
          body: jsonEncode({
            'cover_letter': coverLetter.trim(),
          }),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال أثناء إرسال طلب التقديم');
          },
        );

    print('APPLY OPPORTUNITY STATUS: ${response.statusCode}');
    print('APPLY OPPORTUNITY BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return StudentOpportunityApplyResponse.fromJson(data);
    }

    final message = data['message']?.toString() ?? '';

    if (message.contains('match_score') ||
        message.contains('Unknown column') ||
        message.contains('SQLSTATE')) {
      throw Exception(
        'طلب التقديم وصل للخادم، لكن قاعدة البيانات في الباك ناقصها أعمدة match_score أو match_reasons. يجب تشغيل migration من طرف الباك.',
      );
    }

    throw Exception(message.isEmpty ? 'فشل إرسال طلب التقديم' : message);
  }
}
