import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/auth/register_company_request.dart';

class RegisterCompanyService {
  // static const String _baseUrl = 'http://10.33.50.250:8000/api/register';

  Future<void> register(RegisterCompanyRequest request) async {
    try {
      final uri = Uri.parse(ApiLinks.register);

      final multipartRequest = http.MultipartRequest('POST', uri);

      // إضافة الحقول
      multipartRequest.fields.addAll(request.toFields());

      // إضافة الملف
      multipartRequest.files.add(
        await http.MultipartFile.fromPath(
          'documentation_file',
          request.documentationFilePath,
        ),
      );

      final response = await multipartRequest.send();

      final responseBody = await response.stream.bytesToString();
      
print('STATUS CODE: ${response.statusCode}');
print('RESPONSE BODY: $responseBody'); 

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        final decoded = jsonDecode(responseBody);
        throw decoded['message'] ?? 'حدث خطأ أثناء التسجيل';
      }
    } catch (e) {
      throw 'فشل الاتصال بالخادم';
    }
  }
}