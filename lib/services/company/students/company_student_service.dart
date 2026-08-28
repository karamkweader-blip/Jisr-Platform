import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/company/students/company_student_details_model.dart';
import 'package:jisr_platform/models/company/students/company_student_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class CompanyStudentService {
  final AuthService _authService;

  CompanyStudentService(this._authService);

  static const Duration _timeout =
      Duration(seconds: 15);

  Future<CompanyStudentSearchResult> getStudents({
    String? name,
    int? skillId,
    int page = 1,
    int perPage = 10,
  }) async {
    if (page < 1) {
      throw Exception('رقم الصفحة غير صالح');
    }

    if (perPage < 1 || perPage > 100) {
      throw Exception(
        'عدد النتائج في الصفحة غير صالح',
      );
    }

    if (skillId != null && skillId <= 0) {
      throw Exception('المهارة المحددة غير صالحة');
    }

    final normalizedName = name?.trim();

    final uri = Uri.parse(
      ApiLinks.companyStudents,
    ).replace(
      queryParameters: <String, String>{
        if (normalizedName != null &&
            normalizedName.isNotEmpty)
          'name': normalizedName,
        if (skillId != null)
          'skill_id': skillId.toString(),
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
    );

    final body = await _send(
      () async => http.get(
        uri,
        headers: await _headers(),
      ),
      fallbackMessage: 'تعذر تحميل الطلاب',
    );

    final data = body['data'];

    if (data is! Map) {
      throw Exception(
        'استجابة قائمة الطلاب غير صالحة',
      );
    }

    return CompanyStudentSearchResult.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<CompanyStudentDetailsModel>
      getStudentDetails(
    int studentId,
  ) async {
    if (studentId <= 0) {
      throw Exception('معرف الطالب غير صالح');
    }

    final body = await _send(
      () async => http.get(
        Uri.parse(
          ApiLinks.companyStudentDetails(studentId),
        ),
        headers: await _headers(),
      ),
      fallbackMessage: 'تعذر تحميل تفاصيل الطالب',
    );

    final data = body['data'];

    if (data is! Map) {
      throw Exception(
        'استجابة تفاصيل الطالب غير صالحة',
      );
    }

    final student =
        CompanyStudentDetailsModel.fromJson(
      Map<String, dynamic>.from(data),
    );

    if (student.id <= 0) {
      throw Exception(
        'بيانات الطالب المستلمة غير صالحة',
      );
    }

    return student;
  }

  Future<List<CompanyStudentFilterSkill>>
      getAvailableSkills() async {
    final body = await _send(
      () async => http.get(
        Uri.parse(ApiLinks.skills),
        headers: await _headers(),
      ),
      fallbackMessage: 'تعذر تحميل المهارات',
    );

    final data = body['data'];

    if (data is! List) {
      throw Exception(
        'استجابة قائمة المهارات غير صالحة',
      );
    }

    final skills = data
        .whereType<Map>()
        .map(
          (item) =>
              CompanyStudentFilterSkill.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where(
          (skill) =>
              skill.id > 0 && skill.name.isNotEmpty,
        )
        .toList()
      ..sort(
        (first, second) =>
            first.name.toLowerCase().compareTo(
                  second.name.toLowerCase(),
                ),
      );

    return skills;
  }

  Future<Map<String, String>> _headers() async {
    final token =
        (await _authService.getToken())?.trim();

    if (token == null || token.isEmpty) {
      throw Exception(
        'انتهت الجلسة، يرجى تسجيل الدخول مجددًا',
      );
    }

    return <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request, {
    required String fallbackMessage,
  }) async {
    try {
      final response =
          await request().timeout(_timeout);

      final body = _decode(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          body['status'] != false &&
          body['success'] != false) {
        return body;
      }

      throw Exception(
        _responseMessage(
          body: body,
          statusCode: response.statusCode,
          fallbackMessage: fallbackMessage,
        ),
      );
    } on TimeoutException {
      throw Exception(
        'انتهت مهلة الاتصال بالخادم',
      );
    } on FormatException {
      throw Exception(
        'تعذر قراءة استجابة الخادم',
      );
    } on http.ClientException {
      throw Exception(
        'تعذر الاتصال بالخادم، تحقق من الشبكة وحاول مجددًا',
      );
    } catch (error) {
      throw Exception(_cleanError(error));
    }
  }

  Map<String, dynamic> _decode(String rawBody) {
    if (rawBody.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(rawBody);

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    throw const FormatException();
  }

  String _responseMessage({
    required Map<String, dynamic> body,
    required int statusCode,
    required String fallbackMessage,
  }) {
    final serverMessage =
        body['message']?.toString().trim();

    if (serverMessage != null &&
        serverMessage.isNotEmpty) {
      return serverMessage;
    }

    return switch (statusCode) {
      401 =>
        'انتهت الجلسة، يرجى تسجيل الدخول مجددًا',
      403 =>
        'ليس لديك صلاحية للوصول إلى بيانات الطلاب',
      404 => 'الطالب المطلوب غير موجود',
      422 => 'بيانات البحث المرسلة غير صالحة',
      >= 500 =>
        'حدث خطأ في الخادم، حاول مجددًا لاحقًا',
      _ => fallbackMessage,
    };
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '');
  }
}