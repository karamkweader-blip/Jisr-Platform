import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:jisr_platform/models/student/assessment/assessment_models.dart';

class AssessmentLearningPlanCacheData {
  final int assessmentSessionId;
  final int careerPathId;
  final int cvId;
  final String careerPath;
  final String savedAt;
  final List<AssessmentLearningPathItem> roadmap;

  const AssessmentLearningPlanCacheData({
    required this.assessmentSessionId,
    required this.careerPathId,
    required this.cvId,
    required this.careerPath,
    required this.savedAt,
    this.roadmap = const [],
  });

  AssessmentLearningPlanCacheData copyWith({
    int? assessmentSessionId,
    int? careerPathId,
    int? cvId,
    String? careerPath,
    String? savedAt,
    List<AssessmentLearningPathItem>? roadmap,
  }) {
    return AssessmentLearningPlanCacheData(
      assessmentSessionId: assessmentSessionId ?? this.assessmentSessionId,
      careerPathId: careerPathId ?? this.careerPathId,
      cvId: cvId ?? this.cvId,
      careerPath: careerPath ?? this.careerPath,
      savedAt: savedAt ?? this.savedAt,
      roadmap: roadmap ?? this.roadmap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assessment_session_id': assessmentSessionId,
      'career_path_id': careerPathId,
      'cv_id': cvId,
      'career_path': careerPath,
      'saved_at': savedAt,
      'roadmap': roadmap.map((item) => item.toJson()).toList(),
    };
  }

  factory AssessmentLearningPlanCacheData.fromJson(Map<String, dynamic> json) {
    return AssessmentLearningPlanCacheData(
      assessmentSessionId:
          int.tryParse(json['assessment_session_id']?.toString() ?? '') ?? 0,
      careerPathId:
          int.tryParse(json['career_path_id']?.toString() ?? '') ?? 0,
      cvId: int.tryParse(json['cv_id']?.toString() ?? '') ?? 0,
      careerPath: json['career_path']?.toString() ?? '',
      savedAt: json['saved_at']?.toString() ?? '',
      roadmap: (json['roadmap'] as List? ?? [])
          .whereType<Map>()
          .map((item) => AssessmentLearningPathItem.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .where((item) => item.skillId > 0)
          .toList(),
    );
  }
}

class AssessmentRetestSeedData {
  final int careerPathId;
  final int cvId;
  final String savedAt;

  const AssessmentRetestSeedData({
    required this.careerPathId,
    required this.cvId,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'career_path_id': careerPathId,
      'cv_id': cvId,
      'saved_at': savedAt,
    };
  }

  factory AssessmentRetestSeedData.fromJson(Map<String, dynamic> json) {
    return AssessmentRetestSeedData(
      careerPathId:
          int.tryParse(json['career_path_id']?.toString() ?? '') ?? 0,
      cvId: int.tryParse(json['cv_id']?.toString() ?? '') ?? 0,
      savedAt: json['saved_at']?.toString() ?? '',
    );
  }
}

class AssessmentLearningPlanCache {
  static const String _key = 'latest_assessment_learning_plan';
  static const String _seedKey = 'latest_assessment_retest_seed';

