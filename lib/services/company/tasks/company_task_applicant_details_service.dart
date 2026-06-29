import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/company/tasks/company_task_applicant_details_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class CompanyTaskApplicantDetailsService {
  final AuthService _authService;

  CompanyTaskApplicantDetailsService(this._authService);

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('انتهت الجلسة، يرجى تسجيل الدخول مجددًا');
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<CompanyTaskApplicantDetailsModel> getApplicantDetails(
    int applicationId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiLinks.companyTaskApplicantDetails(applicationId)),
            headers: await _headers(),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
          );

      final decodedBody = _decodeBody(response.body);

      if (_isSuccess(response.statusCode)) {
        final data = decodedBody['data'];

        if (data is! Map<String, dynamic>) {
          throw Exception('صيغة بيانات المتقدم غير صحيحة');
        }

        return CompanyTaskApplicantDetailsModel.fromJson(data);
      }

      throw Exception(
        decodedBody['message'] as String? ?? 'تعذر تحميل تفاصيل المتقدم',
      );
    } on FormatException {
      throw Exception('تعذر قراءة استجابة تفاصيل المتقدم');
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> acceptApplication({
    required int applicationId,
    required String companyNotes,
  }) async {
    await _sendDecisionRequest(
      url: ApiLinks.acceptTaskApplication(applicationId),
      companyNotes: companyNotes,
      fallbackMessage: 'تعذر قبول الطالب',
    );
  }

  Future<void> rejectApplication({
    required int applicationId,
    required String companyNotes,
  }) async {
    await _sendDecisionRequest(
      url: ApiLinks.rejectTaskApplication(applicationId),
      companyNotes: companyNotes,
      fallbackMessage: 'تعذر رفض الطالب',
    );
  }

  Future<void> _sendDecisionRequest({
    required String url,
    required String companyNotes,
    required String fallbackMessage,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: await _headers(),
            body: jsonEncode({
              'company_notes': companyNotes,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
          );

      final decodedBody = _decodeBody(response.body);

      if (_isSuccess(response.statusCode)) {
        return;
      }

      throw Exception(
        decodedBody['message'] as String? ?? fallbackMessage,
      );
    } on FormatException {
      throw Exception('تعذر قراءة استجابة الخادم');
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  bool _isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }
}