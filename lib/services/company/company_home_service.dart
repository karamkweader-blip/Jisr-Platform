import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/company/company_home_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class CompanyHomeService {
  final AuthService _authService;

  CompanyHomeService(this._authService);

  Future<CompanyHomeModel> getCompanyHome() async {
    final token = await _authService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('انتهت الجلسة، يرجى تسجيل الدخول مجددًا');
    }

    final response = await http
        .get(
          Uri.parse(ApiLinks.companyHome),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال بالخادم');
          },
        );

    final Map<String, dynamic> decodedBody = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return CompanyHomeModel.fromJson(decodedBody);
    }

    final message = decodedBody['message'] as String? ??
        'تعذر تحميل بيانات الصفحة الرئيسية';

    throw Exception(message);
  }
}