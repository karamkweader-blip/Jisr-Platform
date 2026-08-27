class StudentCvListResponse {
  final bool success;
  final String message;
  final List<StudentCvItem> cvs;
  final int total;

  const StudentCvListResponse({
    required this.success,
    required this.message,
    required this.cvs,
    required this.total,
  });

  factory StudentCvListResponse.fromJson(Map<String, dynamic> json) {
    final data = CvHistoryJson.map(json['data']);
    final cvs = CvHistoryJson.mapList(data['cvs'])
        .map(StudentCvItem.fromJson)
        .toList(growable: false);

    return StudentCvListResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      cvs: cvs,
      total: CvHistoryJson.intValue(data['total']) ?? cvs.length,
    );
  }
}

class StudentCvItem {
  final int cvId;
  final String? fileUrl;
  final bool isPrimary;
  final DateTime? uploadedAt;
  final bool hasAnalysis;
  final StudentCvLatestAnalysis? latestAnalysis;

  const StudentCvItem({
    required this.cvId,
    required this.fileUrl,
    required this.isPrimary,
    required this.uploadedAt,
    required this.hasAnalysis,
    required this.latestAnalysis,
  });

  factory StudentCvItem.fromJson(Map<String, dynamic> json) {
    final latest = CvHistoryJson.nullableMap(json['latest_analysis']);

    return StudentCvItem(
      cvId: CvHistoryJson.intValue(json['cv_id']) ?? 0,
      fileUrl: CvHistoryJson.stringValue(json['file_url']),
      isPrimary: CvHistoryJson.boolValue(json['is_primary']),
      uploadedAt: CvHistoryJson.dateValue(json['uploaded_at']),
      hasAnalysis: CvHistoryJson.boolValue(json['has_analysis']),
      latestAnalysis: latest == null
          ? null
          : StudentCvLatestAnalysis.fromJson(latest),
    );
  }

  String get displayName {
    final url = fileUrl;
    if (url != null) {
      final uri = Uri.tryParse(url);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        final name = Uri.decodeComponent(uri.pathSegments.last).trim();
        if (name.isNotEmpty) return name;
      }
    }
    return 'السيرة الذاتية رقم $cvId';
  }
}

class StudentCvLatestAnalysis {
  final int analysisId;
  final double? overallScore;
  final String? modelVersion;
  final int skillsCount;
  final DateTime? analyzedAt;

  const StudentCvLatestAnalysis({
    required this.analysisId,
    required this.overallScore,
    required this.modelVersion,
    required this.skillsCount,
    required this.analyzedAt,
  });

  factory StudentCvLatestAnalysis.fromJson(Map<String, dynamic> json) {
    return StudentCvLatestAnalysis(
      analysisId: CvHistoryJson.intValue(json['analysis_id']) ?? 0,
      overallScore: CvHistoryJson.doubleValue(json['overall_score']),
      modelVersion: CvHistoryJson.stringValue(json['model_version']),
      skillsCount: CvHistoryJson.intValue(json['skills_count']) ?? 0,
      analyzedAt: CvHistoryJson.dateValue(json['analyzed_at']),
    );
  }
}

class StudentCvAnalysisDetailsResponse {
  final bool success;
  final String message;
  final StudentCvItem cv;
  final StudentCvAnalysis analysis;

  const StudentCvAnalysisDetailsResponse({
    required this.success,
    required this.message,
    required this.cv,
    required this.analysis,
  });

  factory StudentCvAnalysisDetailsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = CvHistoryJson.map(json['data']);

    return StudentCvAnalysisDetailsResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      cv: StudentCvItem.fromJson(CvHistoryJson.map(data['cv'])),
      analysis: StudentCvAnalysis.fromJson(
        CvHistoryJson.map(data['analysis']),
      ),
    );
  }
}

class StudentCvAnalysis {
  final int analysisId;
  final int cvId;
  final double? overallScore;
  final String? modelVersion;
  final DateTime? analyzedAt;
  final List<String> missingCriteria;
  final List<StudentCvAnalysisSkill> skills;

  const StudentCvAnalysis({
    required this.analysisId,
    required this.cvId,
    required this.overallScore,
    required this.modelVersion,
    required this.analyzedAt,
    required this.missingCriteria,
    required this.skills,
  });

  factory StudentCvAnalysis.fromJson(Map<String, dynamic> json) {
    final missingCriteria = json['missing_criteria'] is List
        ? (json['missing_criteria'] as List)
            .map((item) => item?.toString().trim() ?? '')
            .where((item) => item.isNotEmpty)
            .toList(growable: false)
        : const <String>[];

    return StudentCvAnalysis(
      analysisId: CvHistoryJson.intValue(json['analysis_id']) ?? 0,
      cvId: CvHistoryJson.intValue(json['cv_id']) ?? 0,
      overallScore: CvHistoryJson.doubleValue(json['overall_score']),
      modelVersion: CvHistoryJson.stringValue(json['model_version']),
      analyzedAt: CvHistoryJson.dateValue(json['analyzed_at']),
      missingCriteria: missingCriteria,
      skills: CvHistoryJson.mapList(json['skills'])
          .map(StudentCvAnalysisSkill.fromJson)
          .toList(growable: false),
    );
  }
}

class StudentCvAnalysisSkill {
  final int? extractedSkillId;
  final int? skillId;
  final String? skillName;
  final String? rawSkillName;
  final String? evidence;
  final double? initialLevel;
  final double? confidenceScore;
  final String? extractionSource;

  const StudentCvAnalysisSkill({
    required this.extractedSkillId,
    required this.skillId,
    required this.skillName,
    required this.rawSkillName,
    required this.evidence,
    required this.initialLevel,
    required this.confidenceScore,
    required this.extractionSource,
  });

  factory StudentCvAnalysisSkill.fromJson(Map<String, dynamic> json) {
    return StudentCvAnalysisSkill(
      extractedSkillId: CvHistoryJson.intValue(json['extracted_skill_id']),
      skillId: CvHistoryJson.intValue(json['skill_id']),
      skillName: CvHistoryJson.stringValue(json['skill_name']),
      rawSkillName: CvHistoryJson.stringValue(json['raw_skill_name']),
      evidence: CvHistoryJson.stringValue(json['evidence']),
      initialLevel: CvHistoryJson.doubleValue(json['initial_level']),
      confidenceScore: CvHistoryJson.doubleValue(json['confidence_score']),
      extractionSource: CvHistoryJson.stringValue(json['extraction_source']),
    );
  }

  String get displayName => skillName ?? rawSkillName ?? 'مهارة غير مسماة';
}

class CvHistoryJson {
  static Map<String, dynamic> map(dynamic value) {
    return value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
  }

  static Map<String, dynamic>? nullableMap(dynamic value) {
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  static List<Map<String, dynamic>> mapList(dynamic value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  static int? intValue(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static double? doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static bool boolValue(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return value?.toString().toLowerCase() == 'true';
  }

  static String? stringValue(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }

  static DateTime? dateValue(dynamic value) {
    final text = stringValue(value);
    return text == null ? null : DateTime.tryParse(text);
  }
}
