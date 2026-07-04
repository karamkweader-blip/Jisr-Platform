import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AssessmentSessionCacheData {
  final int assessmentSessionId;
  final int careerPathId;
  final int cvId;
  final List<int> skillIds;
  final Map<int, String> skillNames;
  final int currentSkillIndex;
  final int exitAttempts;

  const AssessmentSessionCacheData({
    required this.assessmentSessionId,
    required this.careerPathId,
    required this.cvId,
    required this.skillIds,
    required this.skillNames,
    required this.currentSkillIndex,
    required this.exitAttempts,
  });

  bool matches({
    required int careerPathId,
    required int cvId,
    required List<int> skillIds,
  }) {
    if (this.careerPathId != careerPathId || this.cvId != cvId) return false;
    if (this.skillIds.length != skillIds.length) return false;

    for (int i = 0; i < skillIds.length; i++) {
      if (this.skillIds[i] != skillIds[i]) return false;
    }

    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'assessment_session_id': assessmentSessionId,
      'career_path_id': careerPathId,
      'cv_id': cvId,
      'skill_ids': skillIds,
      'skill_names': skillNames.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'current_skill_index': currentSkillIndex,
      'exit_attempts': exitAttempts,
    };
  }

  factory AssessmentSessionCacheData.fromJson(Map<String, dynamic> json) {
    final names = json['skill_names'];

    return AssessmentSessionCacheData(
      assessmentSessionId:
          int.tryParse(json['assessment_session_id']?.toString() ?? '') ?? 0,
      careerPathId: int.tryParse(json['career_path_id']?.toString() ?? '') ?? 0,
      cvId: int.tryParse(json['cv_id']?.toString() ?? '') ?? 0,
      skillIds: List<int>.from(
        (json['skill_ids'] as List? ?? []).map(
          (item) => int.tryParse(item.toString()) ?? 0,
        ),
      ),
      skillNames: names is Map
          ? names.map(
              (key, value) =>
                  MapEntry(int.tryParse(key.toString()) ?? 0, value.toString()),
            )
          : <int, String>{},
      currentSkillIndex:
          int.tryParse(json['current_skill_index']?.toString() ?? '') ?? 0,
      exitAttempts: int.tryParse(json['exit_attempts']?.toString() ?? '') ?? 0,
    );
  }
}

class AssessmentSessionCache {
  static const String _key = 'active_assessment_session';

  Future<void> save(AssessmentSessionCacheData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data.toJson()));
  }

  Future<AssessmentSessionCacheData?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      final data = AssessmentSessionCacheData.fromJson(decoded);

      if (data.assessmentSessionId == 0 || data.skillIds.isEmpty) {
        return null;
      }

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
