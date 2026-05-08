import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/cv/cv_upload_response.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class CvService {
  final AuthService _authService = AuthService();

  Future<CvUploadResponse> uploadCv({
    required String filePath,
    bool isPrimary = true,
  }) async {
    final token = (await _authService.getToken())?.trim();

    if (token == null || token.isEmpty) {
      throw Exception('انتهت الجلسة، يرجى تسجيل الدخول من جديد');
    }

    final request = http.MultipartRequest('POST', Uri.parse(ApiLinks.uploadCv));

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.fields['is_primary'] = isPrimary ? '1' : '0';

    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    print('CV UPLOAD URL: ${ApiLinks.uploadCv}');
    print('CV UPLOAD TOKEN: $token');
    print('CV UPLOAD FIELDS: ${request.fields}');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('CV UPLOAD STATUS: ${response.statusCode}');
    print('CV UPLOAD BODY: ${response.body}');

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CvUploadResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل رفع السيرة الذاتية');
  }
}
