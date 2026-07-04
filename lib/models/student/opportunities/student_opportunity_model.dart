class StudentOpportunitiesResponse {
  final List<StudentOpportunityModel> data;

  StudentOpportunitiesResponse({required this.data});

  factory StudentOpportunitiesResponse.fromJson(Map<String, dynamic> json) {
    return StudentOpportunitiesResponse(
      data: (json['data'] as List? ?? [])
          .map((item) => StudentOpportunityModel.fromJson(item))
          .toList(),
    );
  }
}

class StudentOpportunityDetailsResponse {
  final StudentOpportunityDetailsModel data;

  StudentOpportunityDetailsResponse({required this.data});

  factory StudentOpportunityDetailsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentOpportunityDetailsResponse(
      data: StudentOpportunityDetailsModel.fromJson(json['data'] ?? {}),
    );
  }
}

class StudentOpportunityApplyResponse {
  final bool success;
  final String message;
  final StudentOpportunityApplicationModel? data;

  StudentOpportunityApplyResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StudentOpportunityApplyResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return StudentOpportunityApplyResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: rawData is Map<String, dynamic>
          ? StudentOpportunityApplicationModel.fromJson(rawData)
          : null,
    );
  }
}

class StudentOpportunityModel {
  final int id;
  final String title;
  final String description;
  final String type;
  final StudentOpportunityCompanyModel company;
  final String location;
  final String salaryMin;
  final String salaryMax;
  final String? deadline;
  final String? postedAt;
  final int applicationsCount;
  final int matchScore;
  final String matchLabel;
  final List<String> matchReasons;
  final List<StudentOpportunityMatchedSkillModel> matchedSkills;
  final List<StudentOpportunityMissingSkillModel> missingSkills;
  final List<StudentOpportunityMissingSkillModel> missingMandatorySkills;
  final bool alreadyApplied;
  final String? applicationStatus;

  StudentOpportunityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.company,
    required this.location,
    required this.salaryMin,
    required this.salaryMax,
    required this.deadline,
    required this.postedAt,
    required this.applicationsCount,
    required this.matchScore,
    required this.matchLabel,
    required this.matchReasons,
    required this.matchedSkills,
    required this.missingSkills,
    required this.missingMandatorySkills,
    required this.alreadyApplied,
    required this.applicationStatus,
  });

  factory StudentOpportunityModel.fromJson(Map<String, dynamic> json) {
    return StudentOpportunityModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      company: StudentOpportunityCompanyModel.fromJson(json['company'] ?? {}),
      location: json['location']?.toString() ?? '',
      salaryMin: json['salary_min']?.toString() ?? '',
      salaryMax: json['salary_max']?.toString() ?? '',
      deadline: json['deadline']?.toString(),
      postedAt: json['posted_at']?.toString(),
      applicationsCount:
          int.tryParse(json['applications_count'].toString()) ?? 0,
      matchScore: int.tryParse(json['match_score'].toString()) ?? 0,
      matchLabel: json['match_label']?.toString() ?? '',
      matchReasons: (json['match_reasons'] as List? ?? [])
          .map((item) => item.toString())
          .toList(),
      matchedSkills: (json['matched_skills'] as List? ?? [])
          .map((item) => StudentOpportunityMatchedSkillModel.fromJson(item))
          .toList(),
      missingSkills: (json['missing_skills'] as List? ?? [])
          .map((item) => StudentOpportunityMissingSkillModel.fromJson(item))
          .toList(),
      missingMandatorySkills:
          (json['missing_mandatory_skills'] as List? ?? [])
              .map((item) => StudentOpportunityMissingSkillModel.fromJson(item))
              .toList(),
      alreadyApplied: json['already_applied'] == true,
      applicationStatus: json['application_status']?.toString(),
    );
  }
}

class StudentOpportunityDetailsModel extends StudentOpportunityModel {
  final String status;
  final List<StudentOpportunitySkillModel> skills;
  final bool isEligibleForRecommendation;
  final bool canApply;
  final String? cannotApplyReason;

  StudentOpportunityDetailsModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.company,
    required super.location,
    required super.salaryMin,
    required super.salaryMax,
    required super.deadline,
    required super.postedAt,
    required super.applicationsCount,
    required super.matchScore,
    required super.matchLabel,
    required super.matchReasons,
    required super.matchedSkills,
    required super.missingSkills,
    required super.missingMandatorySkills,
    required super.alreadyApplied,
    required super.applicationStatus,
    required this.status,
    required this.skills,
    required this.isEligibleForRecommendation,
    required this.canApply,
    required this.cannotApplyReason,
  });

  factory StudentOpportunityDetailsModel.fromJson(Map<String, dynamic> json) {
    final base = StudentOpportunityModel.fromJson(json);

    return StudentOpportunityDetailsModel(
      id: base.id,
      title: base.title,
      description: base.description,
      type: base.type,
      company: base.company,
      location: base.location,
      salaryMin: base.salaryMin,
      salaryMax: base.salaryMax,
      deadline: base.deadline,
      postedAt: base.postedAt,
      applicationsCount: base.applicationsCount,
      matchScore: base.matchScore,
      matchLabel: base.matchLabel,
      matchReasons: base.matchReasons,
      matchedSkills: base.matchedSkills,
      missingSkills: base.missingSkills,
      missingMandatorySkills: base.missingMandatorySkills,
      alreadyApplied: base.alreadyApplied,
      applicationStatus: base.applicationStatus,
      status: json['status']?.toString() ?? '',
      skills: (json['skills'] as List? ?? [])
          .map((item) => StudentOpportunitySkillModel.fromJson(item))
          .toList(),
      isEligibleForRecommendation:
          json['is_eligible_for_recommendation'] == true,
      canApply: json['can_apply'] != false,
      cannotApplyReason: json['cannot_apply_reason']?.toString(),
    );
  }
}

class StudentOpportunityCompanyModel {
  final int id;
  final String name;
  final String industry;
  final String? website;
  final String? description;

  StudentOpportunityCompanyModel({
    required this.id,
    required this.name,
    required this.industry,
    required this.website,
    required this.description,
  });

  factory StudentOpportunityCompanyModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['name']?.toString();
    final industry = json['industry']?.toString() ?? '';

    return StudentOpportunityCompanyModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: rawName == null || rawName.trim().isEmpty
          ? 'شركة غير محددة'
          : rawName,
      industry: industry,
      website: json['website']?.toString(),
      description: json['description']?.toString(),
    );
  }
}

class StudentOpportunitySkillModel {
  final int id;
  final String name;
  final String category;
  final double requiredLevel;
  final bool mandatory;
  final double weight;

  StudentOpportunitySkillModel({
    required this.id,
    required this.name,
    required this.category,
    required this.requiredLevel,
    required this.mandatory,
    required this.weight,
  });

  factory StudentOpportunitySkillModel.fromJson(Map<String, dynamic> json) {
    return StudentOpportunitySkillModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      requiredLevel: double.tryParse(json['required_level'].toString()) ?? 0,
      mandatory: json['mandatory'] == true,
      weight: double.tryParse(json['weight'].toString()) ?? 0,
    );
  }
}

class StudentOpportunityMatchedSkillModel {
  final int id;
  final String name;
  final double requiredLevel;
  final double studentLevel;
  final bool mandatory;
  final double weight;
  final String matchType;

  StudentOpportunityMatchedSkillModel({
    required this.id,
    required this.name,
    required this.requiredLevel,
    required this.studentLevel,
    required this.mandatory,
    required this.weight,
    required this.matchType,
  });

  factory StudentOpportunityMatchedSkillModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentOpportunityMatchedSkillModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      requiredLevel: double.tryParse(json['required_level'].toString()) ?? 0,
      studentLevel: double.tryParse(json['student_level'].toString()) ?? 0,
      mandatory: json['mandatory'] == true,
      weight: double.tryParse(json['weight'].toString()) ?? 0,
      matchType: json['match_type']?.toString() ?? '',
    );
  }
}

class StudentOpportunityMissingSkillModel {
  final int id;
  final String name;
  final double requiredLevel;
  final bool mandatory;
  final double weight;

  StudentOpportunityMissingSkillModel({
    required this.id,
    required this.name,
    required this.requiredLevel,
    required this.mandatory,
    required this.weight,
  });

  factory StudentOpportunityMissingSkillModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentOpportunityMissingSkillModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      requiredLevel: double.tryParse(json['required_level'].toString()) ?? 0,
      mandatory: json['mandatory'] == true,
      weight: double.tryParse(json['weight'].toString()) ?? 0,
    );
  }
}

class StudentOpportunityApplicationModel {
  final int id;
  final String status;
  final String displayStatus;
  final String matchScore;
  final String? appliedAt;

  StudentOpportunityApplicationModel({
    required this.id,
    required this.status,
    required this.displayStatus,
    required this.matchScore,
    required this.appliedAt,
  });

  factory StudentOpportunityApplicationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentOpportunityApplicationModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      status: json['status']?.toString() ?? '',
      displayStatus: json['display_status']?.toString() ?? '',
      matchScore: json['match_score']?.toString() ?? '',
      appliedAt: json['applied_at']?.toString(),
    );
  }
}
