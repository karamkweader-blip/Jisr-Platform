import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/interviews/student_interview_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class StudentInterviewService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = (await _authService.getToken())?.trim();
    if (token == null || token.isEmpty) {
      throw const StudentInterviewApiException(
        statusCode: 401,
        message: 'انتهت الجلسة، يرجى تسجيل الدخول من جديد',
      );
    }

    return <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<StudentInterviewsResponse> getInterviews() async {
    final response = await http
        .get(
          Uri.parse(ApiLinks.studentInterviews),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () => throw const StudentInterviewApiException(
            statusCode: 408,
            message: 'انتهت مهلة الاتصال عند جلب المقابلات',
          ),
        );

    final body = _decodeBody(response);
    if (response.statusCode == 200) {
      final result = StudentInterviewsResponse.fromJson(body);
      if (result.status) return result;
    }

    final backendMessage = body['message']?.toString().trim() ?? '';
    throw StudentInterviewApiException(
      statusCode: response.statusCode,
      message: backendMessage.isNotEmpty
          ? backendMessage
          : 'تعذر جلب مقابلات الطالب',
    );
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      // The error below keeps non-JSON server responses understandable.
    }
    return <String, dynamic>{'message': 'استجابة غير مفهومة من الخادم'};
  }
}

class StudentInterviewApiException implements Exception {
  final int statusCode;
  final String message;

  const StudentInterviewApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => message;
}
