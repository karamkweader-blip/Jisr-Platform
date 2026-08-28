import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/cv/student_cv_history_models.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class StudentCvHistoryService {
  final AuthService _authService = AuthService();

  Future<StudentCvListResponse> getStudentCvs() async {
    final response = await http
        .get(Uri.parse(ApiLinks.studentCvs), headers: await _headers())
        .timeout(const Duration(seconds: 15));
    final body = _decode(response);

    if (response.statusCode == 200) {
      final result = StudentCvListResponse.fromJson(body);
      if (result.success) return result;
    }

    throw StudentCvHistoryException(
      response.statusCode,
      body['message']?.toString() ?? 'تعذر جلب السير الذاتية',
    );
  }

  Future<StudentCvAnalysisDetailsResponse> getAnalysis(int cvId) async {
    final response = await http
        .get(
          Uri.parse(ApiLinks.studentCvAnalysis(cvId)),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 15));
    final body = _decode(response);

    if (response.statusCode == 200) {
      final result = StudentCvAnalysisDetailsResponse.fromJson(body);
      if (result.success &&
          result.cv.cvId == cvId &&
          result.analysis.cvId == cvId) {
        return result;
      }
      if (result.success) {
        throw const StudentCvHistoryException(
          409,
          'عاد الخادم بتحليل لا يطابق السيرة الذاتية المحددة.',
        );
      }
    }

    throw StudentCvHistoryException(
      response.statusCode,
      body['message']?.toString() ?? 'تعذر جلب تحليل السيرة الذاتية',
    );
  }

  Future<Map<String, String>> _headers() async {
    final token = (await _authService.getToken())?.trim();
    if (token == null || token.isEmpty) {
      throw const StudentCvHistoryException(
        401,
        'انتهت الجلسة، يرجى تسجيل الدخول من جديد',
      );
    }

    return <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) return <String, dynamic>{};
    try {
      final value = jsonDecode(response.body);
      if (value is Map) return Map<String, dynamic>.from(value);
    } catch (_) {
      return <String, dynamic>{'message': 'استجابة غير مفهومة من الخادم'};
    }
    return <String, dynamic>{'message': 'استجابة غير مفهومة من الخادم'};
  }
}

class StudentCvHistoryException implements Exception {
  final int statusCode;
  final String message;

  const StudentCvHistoryException(this.statusCode, this.message);

  @override
  String toString() => message;
}
