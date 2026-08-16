class MentorSpecializations {
  static const String backend = 'backend';
  static const String frontend = 'frontend';
  static const String flutter = 'flutter';
  static const String ai = 'ai';
  static const String devops = 'devops';

  static const List<String> values = <String>[
    backend,
    frontend,
    flutter,
    ai,
    devops,
  ];

  static String label(String value) {
    switch (value) {
      case backend:
        return 'Backend';
      case frontend:
        return 'Frontend';
      case flutter:
        return 'Flutter';
      case ai:
        return 'AI';
      case devops:
        return 'DevOps';
      default:
        return value;
    }
  }
}

class MentorTopics {
  static const String careerGuidance = 'career_guidance';
  static const String projectReview = 'project_review';
  static const String interviewPreparation = 'interview_preparation';
  static const String cvReview = 'cv_review';

  static const List<String> values = <String>[
    careerGuidance,
    projectReview,
    interviewPreparation,
    cvReview,
  ];

  static String label(String value) {
    switch (value) {
      case careerGuidance:
        return 'الإرشاد المهني';
      case projectReview:
        return 'مراجعة المشاريع';
      case interviewPreparation:
        return 'التحضير للمقابلات';
      case cvReview:
        return 'مراجعة السيرة الذاتية';
      default:
        return value;
    }
  }
}

class MentorApplicationStatuses {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';

  static String label(String value) {
    switch (value) {
      case pending:
        return 'قيد المراجعة';
      case approved:
        return 'تمت الموافقة';
      case rejected:
        return 'مرفوض';
      default:
        return value.isEmpty ? 'غير محدد' : value;
    }
  }
}

class MentorApplicationModel {
  final int id;
  final String source;
  final String status;
  final String fullName;
  final String email;
  final String whatsappNumber;
  final String specialization;
  final String professionalTitle;
  final String expertise;
  final String bio;
  final String linkedinUrl;
  final String githubOrPortfolioUrl;
  final List<String> mentoringTopics;
  final String? rejectionReason;
  final String? reviewedAt;
  final String? createdAt;

  const MentorApplicationModel({
    required this.id,
    required this.source,
    required this.status,
    required this.fullName,
    required this.email,
    required this.whatsappNumber,
    required this.specialization,
    required this.professionalTitle,
    required this.expertise,
    required this.bio,
    required this.linkedinUrl,
    required this.githubOrPortfolioUrl,
    required this.mentoringTopics,
    required this.rejectionReason,
    required this.reviewedAt,
    required this.createdAt,
  });

  factory MentorApplicationModel.fromJson(Map<String, dynamic> json) {
    return MentorApplicationModel(
      id: _MentorJson.toInt(json['id']),
      source: json['source']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      whatsappNumber: json['whatsapp_number']?.toString() ?? '',
      specialization: json['specialization']?.toString() ?? '',
      professionalTitle: json['professional_title']?.toString() ?? '',
      expertise: json['expertise']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      linkedinUrl: json['linkedin_url']?.toString() ?? '',
      githubOrPortfolioUrl:
          json['github_or_portfolio_url']?.toString() ?? '',
      mentoringTopics: _MentorJson.stringList(json['mentoring_topics']),
      rejectionReason: _MentorJson.nullableString(json['rejection_reason']),
      reviewedAt: _MentorJson.nullableString(json['reviewed_at']),
      createdAt: _MentorJson.nullableString(json['created_at']),
    );
  }
}

class MentorSkillModel {
  final int id;
  final String name;
  final String category;

  const MentorSkillModel({
    required this.id,
    required this.name,
    required this.category,
  });

  factory MentorSkillModel.fromJson(Map<String, dynamic> json) {
    return MentorSkillModel(
      id: _MentorJson.toInt(json['id']),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
    );
  }
}

class MentorMatchingSkillModel {
  final int id;
  final String name;

  const MentorMatchingSkillModel({required this.id, required this.name});

  factory MentorMatchingSkillModel.fromJson(Map<String, dynamic> json) {
    return MentorMatchingSkillModel(
      id: _MentorJson.toInt(json['id']),
      name: json['name']?.toString() ?? '',
    );
  }
}

class MentorRecommendationModel {
  final bool isRecommended;
  final bool specializationMatch;
  final int matchingSkillCount;
  final List<MentorMatchingSkillModel> matchingSkills;

  const MentorRecommendationModel({
    required this.isRecommended,
    required this.specializationMatch,
    required this.matchingSkillCount,
    required this.matchingSkills,
  });

