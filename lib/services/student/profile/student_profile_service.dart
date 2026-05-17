import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/profile/student_profile_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'dart:io';

class StudentProfileService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = (await _authService.getToken())?.trim();

    if (token == null || token.isEmpty) {
      throw Exception('انتهت الجلسة، يرجى تسجيل الدخول من جديد');
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<StudentProfileResponse> getProfile() async {
    final response = await http.get(
      Uri.parse(ApiLinks.studentProfile),
      headers: await _headers(),
    );

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200) {
      return StudentProfileResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب الملف الشخصي');
  }

  Future<StudentProfileResponse> updateProfile({
    required String name,
    required String email,
    required String bio,
    required String university,
    required String major,
    required String graduationYear,
    required String phone,
    File? profileImage,
  }) async {
    final token = (await _authService.getToken())?.trim();

    if (token == null || token.isEmpty) {
      throw Exception('انتهت الجلسة، يرجى تسجيل الدخول من جديد');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiLinks.editStudentProfile),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.fields.addAll({
      'name': name,
      'email': email,
      'bio': bio,
      'university': university,
      'major': major,
      'graduation_year': graduationYear,
      'phone': phone,
    });

    if (profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profile_picture', profileImage.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200 || response.statusCode == 201) {
      return StudentProfileResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل حفظ تعديلات الملف الشخصي');
  }
}
