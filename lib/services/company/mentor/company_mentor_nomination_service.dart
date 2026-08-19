import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/company/mentor/company_mentor_constants.dart';
import 'package:jisr_platform/models/company/mentor/company_mentor_nomination_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class CompanyMentorNominationService {
  final AuthService _authService;

  CompanyMentorNominationService(this._authService);

  static const Duration _listTimeout = Duration(seconds: 15);
  static const Duration _uploadTimeout = Duration(seconds: 30);

  Future<CompanyMentorNominationsResponse> getNominations({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final normalizedStatus = status?.trim();

    if (normalizedStatus != null &&
        normalizedStatus.isNotEmpty &&
        !CompanyMentorNominationStatuses.values.contains(
          normalizedStatus,
        )) {
      throw const CompanyMentorApiException(
        statusCode: 422,
        message: 'حالة الترشيح المحددة غير صالحة',
        errors: <String, dynamic>{
          'status': <String>[
            'حالة الترشيح المحددة غير صالحة',
          ],
        },
      );
    }

    if (page < 1 || perPage < 1 || perPage > 50) {
      throw const CompanyMentorApiException(
        statusCode: 422,
        message: 'إعدادات صفحات الترشيحات غير صالحة',
      );
    }

    final uri = Uri.parse(
      ApiLinks.companyMentorNominations,
    ).replace(
      queryParameters: <String, String>{
        if (normalizedStatus != null &&
            normalizedStatus.isNotEmpty)
          'status': normalizedStatus,
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
          _listTimeout,
          onTimeout: () {
            throw TimeoutException(
              'انتهت مهلة الاتصال أثناء جلب ترشيحات المرشدين',
            );
          },
        );

    final body = _decodeBody(response);

    if (response.statusCode == 200 &&
        body['success'] == true) {
      return CompanyMentorNominationsResponse.fromJson(body);
    }

    throw _apiException(
      response,
      body,
      fallback: 'تعذر جلب ترشيحات المرشدين',
    );
  }

  Future<CompanyMentorNominationModel> submitNomination({
    required CompanyMentorNominationRequest nomination,
    required String cvPath,
  }) async {
    final hasValidSpecialization =
        CompanyMentorSpecializations.values.contains(
      nomination.specialization,
    );

    final hasValidTopics =
        nomination.mentoringTopics.isNotEmpty &&
        nomination.mentoringTopics.every(
          CompanyMentorTopics.values.contains,
        );

    if (!hasValidSpecialization || !hasValidTopics) {
      throw const CompanyMentorApiException(
        statusCode: 422,
        message: 'بيانات التخصص أو مواضيع الإرشاد غير صالحة',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiLinks.companyMentorNominations),
    );

    request.headers.addAll(
      await _headers(includeJsonContentType: false),
    );

    request.fields.addAll(nomination.toFields());

    for (
      var index = 0;
      index < nomination.mentoringTopics.length;
      index++
    ) {
      request.fields['mentoring_topics[$index]'] =
          nomination.mentoringTopics[index];
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'cv',
        cvPath,
      ),
    );

    final streamedResponse = await request.send().timeout(
      _uploadTimeout,
      onTimeout: () {
        throw TimeoutException(
          'انتهت مهلة الاتصال أثناء إرسال ترشيح المرشد',
        );
      },
    );

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    final body = _decodeBody(response);

    if (response.statusCode == 201 &&
        body['success'] == true) {
      return CompanyMentorNominationModel.fromJson(
        _map(body['data']),
      );
    }

    throw _apiException(
      response,
      body,
      fallback: 'تعذر إرسال ترشيح المرشد',
    );
  }

  Future<Map<String, String>> _headers({
    bool includeJsonContentType = true,
  }) async {
    final token = (await _authService.getToken())?.trim();

    if (token == null || token.isEmpty) {
      throw const CompanyMentorApiException(
        statusCode: 401,
        message: 'انتهت الجلسة، يرجى تسجيل الدخول من جديد',
      );
    }

    return <String, String>{
      'Accept': 'application/json',
      if (includeJsonContentType)
        'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeBody(
    http.Response response,
  ) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      // سيتم استخدام رسالة عربية واضحة أدناه.
    }

    return <String, dynamic>{
      'message': 'استجابة غير مفهومة من الخادم',
    };
  }

  CompanyMentorApiException _apiException(
    http.Response response,
    Map<String, dynamic> body, {
    required String fallback,
  }) {
    final backendMessage =
        body['message']?.toString().trim();

    final errors = body['errors'] is Map
        ? Map<String, dynamic>.from(body['errors'])
        : const <String, dynamic>{};

    return CompanyMentorApiException(
      statusCode: response.statusCode,
      message: _firstError(errors) ??
          (backendMessage != null &&
                  backendMessage.isNotEmpty
              ? backendMessage
              : fallback),
      errors: errors,
    );
  }

  String? _firstError(
    Map<String, dynamic> errors,
  ) {
    for (final value in errors.values) {
      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      }

      final text = value?.toString().trim();

      if (text != null && text.isNotEmpty) {
        return text;
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

class CompanyMentorApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic> errors;

  const CompanyMentorApiException({
    required this.statusCode,
    required this.message,
    this.errors = const <String, dynamic>{},
  });

  String? fieldMessage(String key) {
    final value = errors[key];

    if (value is List && value.isNotEmpty) {
      return value.first.toString();
    }

    final text = value?.toString().trim();

    return text == null || text.isEmpty ? null : text;
  }

  bool hasError(String key) {
    return fieldMessage(key) != null;
  }

  @override
  String toString() {
    return message;
  }
}