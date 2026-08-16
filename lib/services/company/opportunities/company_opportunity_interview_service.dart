import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_interview_model.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class CompanyOpportunityInterviewService {
  final AuthService _authService;

  CompanyOpportunityInterviewService(this._authService);

  Future<String> _token() async {
    final token = (await _authService.getToken())?.trim();
    if (token == null || token.isEmpty) {
      throw Exception('انتهت الجلسة، يرجى تسجيل الدخول مجددًا');
    }
    return token;
  }

  Future<CompanyOpportunityInterview> schedule({
    required int opportunityId,
    required int applicationId,
    required SaveOpportunityInterviewRequest request,
  }) {
    _validate(opportunityId, applicationId, request);
    return _multipart(
      ApiLinks.scheduleCompanyOpportunityInterview(opportunityId, applicationId),
      request,
    );
  }

  Future<CompanyOpportunityInterview> reschedule({
    required int opportunityId,
    required int interviewId,
    required SaveOpportunityInterviewRequest request,
  }) {
    _validate(opportunityId, interviewId, request);
    return _multipart(
      ApiLinks.rescheduleCompanyOpportunityInterview(opportunityId, interviewId),
      request,
    );
  }

  Future<CompanyOpportunityInterview> cancel({
    required int opportunityId,
    required int interviewId,
  }) {
    if (opportunityId <= 0 || interviewId <= 0) {
      throw Exception('بيانات المقابلة غير صالحة');
    }
    return _patch(
      ApiLinks.cancelCompanyOpportunityInterview(opportunityId, interviewId),
      'تعذر إلغاء المقابلة',
    );
  }

  Future<CompanyOpportunityInterview> complete({
    required int opportunityId,
    required int interviewId,
  }) {
    if (opportunityId <= 0 || interviewId <= 0) {
      throw Exception('بيانات المقابلة غير صالحة');
    }
    return _patch(
      ApiLinks.completeCompanyOpportunityInterview(opportunityId, interviewId),
      'تعذر إكمال المقابلة',
    );
  }

  Future<CompanyOpportunityInterview> _multipart(
    String url,
    SaveOpportunityInterviewRequest data,
  ) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer ${await _token()}',
      });
      request.fields.addAll(data.toFormFields());
      final streamed = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamed);
      return _parse(response, 'تعذر حفظ موعد المقابلة');
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال بالخادم');
    } catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _validate(
    int opportunityId,
    int targetId,
    SaveOpportunityInterviewRequest request,
  ) {
    if (opportunityId <= 0 || targetId <= 0) {
      throw Exception('بيانات المقابلة غير صالحة');
    }
    if (!const {'online', 'onsite', 'phone'}.contains(request.meetingType)) {
      throw Exception('نوع المقابلة غير صالح');
    }
    if (request.meetingType == 'online' &&
        (request.meetingLink?.trim().isEmpty ?? true)) {
      throw Exception('رابط الاجتماع مطلوب للمقابلة الأونلاين');
    }
    if (request.meetingType == 'onsite' &&
        (request.location?.trim().isEmpty ?? true)) {
      throw Exception('الموقع مطلوب للمقابلة الحضورية');
    }
  }

  Future<CompanyOpportunityInterview> _patch(
    String url,
    String fallbackMessage,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _token()}',
        },
      ).timeout(const Duration(seconds: 15));
      return _parse(response, fallbackMessage);
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال بالخادم');
    } catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  CompanyOpportunityInterview _parse(http.Response response, String fallback) {
    try {
      final decoded = response.body.trim().isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
      if (decoded is! Map) throw const FormatException();
      final body = Map<String, dynamic>.from(decoded);
      if (response.statusCode < 200 || response.statusCode >= 300 ||
          body['status'] == false || body['success'] == false) {
        throw Exception(body['message']?.toString() ?? fallback);
      }
      final data = opportunityMap(body['data']);
      if (data.isEmpty) throw Exception('استجابة بيانات المقابلة غير صالحة');
      return CompanyOpportunityInterview.fromJson(data);
    } on FormatException {
      throw Exception('تعذر قراءة استجابة المقابلة');
    }
  }
}
