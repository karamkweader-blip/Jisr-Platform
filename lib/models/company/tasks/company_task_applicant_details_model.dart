class CompanyTaskApplicantDetailsModel {
  final ApplicantApplicationModel application;
  final ApplicantTaskModel task;
  final ApplicantStudentModel student;
  final ApplicantMatchingModel matching;

  const CompanyTaskApplicantDetailsModel({
    required this.application,
    required this.task,
    required this.student,
    required this.matching,
  });

  factory CompanyTaskApplicantDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskApplicantDetailsModel(
      application: ApplicantApplicationModel.fromJson(
        json['application'] as Map<String, dynamic>? ?? {},
      ),
      task: ApplicantTaskModel.fromJson(
        json['task'] as Map<String, dynamic>? ?? {},
      ),
      student: ApplicantStudentModel.fromJson(
        json['student'] as Map<String, dynamic>? ?? {},
      ),
      matching: ApplicantMatchingModel.fromJson(
        json['matching'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    final text = value?.toString().toLowerCase();
    return text == 'true' || text == '1';
  }

  static List<String> _toStringList(dynamic value) {
    if (value is! List) return [];
    return value.map((item) => item.toString()).toList();
  }
}

class ApplicantApplicationModel {
  final int id;
  final String status;
  final String message;
  final String? githubUrl;
  final DateTime? appliedAt;
  final DateTime? reviewedAt;
  final String? companyNotes;

  const ApplicantApplicationModel({
    required this.id,
    required this.status,
    required this.message,
    required this.githubUrl,
    required this.appliedAt,
    required this.reviewedAt,
    required this.companyNotes,
  });

  factory ApplicantApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicantApplicationModel(
      id: CompanyTaskApplicantDetailsModel._toInt(json['id']),
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      githubUrl: json['github_url']?.toString(),
      appliedAt: CompanyTaskApplicantDetailsModel._toDate(json['applied_at']),
      reviewedAt: CompanyTaskApplicantDetailsModel._toDate(json['reviewed_at']),
      companyNotes: json['company_notes']?.toString(),
    );
  }

  bool get isPending => status == 'pending';
}

class ApplicantTaskModel {
  final int id;
  final String title;
  final String difficultyLevel;
  final List<ApplicantRequiredSkillModel> requiredSkills;

  const ApplicantTaskModel({
    required this.id,
    required this.title,
    required this.difficultyLevel,
    required this.requiredSkills,
  });

  factory ApplicantTaskModel.fromJson(Map<String, dynamic> json) {
    return ApplicantTaskModel(
      id: CompanyTaskApplicantDetailsModel._toInt(json['id']),
      title: json['title']?.toString() ?? '',
      difficultyLevel: json['difficulty_level']?.toString() ?? '',
      requiredSkills: (json['required_skills'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ApplicantRequiredSkillModel.fromJson)
          .toList(),
    );
  }
}

class ApplicantRequiredSkillModel {
  final int id;
  final String name;
  final String category;
  final int requiredLevel;
  final double weight;
  final bool mandatory;

  const ApplicantRequiredSkillModel({
    required this.id,
    required this.name,
    required this.category,
    required this.requiredLevel,
    required this.weight,
    required this.mandatory,
  });

  factory ApplicantRequiredSkillModel.fromJson(Map<String, dynamic> json) {
    return ApplicantRequiredSkillModel(
      id: CompanyTaskApplicantDetailsModel._toInt(json['id']),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      requiredLevel:
          CompanyTaskApplicantDetailsModel._toInt(json['required_level']),
      weight: CompanyTaskApplicantDetailsModel._toDouble(json['weight']),
      mandatory: CompanyTaskApplicantDetailsModel._toBool(json['mandatory']),
    );
  }
}

class ApplicantStudentModel {
  final int id;
  final ApplicantStudentProfileModel profile;
  final List<ApplicantStudentSkillModel> skills;
  final List<ApplicantPortfolioProjectModel> portfolioProjects;

  const ApplicantStudentModel({
    required this.id,
    required this.profile,
    required this.skills,
    required this.portfolioProjects,
  });

  factory ApplicantStudentModel.fromJson(Map<String, dynamic> json) {
    return ApplicantStudentModel(
      id: CompanyTaskApplicantDetailsModel._toInt(json['id']),
      profile: ApplicantStudentProfileModel.fromJson(
        json['profile'] as Map<String, dynamic>? ?? {},
      ),
      skills: (json['skills'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ApplicantStudentSkillModel.fromJson)
          .toList(),
      portfolioProjects: (json['portfolio_projects'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ApplicantPortfolioProjectModel.fromJson)
          .toList(),
    );
  }

  String get displayName {
    if (profile.user.name.trim().isNotEmpty) {
      return profile.user.name;
    }

    return 'طالب بدون اسم';
  }
}

class ApplicantStudentProfileModel {
  final int id;
  final ApplicantUserModel user;
  final String? university;
  final String? major;
  final int? graduationYear;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ApplicantStudentProfileModel({
    required this.id,
    required this.user,
    required this.university,
    required this.major,
    required this.graduationYear,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApplicantStudentProfileModel.fromJson(Map<String, dynamic> json) {
    final graduationYearValue = json['graduation_year'];

    return ApplicantStudentProfileModel(
      id: CompanyTaskApplicantDetailsModel._toInt(json['id']),
      user: ApplicantUserModel.fromJson(
        json['user'] as Map<String, dynamic>? ?? {},
      ),
      university: json['university']?.toString(),
      major: json['major']?.toString(),
      graduationYear: graduationYearValue == null
          ? null
          : CompanyTaskApplicantDetailsModel._toInt(graduationYearValue),
      phone: json['phone']?.toString(),
      createdAt: CompanyTaskApplicantDetailsModel._toDate(json['created_at']),
      updatedAt: CompanyTaskApplicantDetailsModel._toDate(json['updated_at']),
    );
  }
}

class ApplicantUserModel {
  final int id;
  final String name;
  final String email;
  final String isVerifiedByAdmin;
  final String? profilePictureUrl;
  final String? bio;
  final bool isActive;

  const ApplicantUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isVerifiedByAdmin,
    required this.profilePictureUrl,
    required this.bio,
    required this.isActive,
  });

  factory ApplicantUserModel.fromJson(Map<String, dynamic> json) {
    return ApplicantUserModel(
      id: CompanyTaskApplicantDetailsModel._toInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      isVerifiedByAdmin: json['is_verified_by_admin']?.toString() ?? '',
      profilePictureUrl: json['profile_picture_url']?.toString(),
      bio: json['bio']?.toString(),
      isActive: CompanyTaskApplicantDetailsModel._toBool(json['is_active']),
    );
  }
}

class ApplicantStudentSkillModel {
  final int id;
  final String name;
  final String category;
  final int proficiencyLevel;
  final double confidenceScore;
  final bool verified;

  const ApplicantStudentSkillModel({
    required this.id,
    required this.name,
    required this.category,
    required this.proficiencyLevel,
    required this.confidenceScore,
    required this.verified,
  });

  factory ApplicantStudentSkillModel.fromJson(Map<String, dynamic> json) {
    return ApplicantStudentSkillModel(
      id: CompanyTaskApplicantDetailsModel._toInt(json['id']),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      proficiencyLevel:
          CompanyTaskApplicantDetailsModel._toInt(json['proficiency_level']),
      confidenceScore:
          CompanyTaskApplicantDetailsModel._toDouble(json['confidence_score']),
      verified: CompanyTaskApplicantDetailsModel._toBool(json['verified']),
    );
  }
}

class ApplicantPortfolioProjectModel {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String? projectUrl;
  final String source;
  final DateTime? completionDate;
  final double? grade;

  const ApplicantPortfolioProjectModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.projectUrl,
    required this.source,
    required this.completionDate,
    required this.grade,
  });

  factory ApplicantPortfolioProjectModel.fromJson(Map<String, dynamic> json) {
    return ApplicantPortfolioProjectModel(
      id: CompanyTaskApplicantDetailsModel._toInt(json['id']),
      userId: CompanyTaskApplicantDetailsModel._toInt(json['user_id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      projectUrl: json['project_url']?.toString(),
      source: json['source']?.toString() ?? '',
      completionDate:
          CompanyTaskApplicantDetailsModel._toDate(json['completion_date']),
      grade: CompanyTaskApplicantDetailsModel._toNullableDouble(json['grade']),
    );
  }
}

class ApplicantMatchingModel {
  final double score;
  final List<String> reasons;

  const ApplicantMatchingModel({
    required this.score,
    required this.reasons,
  });

  factory ApplicantMatchingModel.fromJson(Map<String, dynamic> json) {
    return ApplicantMatchingModel(
      score: CompanyTaskApplicantDetailsModel._toDouble(json['score']),
      reasons: CompanyTaskApplicantDetailsModel._toStringList(json['reasons']),
    );
  }
}