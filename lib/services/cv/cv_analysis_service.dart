import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/cv/cv_analysis_response.dart';
import 'package:jisr_platform/services/auth/auth_service.dart';

class CvAnalysisService {
  final AuthService _authService = AuthService();

  Future<CvAnalysisResponse> analyzeCv(int cvId) async {
    final token = (await _authService.getToken())?.trim();

    if (token == null || token.isEmpty) {
      throw Exception('انتهت الجلسة، يرجى تسجيل الدخول من جديد');
    }

    final url = ApiLinks.analyzeCv(cvId);

    print('CV ANALYSIS URL: $url');
    print('CV ANALYSIS TOKEN: $token');

    final response = await http.post(
      Uri.parse(url),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    print('CV ANALYSIS STATUS: ${response.statusCode}');
    print('CV ANALYSIS BODY: ${response.body}');

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CvAnalysisResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل تحليل السيرة الذاتية');
  }
}
