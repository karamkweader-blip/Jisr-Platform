import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/company/company_profile_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class CompanyProfileService {
  final AuthService _authService;

  CompanyProfileService(this._authService);

  Future<CompanyProfileModel> getCompanyProfile() async {
    final token = await _authService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('انتهت الجلسة، يرجى تسجيل الدخول مجددًا');
    }

    final response = await http
        .get(
          Uri.parse(ApiLinks.companyProfile),
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

    final decodedBody = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return CompanyProfileModel.fromJson(decodedBody);
    }

    throw Exception(
      decodedBody['message'] as String? ?? 'تعذر تحميل ملف الشركة',
    );
  }



Future<CompanyProfileModel> updateCompanyProfile({
  required Map<String, dynamic> body,
}) async {
  final token = await _authService.getToken();

  if (token == null || token.isEmpty) {
    throw Exception('انتهت الجلسة، يرجى تسجيل الدخول مجددًا');
  }

  final response = await http
      .post(
        Uri.parse(ApiLinks.editCompanyProfile),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      )
      .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('انتهت مهلة الاتصال بالخادم');
        },
      );

  final decodedBody = response.body.isNotEmpty
      ? jsonDecode(response.body) as Map<String, dynamic>
      : <String, dynamic>{};

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return CompanyProfileModel.fromJson(decodedBody);
  }

  throw Exception(
    decodedBody['message'] as String? ?? 'تعذر تحديث ملف الشركة',
  );
}

}