  factory MentorRecommendationModel.fromJson(Map<String, dynamic> json) {
    return MentorRecommendationModel(
      isRecommended: json['is_recommended'] == true,
      specializationMatch: json['specialization_match'] == true,
      matchingSkillCount: _MentorJson.toInt(json['matching_skill_count']),
      matchingSkills: _MentorJson.mapList(json['matching_skills'])
          .map(MentorMatchingSkillModel.fromJson)
          .toList(),
    );
  }
}

class StudentMentorModel {
  final int id;
  final String fullName;
  final String email;
  final String whatsappNumber;
  final String specialization;
  final String professionalTitle;
  final String expertise;
  final String bio;
  final String linkedinUrl;
  final String githubOrPortfolioUrl;
  final List<String> mentoringTopics;
  final List<MentorSkillModel> skills;
  final Map<String, dynamic>? company;
  final MentorRecommendationModel recommendation;

  const StudentMentorModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.whatsappNumber,
    required this.specialization,
    required this.professionalTitle,
    required this.expertise,
    required this.bio,
    required this.linkedinUrl,
    required this.githubOrPortfolioUrl,
    required this.mentoringTopics,
    required this.skills,
    required this.company,
    required this.recommendation,
  });

  factory StudentMentorModel.fromJson(Map<String, dynamic> json) {
    return StudentMentorModel(
      id: _MentorJson.toInt(json['id']),
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      whatsappNumber: json['whatsapp_number']?.toString() ?? '',
      specialization: json['specialization']?.toString() ?? '',
      professionalTitle: json['professional_title']?.toString() ?? '',
      expertise: json['expertise']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      linkedinUrl: json['linkedin_url']?.toString() ?? '',
      githubOrPortfolioUrl:
          json['github_or_portfolio_url']?.toString() ?? '',
      mentoringTopics: _MentorJson.stringList(json['mentoring_topics']),
      skills: _MentorJson.mapList(json['skills'])
          .map(MentorSkillModel.fromJson)
          .toList(),
      company: json['company'] is Map
          ? Map<String, dynamic>.from(json['company'])
          : null,
      recommendation: MentorRecommendationModel.fromJson(
        _MentorJson.map(json['recommendation']),
      ),
    );
  }
}

class MentorRecommendationContextModel {
  final String careerPath;
  final String specialization;
  final String skillSource;
  final List<MentorSkillModel> targetSkills;

  const MentorRecommendationContextModel({
    required this.careerPath,
    required this.specialization,
    required this.skillSource,
    required this.targetSkills,
  });

  factory MentorRecommendationContextModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MentorRecommendationContextModel(
      careerPath: json['career_path']?.toString() ?? '',
      specialization: json['specialization']?.toString() ?? '',
      skillSource: json['skill_source']?.toString() ?? 'none',
      targetSkills: _MentorJson.mapList(json['target_skills'])
          .map(MentorSkillModel.fromJson)
          .toList(),
    );
  }
}

class MentorPaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const MentorPaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory MentorPaginationModel.fromJson(Map<String, dynamic> json) {
    return MentorPaginationModel(
      currentPage: _MentorJson.toInt(json['current_page']),
      lastPage: _MentorJson.toInt(json['last_page']),
      perPage: _MentorJson.toInt(json['per_page']),
      total: _MentorJson.toInt(json['total']),
    );
  }
}

class StudentMentorsResponse {
  final bool success;
  final String message;
  final MentorRecommendationContextModel recommendationContext;
  final List<StudentMentorModel> mentors;
  final MentorPaginationModel pagination;

  const StudentMentorsResponse({
    required this.success,
    required this.message,
    required this.recommendationContext,
    required this.mentors,
    required this.pagination,
  });

  factory StudentMentorsResponse.fromJson(Map<String, dynamic> json) {
    final data = _MentorJson.map(json['data']);
    return StudentMentorsResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      recommendationContext: MentorRecommendationContextModel.fromJson(
        _MentorJson.map(data['recommendation_context']),
      ),
      mentors: _MentorJson.mapList(data['mentors'])
          .map(StudentMentorModel.fromJson)
          .toList(),
      pagination: MentorPaginationModel.fromJson(
        _MentorJson.map(data['pagination']),
      ),
    );
  }
}

class _MentorJson {
  static int toInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

  static String? nullableString(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static Map<String, dynamic> map(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> mapList(dynamic value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static List<String> stringList(dynamic value) {
    if (value is! List) return const <String>[];
    return value.map((item) => item.toString()).toList();
  }
}
