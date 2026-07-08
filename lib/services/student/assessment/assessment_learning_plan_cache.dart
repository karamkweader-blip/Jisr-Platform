import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AssessmentLearningPlanCacheData {
  final int assessmentSessionId;
  final String careerPath;
  final String savedAt;

  const AssessmentLearningPlanCacheData({
    required this.assessmentSessionId,
    required this.careerPath,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'assessment_session_id': assessmentSessionId,
      'career_path': careerPath,
      'saved_at': savedAt,
    };
  }

  factory AssessmentLearningPlanCacheData.fromJson(Map<String, dynamic> json) {
    return AssessmentLearningPlanCacheData(
      assessmentSessionId:
          int.tryParse(json['assessment_session_id']?.toString() ?? '') ?? 0,
      careerPath: json['career_path']?.toString() ?? '',
      savedAt: json['saved_at']?.toString() ?? '',
    );
  }
}

class AssessmentLearningPlanCache {
  static const String _key = 'latest_assessment_learning_plan';

  Future<void> save({
    required int assessmentSessionId,
    required String careerPath,
  }) async {
    if (assessmentSessionId == 0) return;

    final prefs = await SharedPreferences.getInstance();

    final data = AssessmentLearningPlanCacheData(
      assessmentSessionId: assessmentSessionId,
      careerPath: careerPath,
      savedAt: DateTime.now().toIso8601String(),
    );

    await prefs.setString(_key, jsonEncode(data.toJson()));
  }

  Future<AssessmentLearningPlanCacheData?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      final data = AssessmentLearningPlanCacheData.fromJson(decoded);
      if (data.assessmentSessionId == 0) return null;

      return data;
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
