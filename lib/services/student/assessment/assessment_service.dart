import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/assessment/assessment_models.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class NextQuestionResult {
  final AssessmentQuestion? question;
  final bool isSkillCompleted;
  final String message;

  NextQuestionResult({
    required this.question,
    required this.isSkillCompleted,
    required this.message,
  });
}

class AssessmentService {
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

  Future<AssessmentSessionResponse> createAssessment({
    required int careerPathId,
    required int cvId,
    required List<int> skillIds,
  }) async {
    final response = await http.post(
      Uri.parse(ApiLinks.createAssessment),
      headers: await _headers(),
      body: jsonEncode({
        'career_path_id': careerPathId,
        'cv_id': cvId,
        'skill_ids': skillIds,
      }),
    );

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AssessmentSessionResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل إنشاء جلسة الاختبار');
  }

  Future<NextQuestionResult> getNextQuestion({
    required int assessmentSessionId,
    required int skillId,
  }) async {
    final response = await http.post(
      Uri.parse(
        ApiLinks.nextAssessmentQuestion(
          assessmentSessionId: assessmentSessionId,
          skillId: skillId,
        ),
      ),
      headers: await _headers(),
    );

    print('STATUS CODE: ${response.statusCode}');
    print('BODY: ${response.body}');

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data['success'] == true &&
          data['data'] == null &&
          data['message'].toString().toLowerCase().contains(
            'already completed',
          )) {
        return NextQuestionResult(
          question: null,
          isSkillCompleted: true,
          message: data['message'] ?? '',
        );
      }

      if (data['data'] is Map<String, dynamic>) {
        return NextQuestionResult(
          question: AssessmentQuestion.fromJson(data['data']),
          isSkillCompleted: false,
          message: data['message'] ?? '',
        );
      }
    }

    throw Exception(response.body);
  }

  Future<AssessmentAnswerResult> submitAnswer({
    required int assessmentSessionId,
    required int attemptId,
    required String answer,
  }) async {
    final response = await http.post(
      Uri.parse(
        ApiLinks.submitAssessmentAnswer(
          assessmentSessionId: assessmentSessionId,
          attemptId: attemptId,
        ),
      ),
      headers: await _headers(),
      body: jsonEncode({'answer_text': answer}),
    );

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AssessmentAnswerResult.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل إرسال الإجابة');
  }

  Future<AssessmentCompleteResponse> completeAssessment({
    required int assessmentSessionId,
  }) async {
    final response = await http.post(
      Uri.parse(
        ApiLinks.completeAssessment(assessmentSessionId: assessmentSessionId),
      ),
      headers: await _headers(),
      body: jsonEncode({}),
    );

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AssessmentCompleteResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل إنهاء جلسة الاختبار');
  }
}
