import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/market_analysis/market_analysis_models.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class MarketAnalysisService {
  final AuthService _authService = AuthService();
  static const Duration _timeout = Duration(seconds: 20);

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

  Future<MarketCareerPathResponse> getCareerPaths({
    bool onlyWithMarketData = true,
  }) async {
    final uri = Uri.parse(ApiLinks.marketCareerPaths).replace(
      queryParameters: {
        if (onlyWithMarketData) 'only_with_market_data': '1',
      },
    );

    final response = await http.get(uri, headers: await _headers()).timeout(_timeout);
    final data = _decode(response.body);

    if (response.statusCode == 200) {
      return MarketCareerPathResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب مسارات سوق العمل');
  }

  Future<MarketSkillDemandResponse> getSkillDemand({
    required int careerPathId,
  }) async {
    final response = await http
        .get(
          Uri.parse(ApiLinks.marketSkillDemand(careerPathId)),
          headers: await _headers(),
        )
        .timeout(_timeout);
    final data = _decode(response.body);

    if (response.statusCode == 200) {
      return MarketSkillDemandResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب طلب المهارات');
  }

  Future<MarketTrendResponse> getTrends({
    required int careerPathId,
    String? date,
  }) async {
    final uri = Uri.parse(ApiLinks.marketTrends(careerPathId)).replace(
      queryParameters: {
        if (date != null && date.trim().isNotEmpty) 'date': date.trim(),
      },
    );

    final response = await http.get(uri, headers: await _headers()).timeout(_timeout);
    final data = _decode(response.body);

    if (response.statusCode == 200) {
      return MarketTrendResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب اتجاهات السوق');
  }

  Future<MarketSkillEvidenceResponse> getSkillEvidence({
    required int careerPathId,
    required int skillId,
    int limit = 10,
  }) async {
    final uri = Uri.parse(ApiLinks.marketSkillEvidence(
      careerPathId: careerPathId,
      skillId: skillId,
    )).replace(
      queryParameters: {'limit': limit.toString()},
    );

    final response = await http.get(uri, headers: await _headers()).timeout(_timeout);
    final data = _decode(response.body);

    if (response.statusCode == 200) {
      return MarketSkillEvidenceResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب أدلة المهارة');
  }

  Map<String, dynamic> _decode(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    return Map<String, dynamic>.from(jsonDecode(body));
  }
}
