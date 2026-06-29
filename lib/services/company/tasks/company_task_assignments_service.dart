import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_details_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_progress_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class CompanyTaskAssignmentsService {
  final AuthService _authService;

  CompanyTaskAssignmentsService(this._authService);

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

  Future<List<CompanyTaskAssignmentModel>> getTaskAssignments() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiLinks.companyTaskAssignments),
            headers: await _headers(),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
          );

      final decodedBody = _decodeBody(response.body);

      if (_isSuccess(response.statusCode)) {
        final data = decodedBody['data'];

        if (data is! List) {
          throw Exception('صيغة بيانات التكليفات غير صحيحة');
        }

        return data
            .whereType<Map>()
            .map(
              (item) => CompanyTaskAssignmentModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      throw Exception(
        decodedBody['message'] as String? ??
            'تعذر تحميل المهام قيد المتابعة',
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

  Future<CompanyTaskAssignmentDetailsModel> getTaskAssignmentDetails(
  int assignmentId,
) async {
  try {
    if (assignmentId <= 0) {
      throw Exception('معرف التكليف غير صالح');
    }

    final response = await http
        .get(
          Uri.parse(
            ApiLinks.companyTaskAssignmentDetails(assignmentId),
          ),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
        );

    final decodedBody = _decodeBody(response.body);

    if (_isSuccess(response.statusCode)) {
      final data = decodedBody['data'];

      if (data is! Map) {
        throw Exception('صيغة تفاصيل التكليف غير صحيحة');
      }

      return CompanyTaskAssignmentDetailsModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception(
      decodedBody['message'] as String? ??
          'تعذر تحميل تفاصيل التكليف',
    );
  } on FormatException {
    throw Exception('تعذر قراءة استجابة الخادم');
  } catch (e) {
    throw Exception(
      e.toString().replaceFirst('Exception: ', ''),
    );
  }
}
Future<CompanyTaskAssignmentProgressModel> getTaskAssignmentProgress(
  int assignmentId,
) async {
  try {
    if (assignmentId <= 0) {
      throw Exception('معرف التكليف غير صالح');
    }

    final response = await http
        .get(
          Uri.parse(
            ApiLinks.companyTaskAssignmentProgress(assignmentId),
          ),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
        );

    final decodedBody = _decodeBody(response.body);

    if (_isSuccess(response.statusCode)) {
      if (decodedBody['status'] == false) {
        throw Exception(
          decodedBody['message']?.toString() ??
              'تعذر تحميل تحديثات التقدم',
        );
      }

      final data = decodedBody['data'];

      if (data is! Map) {
        throw Exception('صيغة بيانات التقدم غير صحيحة');
      }

      return CompanyTaskAssignmentProgressModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception(
      decodedBody['message']?.toString() ??
          'تعذر تحميل تحديثات التقدم',
    );
  } on FormatException {
    throw Exception('تعذر قراءة استجابة الخادم');
  } catch (e) {
    throw Exception(
      e.toString().replaceFirst('Exception: ', ''),
    );
  }
}
}