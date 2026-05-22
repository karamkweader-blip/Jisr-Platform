import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/portfolio/student_portfolio_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class StudentPortfolioService {
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

  Future<PortfolioProjectsResponse> getProjects() async {
    final response = await http.get(
      Uri.parse(ApiLinks.portfolioProjects),
      headers: await _headers(),
    );

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200) {
      return PortfolioProjectsResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب مشاريع البورتفوليو');
  }

  Future<PortfolioProjectResponse> getProjectDetails(int projectId) async {
    final response = await http.get(
      Uri.parse(ApiLinks.portfolioProjectDetails(projectId)),
      headers: await _headers(),
    );

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200) {
      return PortfolioProjectResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب تفاصيل المشروع');
  }

  Future<PortfolioProjectResponse> addProject({
    required String title,
    required String description,
    required String projectUrl,
    required String completionDate,
    required String grade,
  }) async {
    final response = await http.post(
      Uri.parse(ApiLinks.portfolioProjects),
      headers: await _headers(),
      body: jsonEncode({
        'title': title,
        'description': description,
        'project_url': projectUrl,
        'completion_date': completionDate,
        'grade': grade,
      }),
    );

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PortfolioProjectResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل إضافة المشروع');
  }

  Future<PortfolioProjectResponse> updateProject({
    required int projectId,
    required String title,
    required String description,
    required String projectUrl,
    required String completionDate,
    required String grade,
  }) async {
    final response = await http.put(
      Uri.parse(ApiLinks.updatePortfolioProject(projectId)),
      headers: await _headers(),
      body: jsonEncode({
        'title': title,
        'description': description,
        'project_url': projectUrl,
        'completion_date': completionDate,
        'grade': grade,
      }),
    );
    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PortfolioProjectResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل تعديل المشروع');
  }

  Future<String> deleteProject(int projectId) async {
    final response = await http.delete(
      Uri.parse(ApiLinks.deletePortfolioProject(projectId)),
      headers: await _headers(),
    );

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200 || response.statusCode == 204) {
      return data['message']?.toString() ?? 'تم حذف المشروع بنجاح';
    }

    throw Exception(data['message'] ?? 'فشل حذف المشروع');
  }
}
