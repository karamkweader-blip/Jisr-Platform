import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/mentor/student_mentor_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class StudentMentorService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = (await _authService.getToken())?.trim();
    if (token == null || token.isEmpty) {
      throw const MentorApiException(
        statusCode: 401,
        message: 'انتهت الجلسة، يرجى تسجيل الدخول من جديد',
      );
    }

    return <String, String>{
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      // A clear fallback is returned below for non-JSON server responses.
    }
    return <String, dynamic>{'message': 'استجابة غير مفهومة من الخادم'};
  }

  MentorApiException _apiException(
    http.Response response,
    Map<String, dynamic> data,
    String fallback,
  ) {
    final backendMessage = data['message']?.toString().trim();
    return MentorApiException(
      statusCode: response.statusCode,
      message: _firstError(data) ??
          (backendMessage != null && backendMessage.isNotEmpty
              ? backendMessage
              : fallback),
      errors: data['errors'] is Map
          ? Map<String, dynamic>.from(data['errors'])
          : const <String, dynamic>{},
    );
  }

  String? _firstError(Map<String, dynamic> data) {
    final errors = data['errors'];
    if (errors is! Map) return null;
    for (final value in errors.values) {
      if (value is List && value.isNotEmpty) return value.first.toString();
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  Future<MentorApplicationModel?> getMyApplication() async {
    final response = await http
        .get(
          Uri.parse(ApiLinks.myMentorApplication),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () => throw Exception(
            'انتهت مهلة الاتصال عند جلب طلب الإرشاد',
          ),
        );

    final data = _decodeBody(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return MentorApplicationModel.fromJson(_map(data['data']));
    }

    if (response.statusCode == 404 &&
        data['message']?.toString() == 'No mentor application found.') {
      return null;
    }

    throw _apiException(response, data, 'تعذر جلب طلب الإرشاد');
  }

  Future<MentorApplicationModel> submitApplication({
    required String specialization,
    required String professionalTitle,
    required String expertise,
    required String bio,
    required String linkedinUrl,
    required String githubOrPortfolioUrl,
    required String whatsappNumber,
    required String cvPath,
    required List<String> mentoringTopics,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiLinks.mentorApplication),
    );
    request.headers.addAll(await _headers(json: false));
    request.fields.addAll(<String, String>{
      'specialization': specialization,
      'professional_title': professionalTitle,
      'expertise': expertise,
      'bio': bio,
      'linkedin_url': linkedinUrl,
      'github_or_portfolio_url': githubOrPortfolioUrl,
      'whatsapp_number': whatsappNumber,
    });
    for (var index = 0; index < mentoringTopics.length; index++) {
      request.fields['mentoring_topics[$index]'] = mentoringTopics[index];
    }
    request.files.add(await http.MultipartFile.fromPath('cv', cvPath));

    final streamed = await request.send().timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception(
            'انتهت مهلة الاتصال عند إرسال طلب الإرشاد',
          ),
        );
    final response = await http.Response.fromStream(streamed);
    final data = _decodeBody(response);

    if (response.statusCode == 201 && data['success'] == true) {
      return MentorApplicationModel.fromJson(_map(data['data']));
    }

    throw _apiException(response, data, 'تعذر إرسال طلب الإرشاد');
  }

  Future<StudentMentorsResponse> getMentors({
    String? search,
    String? specialization,
    int page = 1,
    int perPage = 20,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (specialization != null && specialization.trim().isNotEmpty) {
      query['specialization'] = specialization.trim();
    }

    final uri = Uri.parse(
      ApiLinks.studentMentors,
    ).replace(queryParameters: query);
    final response = await http
        .get(uri, headers: await _headers())
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () => throw Exception(
            'انتهت مهلة الاتصال عند جلب المرشدين',
          ),
        );
    final data = _decodeBody(response);

    if (response.statusCode == 200 && data['success'] == true) {
      return StudentMentorsResponse.fromJson(data);
    }

    throw _apiException(response, data, 'تعذر جلب المرشدين');
  }

  Future<StudentMentorModel> getMentorDetails(int mentorProfileId) async {
    if (mentorProfileId <= 0) {
      throw const MentorApiException(
        statusCode: 0,
        message: 'معرّف المرشد غير صالح',
      );
    }

    final response = await http
        .get(
          Uri.parse(ApiLinks.studentMentorDetails(mentorProfileId)),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () => throw Exception(
            'انتهت مهلة الاتصال عند جلب تفاصيل المرشد',
          ),
        );
    final data = _decodeBody(response);

    if (response.statusCode == 200 && data['success'] == true) {
      return StudentMentorModel.fromJson(_map(data['data']));
    }

    throw _apiException(response, data, 'تعذر جلب تفاصيل المرشد');
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }
}

class MentorApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic> errors;

  const MentorApiException({
    required this.statusCode,
    required this.message,
    this.errors = const <String, dynamic>{},
  });

  bool hasError(String key) {
    final value = errors[key];
    return value is List ? value.isNotEmpty : value != null;
  }

  @override
  String toString() => message;
}
