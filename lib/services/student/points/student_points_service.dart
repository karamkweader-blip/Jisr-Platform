import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/points/student_points_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class StudentPointsService {
  final AuthService _authService = AuthService();
  static const Duration _timeout = Duration(seconds: 18);

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

  Future<StudentPointsSummaryResponse> getMyPoints() async {
    final response = await http
        .get(Uri.parse(ApiLinks.myPoints), headers: await _headers())
        .timeout(_timeout);

    final data = _decode(response.body);

    if (response.statusCode == 200) {
      return StudentPointsSummaryResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب نقاطك');
  }

  Future<StudentPointsHistoryResponse> getPointsHistory({int page = 1}) async {
    final uri = Uri.parse(ApiLinks.myPointsHistory).replace(
      queryParameters: {'page': page.toString()},
    );

    final response = await http.get(uri, headers: await _headers()).timeout(_timeout);
    final data = _decode(response.body);

    if (response.statusCode == 200) {
      return StudentPointsHistoryResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب سجل النقاط');
  }

  Map<String, dynamic> _decode(String body) {
    if (body.isEmpty) return {};
    return Map<String, dynamic>.from(jsonDecode(body));
  }
}
