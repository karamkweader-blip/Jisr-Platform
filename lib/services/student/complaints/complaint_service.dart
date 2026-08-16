import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/complaints/complaint_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class ComplaintService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = (await _authService.getToken())?.trim();
    if (token == null || token.isEmpty) {
      throw const ComplaintApiException(
        statusCode: 401,
        message: 'انتهت الجلسة، يرجى تسجيل الدخول من جديد',
      );
    }

    return <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<ComplaintSubmissionResponse> submitComplaint(
    ComplaintRequestModel request,
  ) async {
    if (!ComplaintContextTypes.values.contains(request.contextType) ||
        request.contextId <= 0) {
      throw const ComplaintApiException(
        statusCode: 0,
        message: 'سياق الشكوى غير صالح',
      );
    }

    final response = await http
        .post(
          Uri.parse(ApiLinks.complaints),
          headers: await _headers(),
          body: jsonEncode(request.toJson()),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw const ComplaintApiException(
            statusCode: 0,
            message: 'انتهت مهلة الاتصال عند إرسال الشكوى',
          ),
        );

    final data = _decodeBody(response);
    if (response.statusCode == 201 && data['success'] == true) {
      return ComplaintSubmissionResponse.fromJson(data);
    }

    throw ComplaintApiException(
      statusCode: response.statusCode,
      message: _firstError(data) ??
          _message(data) ??
          'تعذر إرسال الشكوى، حاول مرة أخرى',
      errors: data['errors'] is Map
          ? Map<String, dynamic>.from(data['errors'])
          : const <String, dynamic>{},
      retryAfterSeconds: response.statusCode == 429
          ? _retryAfterSeconds(response.headers['retry-after'])
          : null,
    );
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      // A clear fallback is returned for non-JSON server responses.
    }
    return <String, dynamic>{'message': 'استجابة غير مفهومة من الخادم'};
  }

  String? _message(Map<String, dynamic> data) {
    final message = data['message']?.toString().trim();
    return message == null || message.isEmpty ? null : message;
  }

  String? _firstError(Map<String, dynamic> data) {
    final errors = data['errors'];
    if (errors is! Map) return null;
    for (final value in errors.values) {
      if (value is List && value.isNotEmpty) return value.first.toString();
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  int _retryAfterSeconds(String? value) {
    final seconds = int.tryParse(value ?? '');
    if (seconds != null && seconds > 0) return seconds;

    final retryAt = DateTime.tryParse(value ?? '');
    if (retryAt != null) {
      final difference = retryAt.toUtc().difference(DateTime.now().toUtc());
      if (difference.inSeconds > 0) return difference.inSeconds;
    }
    return 60;
  }
}

class ComplaintApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic> errors;
  final int? retryAfterSeconds;

  const ComplaintApiException({
    required this.statusCode,
    required this.message,
    this.errors = const <String, dynamic>{},
    this.retryAfterSeconds,
  });

  @override
  String toString() => message;
}
