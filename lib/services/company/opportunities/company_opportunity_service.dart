import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class CompanyOpportunityService {
  final AuthService _authService;

  CompanyOpportunityService(this._authService);

  static const _timeout = Duration(seconds: 15);
  static const _statuses = {'draft', 'published', 'closed', 'cancelled'};

  Future<Map<String, String>> _headers() async {
    final token = (await _authService.getToken())?.trim();
    if (token == null || token.isEmpty) {
      throw Exception('انتهت الجلسة، يرجى تسجيل الدخول مجددًا');
    }
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<CompanyOpportunityModel>> getOpportunities({
    String? search,
    String? status,
  }) async {
    final normalizedStatus = status?.trim();
    if (normalizedStatus != null &&
        normalizedStatus.isNotEmpty &&
        !_statuses.contains(normalizedStatus)) {
      throw Exception('حالة الفرصة المحددة غير صالحة');
    }

    final uri = Uri.parse(ApiLinks.companyOpportunities).replace(
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (normalizedStatus != null && normalizedStatus.isNotEmpty)
          'status': normalizedStatus,
      },
    );
    final body = await _send(() async => http.get(uri, headers: await _headers()));
    return opportunityList(body['data'])
        .map((item) => CompanyOpportunityModel.fromJson(opportunityMap(item)))
        .where((item) => item.id > 0)
        .toList();
  }

  Future<CompanyOpportunityModel> getOpportunity(int opportunityId) async {
    if (opportunityId <= 0) throw Exception('معرف الفرصة غير صالح');
    final body = await _send(
      () async => http.get(
        Uri.parse(ApiLinks.companyOpportunityDetails(opportunityId)),
        headers: await _headers(),
      ),
    );
    return _opportunityFromBody(body);
  }

  Future<CompanyOpportunityModel> createOpportunity(
    SaveCompanyOpportunityRequest request,
  ) async {
    _validateRequest(request);
    final body = await _send(
      () async => http.post(
        Uri.parse(ApiLinks.companyOpportunities),
        headers: await _headers(),
        body: jsonEncode(request.toJson()),
      ),
    );
    return _opportunityFromBody(body);
  }

  Future<CompanyOpportunityModel> updateOpportunity(
    int opportunityId,
    SaveCompanyOpportunityRequest request,
  ) async {
    if (opportunityId <= 0) throw Exception('معرف الفرصة غير صالح');
    _validateRequest(request);
    final body = await _send(
      () async => http.put(
        Uri.parse(ApiLinks.companyOpportunityDetails(opportunityId)),
        headers: await _headers(),
        body: jsonEncode(request.toJson()),
      ),
    );
    return _opportunityFromBody(body);
  }

  Future<CompanyOpportunityModel> publishOpportunity(int opportunityId) {
    if (opportunityId <= 0) throw Exception('معرف الفرصة غير صالح');
    return _changeStatus(
      ApiLinks.publishCompanyOpportunity(opportunityId),
      'تعذر نشر الفرصة',
    );
  }

  Future<CompanyOpportunityModel> closeOpportunity(int opportunityId) {
    if (opportunityId <= 0) throw Exception('معرف الفرصة غير صالح');
    return _changeStatus(
      ApiLinks.closeCompanyOpportunity(opportunityId),
      'تعذر إغلاق الفرصة',
    );
  }

  Future<CompanyOpportunityModel> cancelOpportunity(int opportunityId) {
    if (opportunityId <= 0) throw Exception('معرف الفرصة غير صالح');
    return _changeStatus(
      ApiLinks.cancelCompanyOpportunity(opportunityId),
      'تعذر إلغاء الفرصة',
    );
  }

  Future<CompanyOpportunityModel> _changeStatus(
    String url,
    String fallbackMessage,
  ) async {
    final body = await _send(
      () async => http.patch(Uri.parse(url), headers: await _headers()),
      fallbackMessage: fallbackMessage,
    );
    return _opportunityFromBody(body);
  }

  CompanyOpportunityModel _opportunityFromBody(Map<String, dynamic> body) {
    final data = opportunityMap(body['data']);
    if (data.isEmpty) throw Exception('استجابة بيانات الفرصة غير صالحة');
    return CompanyOpportunityModel.fromJson(data);
  }

  void _validateRequest(SaveCompanyOpportunityRequest request) {
    if (!const {'job', 'internship'}.contains(request.type)) {
      throw Exception('نوع الفرصة غير صالح');
    }
    if (request.title.trim().isEmpty ||
        request.description.trim().isEmpty ||
        request.location.trim().isEmpty) {
      throw Exception('يرجى إكمال بيانات الفرصة المطلوبة');
    }
    if (request.salaryMin < 0 || request.salaryMax < request.salaryMin) {
      throw Exception('نطاق الراتب غير صالح');
    }
    if (request.skills.isEmpty) {
      throw Exception('يجب إضافة مهارة واحدة على الأقل');
    }
  }

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request, {
    String fallbackMessage = 'تعذر تنفيذ طلب الفرصة',
  }) async {
    try {
      final response = await request().timeout(_timeout);
      final body = _decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300 &&
          body['status'] != false && body['success'] != false) {
        return body;
      }
      throw Exception(body['message']?.toString() ?? fallbackMessage);
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال بالخادم');
    } on FormatException {
      throw Exception('تعذر قراءة استجابة الخادم');
    } catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Map<String, dynamic> _decode(String raw) {
    if (raw.trim().isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(raw);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    throw const FormatException();
  }
}
