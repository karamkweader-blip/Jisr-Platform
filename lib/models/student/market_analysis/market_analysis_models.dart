class MarketCareerPathResponse {
  final bool success;
  final String message;
  final int total;
  final List<MarketCareerPath> careerPaths;

  const MarketCareerPathResponse({
    required this.success,
    required this.message,
    required this.total,
    required this.careerPaths,
  });

  factory MarketCareerPathResponse.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    final pathsJson = _asList(data['career_paths']);

    return MarketCareerPathResponse(
      success: _asBool(json['success'] ?? json['status']),
      message: json['message']?.toString() ?? '',
      total: _asInt(data['total'], fallback: pathsJson.length),
      careerPaths: pathsJson
          .whereType<Map>()
          .map((item) => MarketCareerPath.fromJson(_asMap(item)))
          .toList(),
    );
  }
}

class MarketCareerPath {
  final int id;
  final String name;
  final String description;
  final int totalJobPostings;
  final String latestSnapshotDate;
  final bool hasMarketData;

  const MarketCareerPath({
    required this.id,
    required this.name,
    required this.description,
    required this.totalJobPostings,
    required this.latestSnapshotDate,
    required this.hasMarketData,
  });

  factory MarketCareerPath.fromJson(Map<String, dynamic> json) {
    return MarketCareerPath(
      id: _asInt(json['id'] ?? json['CareerPathID'] ?? json['career_path_id']),
      name: json['name']?.toString() ?? json['Name']?.toString() ?? 'مسار مهني',
      description: json['description']?.toString() ?? json['Description']?.toString() ?? '',
      totalJobPostings: _asInt(
        json['total_job_postings'] ?? json['totalJobPostings'] ?? json['TotalJobPostings'],
      ),
      latestSnapshotDate: (json['latest_snapshot_date'] ?? json['latestSnapshotDate'] ?? '')
          .toString(),
      hasMarketData: _asBool(json['has_market_data'] ?? json['hasMarketData']),
    );
  }
}

class MarketSkillDemandResponse {
  final bool success;
  final String message;
  final MarketCareerPathLite careerPath;
  final int totalJobPostings;
  final List<MarketDemandSkill> skills;
  final Map<String, List<MarketDemandSkill>> skillMap;

  const MarketSkillDemandResponse({
    required this.success,
    required this.message,
    required this.careerPath,
    required this.totalJobPostings,
    required this.skills,
    required this.skillMap,
  });

  factory MarketSkillDemandResponse.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    final skills = _asList(data['skills'])
        .whereType<Map>()
        .map((item) => MarketDemandSkill.fromJson(_asMap(item)))
        .toList();

    final rawMap = _asMap(data['skill_map']);
    final parsedMap = <String, List<MarketDemandSkill>>{};
    rawMap.forEach((key, value) {
      parsedMap[key.toString()] = _asList(value)
          .whereType<Map>()
          .map((item) => MarketDemandSkill.fromJson(_asMap(item)))
          .toList();
    });

    return MarketSkillDemandResponse(
      success: _asBool(json['success'] ?? json['status']),
      message: json['message']?.toString() ?? '',
      careerPath: MarketCareerPathLite.fromJson(_asMap(data['career_path'])),
      totalJobPostings: _asInt(data['total_job_postings'] ?? data['totalJobPostings']),
      skills: skills,
      skillMap: parsedMap,
    );
  }
}

class MarketCareerPathLite {
  final int id;
  final String name;

  const MarketCareerPathLite({required this.id, required this.name});

  factory MarketCareerPathLite.fromJson(Map<String, dynamic> json) {
    return MarketCareerPathLite(
      id: _asInt(json['id'] ?? json['career_path_id'] ?? json['CareerPathID']),
      name: json['name']?.toString() ?? json['Name']?.toString() ?? 'مسار مهني',
    );
  }
}

class MarketDemandSkill {
  final int skillId;
  final String skillName;
  final String skillCategory;
  final int jobPostingCount;
  final double demandPercentage;
  final String demandLevel;

  const MarketDemandSkill({
    required this.skillId,
    required this.skillName,
    required this.skillCategory,
    required this.jobPostingCount,
    required this.demandPercentage,
    required this.demandLevel,
  });

  factory MarketDemandSkill.fromJson(Map<String, dynamic> json) {
    return MarketDemandSkill(
      skillId: _asInt(json['skill_id'] ?? json['skillId'] ?? json['id']),
      skillName: json['skill_name']?.toString() ?? json['skillName']?.toString() ?? 'مهارة',
      skillCategory: json['skill_category']?.toString() ?? json['skillCategory']?.toString() ?? 'عام',
      jobPostingCount: _asInt(json['job_posting_count'] ?? json['source_job_count']),
      demandPercentage: _asDouble(json['demand_percentage'] ?? json['demand_score']),
      demandLevel: json['demand_level']?.toString() ?? 'supporting',
    );
  }
}

class MarketTrendResponse {
  final bool success;
  final String message;
  final MarketCareerPathLite careerPath;
  final String analyzedDate;
  final int totalSkills;
  final List<MarketTrendSkill> trends;

  const MarketTrendResponse({
    required this.success,
    required this.message,
    required this.careerPath,
    required this.analyzedDate,
    required this.totalSkills,
    required this.trends,
  });

