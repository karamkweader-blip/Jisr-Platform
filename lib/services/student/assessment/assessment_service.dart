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

  bool _isTrue(dynamic value) {
    final text = value?.toString().toLowerCase().trim();
    return value == true || text == '1' || text == 'true';
  }

  bool _messageMeansSkillCompleted(String message) {
    final lower = message.toLowerCase();

    return lower.contains('already completed') ||
        lower.contains('skill completed') ||
        lower.contains('completedat') ||
        lower.contains('completed') ||
        message.contains('اكتمل') ||
        message.contains('اكتملت') ||
        message.contains('مكتمل') ||
        message.contains('انتهت') ||
        message.contains('انتهى') ||
        message.contains('خلصت');
  }

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
      final message = data['message']?.toString() ?? '';
      final responseData = data['data'];

      final hasCompletedFlag =
          _isTrue(data['isSkillCompleted']) ||
          _isTrue(data['is_skill_completed']) ||
          _isTrue(data['skill_completed']) ||
          (responseData is Map<String, dynamic> &&
              (_isTrue(responseData['isSkillCompleted']) ||
                  _isTrue(responseData['is_skill_completed']) ||
                  _isTrue(responseData['skill_completed'])));

      if (responseData is Map<String, dynamic> &&
          responseData['attempt_id'] != null &&
          responseData['question_id'] != null &&
          responseData['question_text'] != null) {
        return NextQuestionResult(
          question: AssessmentQuestion.fromJson(responseData),
          isSkillCompleted: false,
          message: message,
        );
      }

      if (hasCompletedFlag ||
          (data['success'] == true &&
              (responseData == null || responseData == false) &&
              _messageMeansSkillCompleted(message))) {
        return NextQuestionResult(
          question: null,
          isSkillCompleted: true,
          message: message,
        );
      }

      if (responseData is Map<String, dynamic> &&
          _messageMeansSkillCompleted(message)) {
        return NextQuestionResult(
          question: null,
          isSkillCompleted: true,
          message: message,
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

  Future<AssessmentSummaryResponse> getAssessmentSummary({
    required int assessmentSessionId,
  }) async {
    final response = await http.get(
      Uri.parse(
        ApiLinks.assessmentSummary(assessmentSessionId: assessmentSessionId),
      ),
      headers: await _headers(),
    );

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200) {
      return AssessmentSummaryResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب ملخص الاختبار');
  }

  Future<AssessmentSkillGapsResponse> getSkillGaps({
    required int assessmentSessionId,
  }) async {
    final response = await http.get(
      Uri.parse(
        ApiLinks.assessmentSkillGaps(assessmentSessionId: assessmentSessionId),
      ),
      headers: await _headers(),
    );

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200) {
      return AssessmentSkillGapsResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل حساب فجوات المهارات');
  }

  Future<AssessmentLearningPathResponse> getLearningPath({
    required int assessmentSessionId,
  }) async {
    final response = await http.get(
      Uri.parse(
        ApiLinks.assessmentLearningPath(
          assessmentSessionId: assessmentSessionId,
        ),
      ),
      headers: await _headers(),
    );

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200) {
      return AssessmentLearningPathResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب خطة التعلم');
  }

  Future<AssessmentAiLearningPlanResponse> generateAiLearningPlan({
    required int assessmentSessionId,
    required int weeks,
    required int hoursPerWeek,
  }) async {
    final response = await http.post(
      Uri.parse(
        ApiLinks.aiLearningPlan(assessmentSessionId: assessmentSessionId),
      ),
      headers: await _headers(),
      body: jsonEncode({'weeks': weeks, 'hours_per_week': hoursPerWeek}),
    );

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AssessmentAiLearningPlanResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل إنشاء خطة التعلم الذكية');
  }

  Future<AssessmentAiLearningPlanResponse> getLatestAiLearningPlan({
    required int assessmentSessionId,
  }) async {
    final response = await http.get(
      Uri.parse(
        ApiLinks.latestAiLearningPlan(assessmentSessionId: assessmentSessionId),
      ),
      headers: await _headers(),
    );

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200) {
      return AssessmentAiLearningPlanResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب آخر خطة تعلم');
  }
}
