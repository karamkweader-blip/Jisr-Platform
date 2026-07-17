import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_details_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_progress_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_submission_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_submission_review_model.dart';
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

bool _looksLikeMissingResource(String message) {
  final normalizedMessage = message.toLowerCase();

  return normalizedMessage.contains('not found') ||
      normalizedMessage.contains('no submission') ||
      normalizedMessage.contains('no final submission') ||
      normalizedMessage.contains('final submission') ||
      normalizedMessage.contains('no review') ||
      normalizedMessage.contains('لا يوجد') ||
      normalizedMessage.contains('لا توجد') ||
      normalizedMessage.contains('غير موجود') ||
      normalizedMessage.contains('غير موجودة') ||
      normalizedMessage.contains('لم يتم العثور');
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

Future<CompanyTaskAssignmentSubmissionModel?> getTaskAssignmentSubmission(
  int assignmentId,
) async {
  try {
    if (assignmentId <= 0) {
      throw Exception('معرف التكليف غير صالح');
    }

    final response = await http
        .get(
          Uri.parse(
            ApiLinks.companyTaskAssignmentSubmission(assignmentId),
          ),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
        );

    final decodedBody = _decodeBody(response.body);

    if (response.statusCode == 404) {
      return null;
    }

    if (_isSuccess(response.statusCode)) {
      if (decodedBody['status'] == false) {
        final message = decodedBody['message']?.toString() ??
            'تعذر تحميل التسليم النهائي';

        if (decodedBody['data'] == null &&
            _looksLikeMissingResource(message)) {
          return null;
        }

        throw Exception(message);
      }

      final data = decodedBody['data'];

      if (data == null) {
        return null;
      }

      if (data is! Map) {
        throw Exception('صيغة بيانات التسليم النهائي غير صحيحة');
      }

      return CompanyTaskAssignmentSubmissionModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception(
      decodedBody['message']?.toString() ??
          'تعذر تحميل التسليم النهائي',
    );
  } on FormatException {
    throw Exception('تعذر قراءة استجابة الخادم');
  } catch (e) {
    throw Exception(
      e.toString().replaceFirst('Exception: ', ''),
    );
  }
}

Future<CompanyTaskSubmissionReviewModel?> getSubmissionReview(
  int submissionId,
) async {
  try {
    if (submissionId <= 0) {
      throw Exception('معرف التسليم غير صالح');
    }

    final response = await http
        .get(
          Uri.parse(
            ApiLinks.companyTaskSubmissionReview(submissionId),
          ),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
        );

    final decodedBody = _decodeBody(response.body);

    if (response.statusCode == 404) {
      return null;
    }

    if (_isSuccess(response.statusCode)) {
      if (decodedBody['status'] == false) {
        final message = decodedBody['message']?.toString() ??
            'تعذر تحميل تقييم التسليم';

        if (decodedBody['data'] == null &&
            _looksLikeMissingResource(message)) {
          return null;
        }

        throw Exception(message);
      }

      final data = decodedBody['data'];

      if (data == null) {
        return null;
      }

      if (data is! Map) {
        throw Exception('صيغة بيانات تقييم التسليم غير صحيحة');
      }

      return CompanyTaskSubmissionReviewModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception(
      decodedBody['message']?.toString() ??
          'تعذر تحميل تقييم التسليم',
    );
  } on FormatException {
    throw Exception('تعذر قراءة استجابة الخادم');
  } catch (e) {
    throw Exception(
      e.toString().replaceFirst('Exception: ', ''),
    );
  }
}

Future<CompanyTaskSubmissionReviewModel> createSubmissionReview({
  required int submissionId,
  required CompanyTaskReviewRequest request,
}) async {
  try {
    if (submissionId <= 0) {
      throw Exception('معرف التسليم غير صالح');
    }

    if (!request.hasValidScores) {
      throw Exception('يجب أن تكون جميع الدرجات بين 0 و100');
    }

    if (!request.hasFeedback) {
      throw Exception('يرجى كتابة ملاحظات التقييم للطالب');
    }

    if (request.finalDecision.trim().isEmpty) {
      throw Exception('يرجى اختيار القرار النهائي');
    }

    final response = await http
        .post(
          Uri.parse(
            ApiLinks.companyTaskSubmissionReview(submissionId),
          ),
          headers: await _headers(),
          body: jsonEncode(request.toJson()),
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
              'تعذر حفظ تقييم التسليم',
        );
      }

      final data = decodedBody['data'];

      if (data is! Map) {
        throw Exception('صيغة نتيجة التقييم غير صحيحة');
      }

      return CompanyTaskSubmissionReviewModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception(
      decodedBody['message']?.toString() ??
          'تعذر حفظ تقييم التسليم',
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