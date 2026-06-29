import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/task_progress/student_task_progress_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class StudentTaskProgressService {
  final AuthService _authService = AuthService();

  Future<String> _token() async {
    final token = (await _authService.getToken())?.trim();

    if (token == null || token.isEmpty) {
      throw Exception('انتهت الجلسة، يرجى تسجيل الدخول من جديد');
    }

    return token;
  }

  Future<Map<String, String>> _headers() async {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${await _token()}',
    };
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) return {};

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'message': 'استجابة غير مفهومة من الخادم'};
    }
  }

  Future<TaskProgressResponse> getProgress(int assignmentId) async {
    final response = await http
        .get(
          Uri.parse(ApiLinks.taskAssignmentProgress(assignmentId)),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال بجلب تقدم التاسك');
          },
        );

    print('TASK PROGRESS STATUS: ${response.statusCode}');
    print('TASK PROGRESS BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      return TaskProgressResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب تقدم التاسك');
  }

  Future<TaskProgressUpdateResponse> addProgressUpdate({
    required int assignmentId,
    required String title,
    required String description,
    required int percentage,
    String? githubUrl,
    String? demoUrl,
    List<File> attachments = const [],
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiLinks.taskAssignmentProgress(assignmentId)),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer ${await _token()}',
    });

    // أسماء الحقول حسب خطأ Laravel 422 بالضبط
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['progress_percentage'] = percentage.toString();

    if (githubUrl != null && githubUrl.trim().isNotEmpty) {
      request.fields['github_url'] = githubUrl.trim();
    }

    if (demoUrl != null && demoUrl.trim().isNotEmpty) {
      request.fields['demo_url'] = demoUrl.trim();
    }

    for (final file in attachments) {
      request.files.add(
        await http.MultipartFile.fromPath('attachments[]', file.path),
      );
    }

    print('ADD PROGRESS FIELDS: ${request.fields}');
    print('ADD PROGRESS FILES COUNT: ${request.files.length}');

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception('انتهت مهلة الاتصال أثناء إضافة تحديث التقدم');
      },
    );

    final response = await http.Response.fromStream(streamedResponse);

    print('ADD PROGRESS STATUS: ${response.statusCode}');
    print('ADD PROGRESS BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return TaskProgressUpdateResponse.fromJson(data);
    }

    if (data['errors'] is Map) {
      final errors = data['errors'] as Map;

      final firstError = errors.values.isNotEmpty
          ? (errors.values.first as List?)?.first?.toString()
          : null;

      throw Exception(
        firstError ?? data['message'] ?? 'فشل إضافة تحديث التقدم',
      );
    }

    throw Exception(data['message'] ?? 'فشل إضافة تحديث التقدم');
  }

  Future<Map<String, dynamic>> submitFinalTask({
    required int assignmentId,
    required String notes,
    String? githubUrl,
    String? demoUrl,
    List<File> attachments = const [],
  }) async {
    final cleanNotes = notes.trim();
    final hasGithub = githubUrl != null && githubUrl.trim().isNotEmpty;
    final hasDemo = demoUrl != null && demoUrl.trim().isNotEmpty;
    final hasFiles = attachments.isNotEmpty;

    if (cleanNotes.isEmpty) {
      throw Exception('ملاحظات التسليم مطلوبة');
    }

    if (!hasGithub && !hasDemo && !hasFiles) {
      throw Exception(
        'يجب إضافة رابط GitHub أو رابط Demo أو ملف واحد على الأقل للتسليم النهائي',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiLinks.taskAssignmentSubmission(assignmentId)),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer ${await _token()}',
    });

    request.fields['notes'] = cleanNotes;

    if (hasGithub) {
      request.fields['github_url'] = githubUrl.trim();
    }

    if (hasDemo) {
      request.fields['demo_url'] = demoUrl.trim();
    }

    if (hasFiles) {
      final file = attachments.first;
      final fileSize = await file.length();

      print('FINAL SUBMISSION FILE PATH: ${file.path}');
      print('FINAL SUBMISSION FILE SIZE: $fileSize bytes');

      request.files.add(
        await http.MultipartFile.fromPath('zip_file', file.path),
      );
    }

    print(
      'FINAL SUBMISSION URL: ${ApiLinks.taskAssignmentSubmission(assignmentId)}',
    );
    print('FINAL SUBMISSION FIELDS: ${request.fields}');
    print('FINAL SUBMISSION FILES COUNT: ${request.files.length}');
    print(
      'FINAL SUBMISSION FILE FIELD: ${request.files.isNotEmpty ? request.files.first.field : 'NO FILE'}',
    );
    print(
      'FINAL SUBMISSION FILE NAME: ${request.files.isNotEmpty ? request.files.first.filename : 'NO FILE'}',
    );

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 120),
      onTimeout: () {
        throw Exception(
          'انتهت مهلة الاتصال أثناء التسليم النهائي. جرّبي ملف أصغر أو انتظري أكثر، لأن الملف يتم رفعه لكن السيرفر تأخر بالرد.',
        );
      },
    );

    final response = await http.Response.fromStream(streamedResponse);

    print('FINAL SUBMISSION STATUS: ${response.statusCode}');
    print('FINAL SUBMISSION BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }

    if (data['errors'] is Map) {
      final errors = data['errors'] as Map;

      final firstError = errors.values.isNotEmpty
          ? (errors.values.first as List?)?.first?.toString()
          : null;

      throw Exception(firstError ?? data['message'] ?? 'فشل التسليم النهائي');
    }

    throw Exception(data['message'] ?? 'فشل التسليم النهائي');
  }
}
