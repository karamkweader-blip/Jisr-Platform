class AssessmentSessionResponse {
  final bool success;
  final String message;
  final AssessmentSessionData data;

  AssessmentSessionResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AssessmentSessionResponse.fromJson(Map<String, dynamic> json) {
    return AssessmentSessionResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: AssessmentSessionData.fromJson(json['data'] ?? {}),
    );
  }
}

class AssessmentSessionData {
  final int assessmentSessionId;
  final int cvId;
  final int careerPathId;
  final String status;
  final List<AssessmentSkillSession> skillSessions;

  AssessmentSessionData({
    required this.assessmentSessionId,
    required this.cvId,
    required this.careerPathId,
    required this.status,
    required this.skillSessions,
  });

  factory AssessmentSessionData.fromJson(Map<String, dynamic> json) {
    return AssessmentSessionData(
      assessmentSessionId:
          int.tryParse(json['AssessmentSessionID'].toString()) ?? 0,
      cvId: int.tryParse(json['CvID'].toString()) ?? 0,
      careerPathId: int.tryParse(json['CareerPathID'].toString()) ?? 0,
      status: json['Status']?.toString() ?? '',
      skillSessions: (json['skill_sessions'] as List? ?? [])
          .map((e) => AssessmentSkillSession.fromJson(e))
          .toList(),
    );
  }
}

class AssessmentSkillSession {
  final int assessmentSkillSessionId;
  final int assessmentSessionId;
  final int skillId;
  final double initialLevel;
  final double currentEstimatedLevel;
  final int questionCount;
  final String status;

  AssessmentSkillSession({
    required this.assessmentSkillSessionId,
    required this.assessmentSessionId,
    required this.skillId,
    required this.initialLevel,
    required this.currentEstimatedLevel,
    required this.questionCount,
    required this.status,
  });

  factory AssessmentSkillSession.fromJson(Map<String, dynamic> json) {
    return AssessmentSkillSession(
      assessmentSkillSessionId:
          int.tryParse(json['AssessmentSkillSessionID'].toString()) ?? 0,
      assessmentSessionId:
          int.tryParse(json['AssessmentSessionID'].toString()) ?? 0,
      skillId: int.tryParse(json['SkillID'].toString()) ?? 0,
      initialLevel: double.tryParse(json['InitialLevel'].toString()) ?? 0.0,
      currentEstimatedLevel:
          double.tryParse(json['CurrentEstimatedLevel'].toString()) ?? 0.0,
      questionCount: int.tryParse(json['QuestionCount'].toString()) ?? 0,
      status: json['Status']?.toString() ?? '',
    );
  }
}

class AssessmentQuestion {
  final int attemptId;
  final int questionId;
  final String questionText;
  final double questionLevel;
  final int skillId;
  final String skillName;

  AssessmentQuestion({
    required this.attemptId,
    required this.questionId,
    required this.questionText,
    required this.questionLevel,
    required this.skillId,
    required this.skillName,
  });

  factory AssessmentQuestion.fromJson(Map<String, dynamic> json) {
    return AssessmentQuestion(
      attemptId: int.tryParse(json['attempt_id'].toString()) ?? 0,
      questionId: int.tryParse(json['question_id'].toString()) ?? 0,
      questionText: json['question_text']?.toString() ?? '',
      questionLevel: double.tryParse(json['question_level'].toString()) ?? 0.0,
      skillId: int.tryParse(json['skill_id'].toString()) ?? 0,
      skillName: json['skill_name']?.toString() ?? '',
    );
  }
}

class AssessmentAnswerResult {
  final bool success;
  final String message;
  final int attemptId;
  final double normalizedScore;
  final String feedback;

  AssessmentAnswerResult({
    required this.success,
    required this.message,
    required this.attemptId,
    required this.normalizedScore,
    required this.feedback,
  });

  factory AssessmentAnswerResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return AssessmentAnswerResult(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      attemptId: int.tryParse(data['attempt_id'].toString()) ?? 0,
      normalizedScore:
          double.tryParse(data['normalized_score'].toString()) ?? 0.0,
      feedback: data['feedback']?.toString() ?? '',
    );
  }
}

class AssessmentCompleteResponse {
  final bool success;
  final String message;
  final AssessmentCompleteData data;

  AssessmentCompleteResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AssessmentCompleteResponse.fromJson(Map<String, dynamic> json) {
    return AssessmentCompleteResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: AssessmentCompleteData.fromJson(json['data'] ?? {}),
    );
  }
}

class AssessmentCompleteData {
  final int assessmentSessionId;
  final String status;
  final String completedAt;
  final List<AssessmentFinalResult> finalResults;

  AssessmentCompleteData({
    required this.assessmentSessionId,
    required this.status,
    required this.completedAt,
    required this.finalResults,
  });

  factory AssessmentCompleteData.fromJson(Map<String, dynamic> json) {
    return AssessmentCompleteData(
      assessmentSessionId:
          int.tryParse(json['AssessmentSessionID'].toString()) ?? 0,
      status: json['Status']?.toString() ?? '',
      completedAt: json['CompletedAt']?.toString() ?? '',
      finalResults: (json['FinalResultsJson'] as List? ?? [])
          .map((e) => AssessmentFinalResult.fromJson(e))
          .toList(),
    );
  }
}

class AssessmentFinalResult {
  final int skillId;
  final String initialLevel;
  final String? finalLevel;
  final String? confidenceScore;
  final String status;

  AssessmentFinalResult({
    required this.skillId,
    required this.initialLevel,
    required this.finalLevel,
    required this.confidenceScore,
    required this.status,
  });

  factory AssessmentFinalResult.fromJson(Map<String, dynamic> json) {
    return AssessmentFinalResult(
      skillId: int.tryParse(json['skill_id'].toString()) ?? 0,
      initialLevel: json['initial_level']?.toString() ?? '',
      finalLevel: json['final_level']?.toString(),
      confidenceScore: json['confidence_score']?.toString(),
      status: json['status']?.toString() ?? '',
    );
  }
}
