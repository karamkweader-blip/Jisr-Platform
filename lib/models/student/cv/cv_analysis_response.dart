class CvAnalysisResponse {
  final bool success;
  final String message;
  final int analysisId;
  final int cvId;
  final List<CvSkillModel> skills;

  CvAnalysisResponse({
    required this.success,
    required this.message,
    required this.analysisId,
    required this.cvId,
    required this.skills,
  });

  factory CvAnalysisResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return CvAnalysisResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      analysisId: int.tryParse(data['analysis_id'].toString()) ?? 0,
      cvId: int.tryParse(data['cv_id'].toString()) ?? 0,
      skills: (data['skills'] as List? ?? [])
          .map((item) => CvSkillModel.fromJson(item))
          .toList(),
    );
  }
}

class CvSkillModel {
  final int skillId;
  final String skillName;
  final String evidence;
  final double initialLevel;
  final double confidence;

  CvSkillModel({
    required this.skillId,
    required this.skillName,
    required this.evidence,
    required this.initialLevel,
    required this.confidence,
  });

  factory CvSkillModel.fromJson(Map<String, dynamic> json) {
    return CvSkillModel(
      skillId: int.tryParse(json['skill_id'].toString()) ?? 0,
      skillName: json['skill_name']?.toString() ?? '',
      evidence: json['evidence']?.toString() ?? '',
      initialLevel: double.tryParse(json['initial_level'].toString()) ?? 0.0,
      confidence: double.tryParse(json['confidence'].toString()) ?? 0.0,
    );
  }
}
