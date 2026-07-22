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
      assessmentSessionId: int.tryParse(
            (json['AssessmentSessionID'] ?? json['assessment_session_id'] ?? json['id'] ?? 0).toString(),
          ) ??
          0,
      cvId: int.tryParse((json['CvID'] ?? json['cv_id'] ?? 0).toString()) ?? 0,
      careerPathId:
          int.tryParse((json['CareerPathID'] ?? json['career_path_id'] ?? 0).toString()) ?? 0,
      status: (json['Status'] ?? json['status'])?.toString() ?? '',
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
      assessmentSessionId: int.tryParse(
            (json['AssessmentSessionID'] ?? json['assessment_session_id'] ?? 0).toString(),
          ) ??
          0,
      skillId: int.tryParse(json['SkillID'].toString()) ?? 0,
      initialLevel: double.tryParse(json['InitialLevel'].toString()) ?? 0.0,
      currentEstimatedLevel:
          double.tryParse(json['CurrentEstimatedLevel'].toString()) ?? 0.0,
      questionCount: int.tryParse(json['QuestionCount'].toString()) ?? 0,
      status: json['Status']?.toString() ?? '',
    );
  }
}


dynamic _firstJsonValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key) && json[key] != null) return json[key];
  }
  return null;
}

int _jsonInt(Map<String, dynamic> json, List<String> keys) {
  final value = _firstJsonValue(json, keys);
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _jsonDouble(Map<String, dynamic> json, List<String> keys) {
  final value = _firstJsonValue(json, keys);
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}

String _jsonString(Map<String, dynamic> json, List<String> keys) {
  final value = _firstJsonValue(json, keys);
  return value?.toString() ?? '';
}

List<T> _jsonList<T>(
  Map<String, dynamic> json,
  List<String> keys,
  T Function(dynamic item) mapper,
) {
  final value = _firstJsonValue(json, keys);
  if (value is! List) return <T>[];
  return value.map(mapper).toList();
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
  final bool isSkillCompleted;
  final bool needsReview;

  AssessmentAnswerResult({
    required this.success,
    required this.message,
    required this.attemptId,
    required this.normalizedScore,
    required this.feedback,
    required this.isSkillCompleted,
    required this.needsReview,
  });

  factory AssessmentAnswerResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final completedValue =
        data['isSkillCompleted'] ??
        data['is_skill_completed'] ??
        data['skill_completed'] ??
        json['isSkillCompleted'] ??
        json['is_skill_completed'] ??
        json['skill_completed'];
    final completedText = completedValue?.toString().toLowerCase().trim();

    return AssessmentAnswerResult(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      attemptId: int.tryParse(data['attempt_id'].toString()) ?? 0,
      normalizedScore:
          double.tryParse(data['normalized_score'].toString()) ?? 0.0,
      feedback: data['feedback']?.toString() ?? '',
      isSkillCompleted:
          completedValue == true ||
          completedText == '1' ||
          completedText == 'true',
      needsReview: data['needs_review'] == true ||
          data['needs_review']?.toString().toLowerCase().trim() == 'true' ||
          data['needs_review']?.toString().trim() == '1',
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
  final String? completedAt;
  final bool finalResultsAvailable;
  final bool hasSkillsNeedingReview;
  final List<AssessmentCompleteSkill> skills;
  final List<AssessmentFinalResult> finalResults;

  AssessmentCompleteData({
    required this.assessmentSessionId,
    required this.status,
    required this.completedAt,
    required this.finalResultsAvailable,
    required this.hasSkillsNeedingReview,
    required this.skills,
    required this.finalResults,
  });

  static bool _asBool(dynamic value) {
    final text = value?.toString().toLowerCase().trim();
    return value == true || text == '1' || text == 'true';
  }

  factory AssessmentCompleteData.fromJson(Map<String, dynamic> json) {
    final oldFinalResults = (json['FinalResultsJson'] as List? ?? [])
        .map((e) => AssessmentFinalResult.fromJson(e))
        .toList();

    final newSkills = (json['skills'] as List? ?? [])
        .map((e) => AssessmentCompleteSkill.fromJson(e))
        .toList();

    final rawStatus = json['status'] ?? json['Status'];
    final status = rawStatus?.toString() ?? '';
    final completedAt = json['completed_at']?.toString() ??
        json['CompletedAt']?.toString();

    return AssessmentCompleteData(
      assessmentSessionId: int.tryParse(
            (json['session_id'] ?? json['AssessmentSessionID'] ?? 0).toString(),
          ) ??
          0,
      status: status,
      completedAt: completedAt,
      finalResultsAvailable: _asBool(json['final_results_available']) ||
          oldFinalResults.isNotEmpty ||
          status.toLowerCase() == 'completed',
      hasSkillsNeedingReview: _asBool(json['has_skills_needing_review']),
      skills: newSkills,
      finalResults: oldFinalResults,
    );
  }

  bool get isReadyToShowFinalResults =>
      finalResultsAvailable || status.toLowerCase() == 'completed';
}

class AssessmentCompleteSkill {
  final int skillSessionId;
  final int skillId;
  final String status;
  final double? finalLevel;
  final int questionCount;

  AssessmentCompleteSkill({
    required this.skillSessionId,
    required this.skillId,
    required this.status,
    required this.finalLevel,
    required this.questionCount,
  });

  factory AssessmentCompleteSkill.fromJson(Map<String, dynamic> json) {
    return AssessmentCompleteSkill(
      skillSessionId: int.tryParse(json['skill_session_id'].toString()) ?? 0,
      skillId: int.tryParse(json['skill_id'].toString()) ?? 0,
      status: json['status']?.toString() ?? '',
      finalLevel: json['final_level'] == null
          ? null
          : double.tryParse(json['final_level'].toString()),
      questionCount: int.tryParse(json['question_count'].toString()) ?? 0,
    );
  }

  bool get needsMoreQuestions {
    final normalized = status.toLowerCase().trim();
    return normalized == 'in_progress' || normalized == 'needs_review';
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

class AssessmentSummaryResponse {
  final AssessmentSummaryData data;

  AssessmentSummaryResponse({required this.data});

  factory AssessmentSummaryResponse.fromJson(Map<String, dynamic> json) {
    return AssessmentSummaryResponse(
      data: AssessmentSummaryData.fromJson(json['data'] ?? {}),
    );
  }
}

class AssessmentSummaryData {
  final int sessionId;
  final String status;
  final String careerPath;
  final String? completedAt;
  final List<AssessmentSummarySkill> skills;

  AssessmentSummaryData({
    required this.sessionId,
    required this.status,
    required this.careerPath,
    required this.completedAt,
    required this.skills,
  });

  factory AssessmentSummaryData.fromJson(Map<String, dynamic> json) {
    return AssessmentSummaryData(
      sessionId: int.tryParse(json['session_id'].toString()) ?? 0,
      status: json['status']?.toString() ?? '',
      careerPath: json['career_path']?.toString() ?? '',
      completedAt: json['completed_at']?.toString(),
      skills: (json['skills'] as List? ?? [])
          .map((item) => AssessmentSummarySkill.fromJson(item))
          .toList(),
    );
  }
}

class AssessmentSummarySkill {
  final int skillId;
  final String skillName;
  final double initialLevel;
  final double currentLevel;
  final double? finalLevel;
  final double? confidenceScore;
  final int questionCount;
  final String status;
  final List<AssessmentSummaryAttempt> attempts;

  AssessmentSummarySkill({
    required this.skillId,
    required this.skillName,
    required this.initialLevel,
    required this.currentLevel,
    required this.finalLevel,
    required this.confidenceScore,
    required this.questionCount,
    required this.status,
    required this.attempts,
  });

  factory AssessmentSummarySkill.fromJson(Map<String, dynamic> json) {
    final finalLevelValue = _firstJsonValue(json, [
      'final_level',
      'FinalLevel',
      'finalLevel',
    ]);

    return AssessmentSummarySkill(
      skillId: _jsonInt(json, ['skill_id', 'SkillID', 'skillId', 'id']),
      skillName: _jsonString(json, [
        'skill_name',
        'SkillName',
        'skillName',
        'name',
        'Name',
      ]),
      initialLevel: _jsonDouble(json, [
        'initial_level',
        'InitialLevel',
        'initialLevel',
      ]),
      currentLevel: _jsonDouble(json, [
        'current_level',
        'CurrentLevel',
        'currentLevel',
        'current_estimated_level',
        'CurrentEstimatedLevel',
        'currentEstimatedLevel',
        'actual_level',
        'ActualLevel',
        'actualLevel',
        'level',
        'Level',
      ]),
      finalLevel: finalLevelValue == null
          ? null
          : double.tryParse(finalLevelValue.toString()),
      confidenceScore: _firstJsonValue(json, [
        'confidence_score',
        'ConfidenceScore',
        'confidenceScore',
      ]) == null
          ? null
          : double.tryParse(_firstJsonValue(json, [
              'confidence_score',
              'ConfidenceScore',
              'confidenceScore',
            ]).toString()),
      questionCount: _jsonInt(json, [
        'question_count',
        'QuestionCount',
        'questionCount',
      ]),
      status: _jsonString(json, ['status', 'Status']),
      attempts: _jsonList<AssessmentSummaryAttempt>(json, ['attempts', 'Attempts'], (item) {
        return AssessmentSummaryAttempt.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }),
    );
  }
}

class AssessmentSummaryAttempt {
  final String questionText;
  final double questionLevel;
  final double normalizedScore;
  final String feedback;

  AssessmentSummaryAttempt({
    required this.questionText,
    required this.questionLevel,
    required this.normalizedScore,
    required this.feedback,
  });

  factory AssessmentSummaryAttempt.fromJson(Map<String, dynamic> json) {
    return AssessmentSummaryAttempt(
      questionText: json['question_text']?.toString() ?? '',
      questionLevel: double.tryParse(json['question_level'].toString()) ?? 0,
      normalizedScore:
          double.tryParse(json['normalized_score'].toString()) ?? 0,
      feedback: json['feedback']?.toString() ?? '',
    );
  }
}

class AssessmentSkillGapsResponse {
  final List<AssessmentSkillGap> gaps;

  AssessmentSkillGapsResponse({required this.gaps});

  factory AssessmentSkillGapsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return AssessmentSkillGapsResponse(
      gaps: (data['gaps'] as List? ?? [])
          .map((item) => AssessmentSkillGap.fromJson(item))
          .toList(),
    );
  }
}

class AssessmentSkillGap {
  final int skillId;
  final String skillName;
  final double requiredLevel;
  final double actualLevel;
  final double gap;
  final String priority;
  final String status;
  final String reliability;

  AssessmentSkillGap({
    required this.skillId,
    required this.skillName,
    required this.requiredLevel,
    required this.actualLevel,
    required this.gap,
    required this.priority,
    required this.status,
    required this.reliability,
  });

  factory AssessmentSkillGap.fromJson(Map<String, dynamic> json) {
    return AssessmentSkillGap(
      skillId: _jsonInt(json, ['skill_id', 'SkillID', 'skillId', 'id']),
      skillName: _jsonString(json, [
        'skill_name',
        'SkillName',
        'skillName',
        'name',
        'Name',
      ]),
      requiredLevel: _jsonDouble(json, [
        'required_level',
        'RequiredLevel',
        'requiredLevel',
        'target_level',
        'TargetLevel',
        'targetLevel',
      ]),
      actualLevel: _jsonDouble(json, [
        'actual_level',
        'ActualLevel',
        'actualLevel',
        'current_level',
        'CurrentLevel',
        'currentLevel',
      ]),
      gap: _jsonDouble(json, ['gap', 'Gap']),
      priority: _jsonString(json, ['priority', 'Priority']),
      status: _jsonString(json, ['status', 'Status']),
      reliability: _jsonString(json, [
        'assessment_reliability',
        'AssessmentReliability',
        'reliability',
      ]),
    );
  }
}

class AssessmentLearningPathResponse {
  final List<AssessmentLearningPathItem> data;

  AssessmentLearningPathResponse({required this.data});

  factory AssessmentLearningPathResponse.fromJson(Map<String, dynamic> json) {
    return AssessmentLearningPathResponse(
      data: (json['data'] as List? ?? [])
          .map((item) => AssessmentLearningPathItem.fromJson(item))
          .toList(),
    );
  }
}

class AssessmentLearningPathItem {
  final int skillId;
  final String skillName;
  final double currentLevel;
  final double targetLevel;
  final String priority;
  final List<AssessmentLearningResource> resources;

  AssessmentLearningPathItem({
    required this.skillId,
    required this.skillName,
    required this.currentLevel,
    required this.targetLevel,
    required this.priority,
    required this.resources,
  });

  factory AssessmentLearningPathItem.fromJson(Map<String, dynamic> json) {
    return AssessmentLearningPathItem(
      skillId: _jsonInt(json, ['skill_id', 'SkillID', 'skillId', 'id']),
      skillName: _jsonString(json, [
        'skill_name',
        'SkillName',
        'skillName',
        'name',
        'Name',
      ]),
      currentLevel: _jsonDouble(json, [
        'current_level',
        'CurrentLevel',
        'currentLevel',
        'current_estimated_level',
        'CurrentEstimatedLevel',
        'currentEstimatedLevel',
        'actual_level',
        'ActualLevel',
        'actualLevel',
        'final_level',
        'FinalLevel',
        'finalLevel',
        'level',
        'Level',
      ]),
      targetLevel: _jsonDouble(json, [
        'target_level',
        'TargetLevel',
        'targetLevel',
        'required_level',
        'RequiredLevel',
        'requiredLevel',
        'market_level',
        'MarketLevel',
        'marketLevel',
      ]),
      priority: _jsonString(json, ['priority', 'Priority', 'status', 'Status']),
      resources: _jsonList<AssessmentLearningResource>(json, [
        'resources',
        'Resources',
        'learning_resources',
        'LearningResources',
      ], (item) {
        return AssessmentLearningResource.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skill_id': skillId,
      'skill_name': skillName,
      'current_level': currentLevel,
      'target_level': targetLevel,
      'priority': priority,
      'resources': resources.map((item) => item.toJson()).toList(),
    };
  }

  AssessmentLearningPathItem copyWith({
    int? skillId,
    String? skillName,
    double? currentLevel,
    double? targetLevel,
    String? priority,
    List<AssessmentLearningResource>? resources,
  }) {
    return AssessmentLearningPathItem(
      skillId: skillId ?? this.skillId,
      skillName: skillName ?? this.skillName,
      currentLevel: currentLevel ?? this.currentLevel,
      targetLevel: targetLevel ?? this.targetLevel,
      priority: priority ?? this.priority,
      resources: resources ?? this.resources,
    );
  }

  bool get isMarketReady => targetLevel > 0 && currentLevel >= targetLevel;
}

class AssessmentLearningResource {
  final String title;
  final String url;
  final String type;
  final double level;
  final String estimatedHours;
  final String provider;

  AssessmentLearningResource({
    required this.title,
    required this.url,
    required this.type,
    required this.level,
    required this.estimatedHours,
    required this.provider,
  });

  factory AssessmentLearningResource.fromJson(Map<String, dynamic> json) {
    return AssessmentLearningResource(
      title: json['title']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      level: double.tryParse(json['level'].toString()) ?? 0,
      estimatedHours: json['estimated_hours']?.toString() ?? '',
      provider: json['provider']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'type': type,
      'level': level,
      'estimated_hours': estimatedHours,
      'provider': provider,
    };
  }

}

class AssessmentAiLearningPlanResponse {
  final bool success;
  final String message;
  final AssessmentAiLearningPlan data;

  AssessmentAiLearningPlanResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AssessmentAiLearningPlanResponse.fromJson(Map<String, dynamic> json) {
    return AssessmentAiLearningPlanResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: AssessmentAiLearningPlan.fromJson(json['data'] ?? {}),
    );
  }
}

class AssessmentAiLearningPlan {
  final int id;
  final int assessmentSessionId;
  final String status;
  final int weeks;
  final int hoursPerWeek;
  final String summaryText;
  final String generatedAt;
  final AssessmentAiPlanJson plan;

  AssessmentAiLearningPlan({
    required this.id,
    required this.assessmentSessionId,
    required this.status,
    required this.weeks,
    required this.hoursPerWeek,
    required this.summaryText,
    required this.generatedAt,
    required this.plan,
  });

  factory AssessmentAiLearningPlan.fromJson(Map<String, dynamic> json) {
    return AssessmentAiLearningPlan(
      id:
          int.tryParse(
            (json['AILearningPlanID'] ?? json['id'] ?? 0).toString(),
          ) ??
          0,
      assessmentSessionId: int.tryParse(
            (json['AssessmentSessionID'] ?? json['assessment_session_id'] ?? 0).toString(),
          ) ??
          0,
      status: json['Status']?.toString() ?? '',
      weeks: int.tryParse(json['Weeks'].toString()) ?? 0,
      hoursPerWeek: int.tryParse(json['HoursPerWeek'].toString()) ?? 0,
      summaryText: json['SummaryText']?.toString() ?? '',
      generatedAt: json['GeneratedAt']?.toString() ?? '',
      plan: AssessmentAiPlanJson.fromJson(json['PlanJson'] ?? {}),
    );
  }
}

class AssessmentAiPlanJson {
  final String careerPath;
  final String summaryAr;
  final String finalOutcomeAr;
  final List<AssessmentAiPlanWeek> weeks;

  AssessmentAiPlanJson({
    required this.careerPath,
    required this.summaryAr,
    required this.finalOutcomeAr,
    required this.weeks,
  });

  factory AssessmentAiPlanJson.fromJson(Map<String, dynamic> json) {
    return AssessmentAiPlanJson(
      careerPath: json['career_path']?.toString() ?? '',
      summaryAr: json['summary_ar']?.toString() ?? '',
      finalOutcomeAr: json['final_outcome_ar']?.toString() ?? '',
      weeks: (json['weeks'] as List? ?? [])
          .map((item) => AssessmentAiPlanWeek.fromJson(item))
          .toList(),
    );
  }
}

class AssessmentAiPlanWeek {
  final int weekNumber;
  final List<String> focusSkills;
  final List<String> goals;
  final List<AssessmentAiPlanTask> tasks;
  final List<AssessmentAiPlanResource> resources;
  final String expectedOutcome;

  AssessmentAiPlanWeek({
    required this.weekNumber,
    required this.focusSkills,
    required this.goals,
    required this.tasks,
    required this.resources,
    required this.expectedOutcome,
  });

  factory AssessmentAiPlanWeek.fromJson(Map<String, dynamic> json) {
    return AssessmentAiPlanWeek(
      weekNumber: int.tryParse(json['week_number'].toString()) ?? 0,
      focusSkills: (json['focus_skills'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      goals: (json['goals'] as List? ?? []).map((e) => e.toString()).toList(),
      tasks: (json['tasks'] as List? ?? [])
          .map((item) => AssessmentAiPlanTask.fromJson(item))
          .toList(),
      resources: (json['resources'] as List? ?? [])
          .map((item) => AssessmentAiPlanResource.fromJson(item))
          .toList(),
      expectedOutcome: json['expected_outcome']?.toString() ?? '',
    );
  }
}

class AssessmentAiPlanTask {
  final String title;
  final double estimatedHours;
  final String skill;

  AssessmentAiPlanTask({
    required this.title,
    required this.estimatedHours,
    required this.skill,
  });

  factory AssessmentAiPlanTask.fromJson(Map<String, dynamic> json) {
    return AssessmentAiPlanTask(
      title: json['title']?.toString() ?? '',
      estimatedHours: double.tryParse(json['estimated_hours'].toString()) ?? 0,
      skill: json['skill']?.toString() ?? '',
    );
  }
}

class AssessmentAiPlanResource {
  final String title;
  final String url;
  final String type;
  final String skill;

  AssessmentAiPlanResource({
    required this.title,
    required this.url,
    required this.type,
    required this.skill,
  });

  factory AssessmentAiPlanResource.fromJson(Map<String, dynamic> json) {
    return AssessmentAiPlanResource(
      title: json['title']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      skill: json['skill']?.toString() ?? '',
    );
  }
}
