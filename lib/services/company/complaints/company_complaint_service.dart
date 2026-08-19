import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/company/complaints/company_complaint_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class CompanyComplaintService {
  final AuthService _authService;

  CompanyComplaintService(this._authService);

  static const Duration _requestTimeout =
      Duration(seconds: 15);

  Future<CompanyComplaintModel> submitComplaint({
    required String contextType,
    required int contextId,
    required String reason,
  }) async {
    final normalizedReason = reason.trim();

    if (!CompanyComplaintContextTypes.values
        .contains(contextType)) {
      throw const CompanyComplaintApiException(
        statusCode: 422,
        message:
            'نوع الشكوى غير مدعوم لحساب الشركة',
      );
    }

    if (contextId < 1) {
      throw const CompanyComplaintApiException(
        statusCode: 422,
        message: 'معرف سياق الشكوى غير صالح',
      );
    }

    if (normalizedReason.length < 10 ||
        normalizedReason.length > 5000) {
      throw const CompanyComplaintApiException(
        statusCode: 422,
        message:
            'يجب أن يكون سبب الشكوى بين 10 و5000 حرف',
        errors: <String, dynamic>{
          'reason': <String>[
            'يجب أن يكون سبب الشكوى بين 10 و5000 حرف',
          ],
        },
      );
    }

    final request = CompanyComplaintRequest(
      contextType: contextType,
      contextId: contextId,
      reason: normalizedReason,
    );

    final response = await http
        .post(
          Uri.parse(ApiLinks.complaints),
          headers: await _headers(),
          body: jsonEncode(request.toJson()),
        )
        .timeout(
          _requestTimeout,
          onTimeout: () => throw TimeoutException(
            'انتهت مهلة الاتصال أثناء إرسال الشكوى',
          ),
        );

    final body = _decodeBody(response);

    if (response.statusCode == 201 &&
        body['success'] == true) {
      final data = _map(body['data']);

      final complaint =
          CompanyComplaintModel.fromJson(data);

      if (complaint.id > 0) {
        return complaint;
      }

      throw const CompanyComplaintApiException(
        statusCode: 500,
        message:
            'تم إرسال الشكوى لكن استجابة الخادم غير مكتملة',
      );
    }

    throw _apiException(
      response,
      body,
      fallback: 'تعذر إرسال الشكوى',
    );
  }

  Future<CompanyComplaintsResponse> getMyComplaints({
    String? status,
    String? contextType,
    int page = 1,
    int perPage = 20,
  }) async {
    final normalizedStatus = status?.trim();

    final normalizedContextType =
        contextType?.trim();

    if (normalizedStatus != null &&
        normalizedStatus.isNotEmpty &&
        !CompanyComplaintStatuses.values
            .contains(normalizedStatus)) {
      throw const CompanyComplaintApiException(
        statusCode: 422,
        message:
            'حالة الشكوى المحددة غير صالحة',
      );
    }

    if (normalizedContextType != null &&
        normalizedContextType.isNotEmpty &&
        !CompanyComplaintContextTypes.values
            .contains(normalizedContextType)) {
      throw const CompanyComplaintApiException(
        statusCode: 422,
        message:
            'نوع الشكوى المحدد غير صالح',
      );
    }

    if (page < 1 ||
        perPage < 1 ||
        perPage > 50) {
      throw const CompanyComplaintApiException(
        statusCode: 422,
        message:
            'إعدادات صفحات الشكاوى غير صالحة',
      );
    }

    final uri = Uri.parse(
      ApiLinks.myComplaints,
    ).replace(
      queryParameters: <String, String>{
        if (normalizedStatus != null &&
            normalizedStatus.isNotEmpty)
          'status': normalizedStatus,
        if (normalizedContextType != null &&
            normalizedContextType.isNotEmpty)
          'context_type': normalizedContextType,
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
    );

    final response = await http
        .get(
          uri,
          headers: await _headers(),
        )
        .timeout(
          _requestTimeout,
          onTimeout: () => throw TimeoutException(
            'انتهت مهلة الاتصال أثناء جلب شكاوى الشركة',
          ),
        );

    final body = _decodeBody(response);

    if (response.statusCode == 200 &&
        body['success'] == true) {
      return CompanyComplaintsResponse.fromJson(
        body,
      );
    }

    throw _apiException(
      response,
      body,
      fallback: 'تعذر جلب شكاوى الشركة',
    );
  }

  Future<Map<String, String>> _headers() async {
    final token =
        (await _authService.getToken())?.trim();

    if (token == null || token.isEmpty) {
      throw const CompanyComplaintApiException(
        statusCode: 401,
        message:
            'انتهت الجلسة، يرجى تسجيل الدخول من جديد',
      );
    }

    return <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeBody(
    http.Response response,
  ) {
    if (response.body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map) {
        return Map<String, dynamic>.from(
          decoded,
        );
      }
    } catch (_) {
      // سيتم استخدام الرسالة العربية الاحتياطية.
    }

    return <String, dynamic>{
      'message':
          'استجابة غير مفهومة من الخادم',
    };
  }

  CompanyComplaintApiException _apiException(
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

    return CompanyComplaintApiException(
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
        return 'لا تملك صلاحية لهذه العملية';

      case 404:
        return 'لم يعد العنصر المحدد متاحًا، يرجى تحديث الصفحة';

      case 422:
        return 'يرجى التحقق من بيانات الشكوى';

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

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }
}

class CompanyComplaintApiException
    implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic> errors;

  const CompanyComplaintApiException({
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

    final text =
        value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text.split('|').first.trim();
  }

  @override
  String toString() => message;
}