  factory MarketTrendResponse.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    final trends = _asList(data['trends'])
        .whereType<Map>()
        .map((item) => MarketTrendSkill.fromJson(_asMap(item)))
        .toList();

    return MarketTrendResponse(
      success: _asBool(json['success'] ?? json['status']),
      message: json['message']?.toString() ?? '',
      careerPath: MarketCareerPathLite.fromJson(_asMap(data['career_path'])),
      analyzedDate: data['analyzed_date']?.toString() ?? '',
      totalSkills: _asInt(data['total_skills'], fallback: trends.length),
      trends: trends,
    );
  }
}

class MarketTrendSkill {
  final int skillId;
  final String skillName;
  final String skillCategory;
  final double demandScore;
  final String trendDirection;
  final int sourceJobCount;
  final String analyzedDate;

  const MarketTrendSkill({
    required this.skillId,
    required this.skillName,
    required this.skillCategory,
    required this.demandScore,
    required this.trendDirection,
    required this.sourceJobCount,
    required this.analyzedDate,
  });

  factory MarketTrendSkill.fromJson(Map<String, dynamic> json) {
    return MarketTrendSkill(
      skillId: _asInt(json['skill_id'] ?? json['skillId']),
      skillName: json['skill_name']?.toString() ?? json['skillName']?.toString() ?? 'مهارة',
      skillCategory: json['skill_category']?.toString() ?? json['skillCategory']?.toString() ?? 'عام',
      demandScore: _asDouble(json['demand_score'] ?? json['demandPercentage']),
      trendDirection: json['trend_direction']?.toString() ?? 'new',
      sourceJobCount: _asInt(json['source_job_count'] ?? json['job_posting_count']),
      analyzedDate: json['analyzed_date']?.toString() ?? '',
    );
  }
}

class MarketSkillEvidenceResponse {
  final bool success;
  final String message;
  final MarketCareerPathLite careerPath;
  final int skillId;
  final int totalReturned;
  final List<MarketSkillEvidence> evidence;

  const MarketSkillEvidenceResponse({
    required this.success,
    required this.message,
    required this.careerPath,
    required this.skillId,
    required this.totalReturned,
    required this.evidence,
  });

  factory MarketSkillEvidenceResponse.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    final evidence = _asList(data['evidence'])
        .whereType<Map>()
        .map((item) => MarketSkillEvidence.fromJson(_asMap(item)))
        .toList();

    return MarketSkillEvidenceResponse(
      success: _asBool(json['success'] ?? json['status']),
      message: json['message']?.toString() ?? '',
      careerPath: MarketCareerPathLite.fromJson(_asMap(data['career_path'])),
      skillId: _asInt(data['skill_id']),
      totalReturned: _asInt(data['total_returned'], fallback: evidence.length),
      evidence: evidence,
    );
  }
}

class MarketSkillEvidence {
  final MarketJobPosting jobPosting;
  final MarketEvidenceSkill skill;
  final MarketEvidenceText evidence;

  const MarketSkillEvidence({
    required this.jobPosting,
    required this.skill,
    required this.evidence,
  });

  factory MarketSkillEvidence.fromJson(Map<String, dynamic> json) {
    return MarketSkillEvidence(
      jobPosting: MarketJobPosting.fromJson(_asMap(json['job_posting'])),
      skill: MarketEvidenceSkill.fromJson(_asMap(json['skill'])),
      evidence: MarketEvidenceText.fromJson(_asMap(json['evidence'])),
    );
  }
}

class MarketJobPosting {
  final int id;
  final String title;
  final String companyName;
  final String location;
  final String language;
  final String sourceName;

  const MarketJobPosting({
    required this.id,
    required this.title,
    required this.companyName,
    required this.location,
    required this.language,
    required this.sourceName,
  });

  factory MarketJobPosting.fromJson(Map<String, dynamic> json) {
    return MarketJobPosting(
      id: _asInt(json['id']),
      title: json['title']?.toString() ?? 'إعلان وظيفة',
      companyName: json['company_name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
      sourceName: json['source_name']?.toString() ?? '',
    );
  }
}

class MarketEvidenceSkill {
  final int id;
  final String name;
  final String category;

  const MarketEvidenceSkill({
    required this.id,
    required this.name,
    required this.category,
  });

  factory MarketEvidenceSkill.fromJson(Map<String, dynamic> json) {
    return MarketEvidenceSkill(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? 'مهارة',
      category: json['category']?.toString() ?? 'عام',
    );
  }
}

class MarketEvidenceText {
  final String matchedText;
  final String matchedLanguage;
  final String alias;
  final double confidence;
  final String extractionMethod;
  final String context;

  const MarketEvidenceText({
    required this.matchedText,
    required this.matchedLanguage,
    required this.alias,
    required this.confidence,
    required this.extractionMethod,
    required this.context,
  });

  factory MarketEvidenceText.fromJson(Map<String, dynamic> json) {
    return MarketEvidenceText(
      matchedText: json['matched_text']?.toString() ?? '',
      matchedLanguage: json['matched_language']?.toString() ?? '',
      alias: json['alias']?.toString() ?? '',
      confidence: _asDouble(json['confidence']),
      extractionMethod: json['extraction_method']?.toString() ?? '',
      context: json['context']?.toString() ?? '',
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  return <dynamic>[];
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _asDouble(dynamic value, {double fallback = 0}) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  final text = value?.toString().toLowerCase().trim();
  return text == 'true' || text == '1' || text == 'yes';
}