  Future<void> save({
    required int assessmentSessionId,
    required String careerPath,
    int? careerPathId,
    int? cvId,
    List<AssessmentLearningPathItem>? roadmap,
  }) async {
    if (assessmentSessionId == 0) return;

    final prefs = await SharedPreferences.getInstance();
    final oldData = await read();

    final data = AssessmentLearningPlanCacheData(
      assessmentSessionId: assessmentSessionId,
      careerPathId: careerPathId ?? oldData?.careerPathId ?? 0,
      cvId: cvId ?? oldData?.cvId ?? 0,
      careerPath: careerPath.isNotEmpty ? careerPath : (oldData?.careerPath ?? ''),
      savedAt: DateTime.now().toIso8601String(),
      roadmap: roadmap ?? oldData?.roadmap ?? const [],
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

  Future<void> mergeRoadmap({
    required int assessmentSessionId,
    required String careerPath,
    required List<AssessmentLearningPathItem> updatedItems,
    int? careerPathId,
    int? cvId,
  }) async {
    final oldData = await read();
    final merged = _mergeRoadmaps(oldData?.roadmap ?? const [], updatedItems);

    await save(
      assessmentSessionId: assessmentSessionId,
      careerPath: careerPath,
      careerPathId: careerPathId,
      cvId: cvId,
      roadmap: merged,
    );
  }

  List<AssessmentLearningPathItem> _mergeRoadmaps(
    List<AssessmentLearningPathItem> oldItems,
    List<AssessmentLearningPathItem> updatedItems,
  ) {
    final byId = <int, AssessmentLearningPathItem>{};
    final order = <int>[];

    void put(AssessmentLearningPathItem item) {
      if (item.skillId <= 0) return;
      if (!byId.containsKey(item.skillId)) order.add(item.skillId);
      byId[item.skillId] = item;
    }

    for (final item in oldItems) {
      put(item);
    }

    for (final incoming in updatedItems) {
      if (incoming.skillId <= 0) continue;
      final old = byId[incoming.skillId];

      if (old == null) {
        put(_normalizeItem(incoming));
        continue;
      }

      final current = incoming.currentLevel > 0
          ? incoming.currentLevel
          : old.currentLevel;

      final incomingHasRealTarget = incoming.targetLevel > 0 &&
          (incoming.targetLevel - incoming.currentLevel).abs() > 0.0001;

      final target = incomingHasRealTarget
          ? incoming.targetLevel
          : (old.targetLevel > 0 ? old.targetLevel : incoming.targetLevel);

      final ready = target > 0 && current >= target;
      final resources = ready
          ? <AssessmentLearningResource>[]
          : (incoming.resources.isNotEmpty ? incoming.resources : old.resources);

      put(AssessmentLearningPathItem(
        skillId: incoming.skillId,
        skillName: incoming.skillName.isNotEmpty ? incoming.skillName : old.skillName,
        currentLevel: current,
        targetLevel: target > 0 ? target : current,
        priority: ready
            ? 'market_ready'
            : (current <= 0
                ? 'unknown'
                : (incoming.priority.isNotEmpty ? incoming.priority : old.priority)),
        resources: resources,
      ));
    }

    return order
        .where((id) => byId.containsKey(id))
        .map((id) => _normalizeItem(byId[id]!))
        .toList();
  }

  AssessmentLearningPathItem _normalizeItem(AssessmentLearningPathItem item) {
    final current = item.currentLevel < 0 ? 0.0 : item.currentLevel;
    final target = item.targetLevel > 0 ? item.targetLevel : current;
    final ready = target > 0 && current >= target;
    final normalizedPriority = ready
        ? 'market_ready'
        : (current <= 0
            ? 'unknown'
            : (item.priority.isEmpty ? 'medium' : item.priority));

    return item.copyWith(
      currentLevel: current,
      targetLevel: target,
      priority: normalizedPriority,
      resources: ready ? <AssessmentLearningResource>[] : item.resources,
    );
  }

  Future<void> saveRetestSeed({
    required int careerPathId,
    required int cvId,
  }) async {
    if (cvId == 0) return;

    final prefs = await SharedPreferences.getInstance();
    final data = AssessmentRetestSeedData(
      careerPathId: careerPathId == 0 ? 1 : careerPathId,
      cvId: cvId,
      savedAt: DateTime.now().toIso8601String(),
    );

    await prefs.setString(_seedKey, jsonEncode(data.toJson()));
  }

  Future<AssessmentRetestSeedData?> readRetestSeed() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_seedKey);

    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      final data = AssessmentRetestSeedData.fromJson(decoded);
      if (data.cvId == 0) return null;
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
