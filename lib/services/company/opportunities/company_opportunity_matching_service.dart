import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_smart_ranking_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class CompanyOpportunityMatchingService {
  final AuthService _authService;

  CompanyOpportunityMatchingService(
    this._authService,
  );

  static const Duration _requestTimeout =
      Duration(seconds: 15);

  Future<CompanyOpportunitySmartRankingResponse>
      getTopCandidates({
    required int opportunityId,
    int limit = 20,
  }) async {
    if (opportunityId <= 0) {
      throw const CompanyOpportunityMatchingApiException(
        statusCode: 404,
        message: 'معرف الفرصة غير صالح',
      );
    }

    if (limit < 1 || limit > 100) {
      throw const CompanyOpportunityMatchingApiException(
        statusCode: 422,
        message:
            'عدد المرشحين المطلوب يجب أن يكون بين 1 و100',
        errors: <String, dynamic>{
          'limit': <String>[
            'عدد المرشحين المطلوب يجب أن يكون بين 1 و100',
          ],
        },
      );
    }

    try {
      final uri = Uri.parse(
        ApiLinks.companyOpportunityTopCandidates(
          opportunityId,
        ),
      ).replace(
        queryParameters: <String, String>{
          'limit': limit.toString(),
        },
      );

      final response = await http
          .get(
            uri,
            headers: await _headers(),
          )
          .timeout(
            _requestTimeout,
            onTimeout: () {
              throw TimeoutException(
                'انتهت مهلة الاتصال أثناء جلب الترتيب الذكي',
              );
            },
          );

      final body = _decodeBody(response);

      if (response.statusCode == 200 &&
          body['success'] == true) {
        if (body['data'] is! List ||
            body['meta'] is! Map) {
          throw const CompanyOpportunityMatchingApiException(
            statusCode: 500,
            message:
                'استجابة الترتيب الذكي غير مكتملة',
          );
        }

        return CompanyOpportunitySmartRankingResponse
            .fromJson(body);
      }

      throw _apiException(
        response,
        body,
        fallback:
            'تعذر تحميل الترتيب الذكي للمرشحين',
      );
    } on CompanyOpportunityMatchingApiException {
      rethrow;
    } on TimeoutException {
      throw const CompanyOpportunityMatchingApiException(
        statusCode: 408,
        message:
            'انتهت مهلة الاتصال، يرجى المحاولة مجددًا',
      );
    } on FormatException {
      throw const CompanyOpportunityMatchingApiException(
        statusCode: 500,
        message:
            'تعذر قراءة استجابة الترتيب الذكي',
      );
    } on http.ClientException {
      throw const CompanyOpportunityMatchingApiException(
        statusCode: 0,
        message:
            'تعذر الاتصال بالخادم، تحقق من اتصال الإنترنت',
      );
    }
  }

  Future<Map<String, String>> _headers() async {
    final token =
        (await _authService.getToken())?.trim();

    if (token == null || token.isEmpty) {
      throw const CompanyOpportunityMatchingApiException(
        statusCode: 401,
        message:
            'انتهت الجلسة، يرجى تسجيل الدخول من جديد',
      );
    }

    return <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeBody(
    http.Response response,
  ) {
    if (response.body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw const FormatException(
        'Response body is not a JSON object',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }

  CompanyOpportunityMatchingApiException
      _apiException(
    http.Response response,
    Map<String, dynamic> body, {
    required String fallback,
  }) {
    final errors = body['errors'] is Map
        ? Map<String, dynamic>.from(
            body['errors'],
          )
        : const <String, dynamic>{};

    final backendMessage =
        body['message']?.toString().trim();

    return CompanyOpportunityMatchingApiException(
      statusCode: response.statusCode,
      message: _firstError(errors) ??
          _preferredMessage(backendMessage) ??
          _statusFallback(
            response.statusCode,
            fallback,
          ),
      errors: errors,
    );
  }

  String _statusFallback(
    int statusCode,
    String fallback,
  ) {
    switch (statusCode) {
      case 401:
        return 'انتهت الجلسة، يرجى تسجيل الدخول من جديد';

      case 403:
        return 'لا تملك صلاحية لعرض الترتيب الذكي';

      case 404:
        return 'الفرصة غير متاحة أو لم تعد موجودة';

      case 422:
        return 'إعدادات الترتيب الذكي غير صالحة';

      case 429:
        return 'تم إرسال عدد كبير من الطلبات، يرجى المحاولة لاحقًا';

      default:
        return fallback;
    }
  }

  String? _preferredMessage(String? message) {
    if (message == null || message.isEmpty) {
      return null;
    }

    final arabicPart =
        message.split('|').first.trim();

    return arabicPart.isEmpty
        ? message
        : arabicPart;
  }

  String? _firstError(
    Map<String, dynamic> errors,
  ) {
    for (final value in errors.values) {
      if (value is List && value.isNotEmpty) {
        return _preferredMessage(
          value.first.toString(),
        );
      }

      final text =
          value?.toString().trim();

      if (text != null && text.isNotEmpty) {
        return _preferredMessage(text);
      }
    }

    return null;
  }
}

class CompanyOpportunityMatchingApiException
    implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic> errors;

  const CompanyOpportunityMatchingApiException({
    required this.statusCode,
    required this.message,
    this.errors = const <String, dynamic>{},
  });

  String? fieldMessage(String field) {
    final value = errors[field];

    if (value is List && value.isNotEmpty) {
      return value.first
          .toString()
          .split('|')
          .first
          .trim();
    }

    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text.split('|').first.trim();
  }

  @override
  String toString() => message;
}