import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/company/tasks/company_task_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class CompanyTaskService {
  final AuthService _authService;

  CompanyTaskService(this._authService);

static const Set<String> _allowedTaskStatuses = {
  'draft',
  'published',
  'in_progress',
  'closed',
  'cancelled',
};
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

  Future<List<CompanyTaskModel>> getCompanyTasks({
  String? status,
}) async {
  final normalizedStatus = status?.trim();

  if (normalizedStatus != null &&
      normalizedStatus.isNotEmpty &&
      !_allowedTaskStatuses.contains(normalizedStatus)) {
    throw Exception('حالة المهمة المحددة غير صالحة');
  }

  try {
    final response = await http
        .post(
          Uri.parse(ApiLinks.companyTasksIndex),
          headers: await _headers(),
          body: normalizedStatus == null || normalizedStatus.isEmpty
              ? null
              : jsonEncode({
                  'status': normalizedStatus,
                }),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
        );

    final decodedBody = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};

    if (decodedBody is! Map<String, dynamic>) {
      throw Exception('استجابة قائمة المهام غير صالحة');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = decodedBody['data'];

      if (data is! List) {
        return <CompanyTaskModel>[];
      }

      return data
          .whereType<Map>()
          .map(
            (item) => CompanyTaskModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    throw Exception(
      decodedBody['message']?.toString() ?? 'تعذر تحميل المهام',
    );
  } on FormatException {
    throw Exception('تعذر قراءة استجابة الخادم');
  } catch (e) {
    throw Exception(
      e.toString().replaceFirst('Exception: ', ''),
    );
  }
}

  Future<CompanyTaskModel> createTask(CreateCompanyTaskRequest request) async {
    final response = await http
        .post(
          Uri.parse(ApiLinks.companyTasks),
          headers: await _headers(),
          body: jsonEncode(request.toJson()),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
        );

    final decodedBody = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return CompanyTaskModel.fromJson(
        decodedBody['data'] as Map<String, dynamic>? ?? {},
      );
    }
   print(response.body); 
    throw Exception(
      decodedBody['message'] as String? ?? 'تعذر إنشاء المهمة',
      );
  }

  Future<CompanyTaskModel> publishTask(int taskId) async {
    final response = await http
        .patch(
          Uri.parse(ApiLinks.publishCompanyTask(taskId)),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
        );

    final decodedBody = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return CompanyTaskModel.fromJson(
        decodedBody['data'] as Map<String, dynamic>? ?? {},
      );
    }

    throw Exception(
      decodedBody['message'] as String? ?? 'تعذر نشر المهمة',
    );
  }

 Future<List<AvailableSkillModel>> getAvailableSkills() async {
  final token = await _authService.getToken();
  try {
    final response = await http.get(
      Uri.parse(ApiLinks.skills),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    );

    final decodedBody = jsonDecode(response.body);

    if (decodedBody is! Map<String, dynamic>) {
      throw Exception('استجابة المهارات غير صالحة');
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        decodedBody['message']?.toString() ??
            'تعذر تحميل المهارات',
      );
    }

    if (decodedBody['status'] != true) {
      throw Exception(
        decodedBody['message']?.toString() ??
            'تعذر تحميل المهارات',
      );
    }

    final data = decodedBody['data'];

    if (data is! List) {
      throw Exception('قائمة المهارات غير صالحة');
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(AvailableSkillModel.fromJson)
        .where((skill) => skill.id > 0)
        .toList();
  } on FormatException {
    throw Exception('تعذر قراءة استجابة المهارات');
  } catch (e) {
    throw Exception(
      e.toString().replaceFirst('Exception: ', ''),
    );
  }
}
  
}