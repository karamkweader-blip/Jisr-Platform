class CompanyTaskAssignmentDetailsModel {
  final CompanyTaskAssignmentDetailsAssignmentModel assignment;
  final CompanyTaskAssignmentApplicationModel application;
  final CompanyTaskAssignmentDetailsTaskModel task;
  final CompanyTaskAssignmentDetailsStudentModel student;
  final CompanyTaskAssignmentDetailsMatchingModel matching;

  const CompanyTaskAssignmentDetailsModel({
    required this.assignment,
    required this.application,
    required this.task,
    required this.student,
    required this.matching,
  });

  factory CompanyTaskAssignmentDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskAssignmentDetailsModel(
      assignment: CompanyTaskAssignmentDetailsAssignmentModel.fromJson(
        _AssignmentJson.map(json['assignment']),
      ),
      application: CompanyTaskAssignmentApplicationModel.fromJson(
        _AssignmentJson.map(json['application']),
      ),
      task: CompanyTaskAssignmentDetailsTaskModel.fromJson(
        _AssignmentJson.map(json['task']),
      ),
      student: CompanyTaskAssignmentDetailsStudentModel.fromJson(
        _AssignmentJson.map(json['student']),
      ),
      matching: CompanyTaskAssignmentDetailsMatchingModel.fromJson(
        _AssignmentJson.map(json['matching']),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignment': assignment.toJson(),
      'application': application.toJson(),
      'task': task.toJson(),
      'student': student.toJson(),
      'matching': matching.toJson(),
    };
  }
}

class CompanyTaskAssignmentDetailsAssignmentModel {
  final int id;
  final String status;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final DateTime? completedAt;

  const CompanyTaskAssignmentDetailsAssignmentModel({
    required this.id,
    required this.status,
    required this.startedAt,
    required this.submittedAt,
    required this.completedAt,
  });

  factory CompanyTaskAssignmentDetailsAssignmentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskAssignmentDetailsAssignmentModel(
      id: _AssignmentJson.toInt(json['id']),
      status: json['status']?.toString() ?? '',
      startedAt: _AssignmentJson.toDate(json['started_at']),
      submittedAt: _AssignmentJson.toDate(json['submitted_at']),
      completedAt: _AssignmentJson.toDate(json['completed_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'started_at': startedAt?.toIso8601String(),
      'submitted_at': submittedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}

class CompanyTaskAssignmentApplicationModel {
  final int id;
  final String status;
  final String? message;
  final String? githubUrl;
  final DateTime? appliedAt;
  final DateTime? reviewedAt;
  final String? companyNotes;

  const CompanyTaskAssignmentApplicationModel({
    required this.id,
    required this.status,
    required this.message,
    required this.githubUrl,
    required this.appliedAt,
    required this.reviewedAt,
    required this.companyNotes,
  });

  factory CompanyTaskAssignmentApplicationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskAssignmentApplicationModel(
      id: _AssignmentJson.toInt(json['id']),
      status: json['status']?.toString() ?? '',
      message: _AssignmentJson.nullableString(json['message']),
      githubUrl: _AssignmentJson.nullableString(json['github_url']),
      appliedAt: _AssignmentJson.toDate(json['applied_at']),
      reviewedAt: _AssignmentJson.toDate(json['reviewed_at']),
      companyNotes: _AssignmentJson.nullableString(json['company_notes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'message': message,
      'github_url': githubUrl,
      'applied_at': appliedAt?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'company_notes': companyNotes,
    };
  }
}

class CompanyTaskAssignmentDetailsTaskModel {
  final int id;
  final String title;
  final String description;
  final String difficultyLevel;
  final DateTime? deadline;
  final List<CompanyTaskAssignmentRequiredSkillModel> requiredSkills;

  const CompanyTaskAssignmentDetailsTaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficultyLevel,
    required this.deadline,
    required this.requiredSkills,
  });

  factory CompanyTaskAssignmentDetailsTaskModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final skills = _AssignmentJson.maps(json['required_skills'])
        .map(CompanyTaskAssignmentRequiredSkillModel.fromJson)
        .toList();

    return CompanyTaskAssignmentDetailsTaskModel(
      id: _AssignmentJson.toInt(json['id']),
      title: json['title']?.toString() ?? 'مهمة بدون عنوان',
      description: json['description']?.toString() ?? '',
      difficultyLevel: json['difficulty_level']?.toString() ?? '',
      deadline: _AssignmentJson.toDate(json['deadline']),
      requiredSkills: skills,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty_level': difficultyLevel,
      'deadline': deadline?.toIso8601String(),
      'required_skills': requiredSkills.map((skill) => skill.toJson()).toList(),
    };
  }
}

class CompanyTaskAssignmentRequiredSkillModel {
  final int id;
  final String name;
  final String category;
  final int requiredLevel;
  final double weight;
  final bool mandatory;

  const CompanyTaskAssignmentRequiredSkillModel({
    required this.id,
    required this.name,
    required this.category,
    required this.requiredLevel,
    required this.weight,
    required this.mandatory,
  });

  factory CompanyTaskAssignmentRequiredSkillModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskAssignmentRequiredSkillModel(
      id: _AssignmentJson.toInt(json['id']),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      requiredLevel: _AssignmentJson.toInt(json['required_level']),
      weight: _AssignmentJson.toDouble(json['weight']),
      mandatory: _AssignmentJson.toBool(json['mandatory']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'required_level': requiredLevel,
      'weight': weight,
      'mandatory': mandatory,
    };
  }
}

class CompanyTaskAssignmentDetailsStudentModel {
  final int id;
  final CompanyTaskAssignmentStudentProfileModel profile;
  final List<CompanyTaskAssignmentStudentSkillModel> skills;
  final List<CompanyTaskAssignmentPortfolioProjectModel> portfolioProjects;

  const CompanyTaskAssignmentDetailsStudentModel({
    required this.id,
    required this.profile,
    required this.skills,
    required this.portfolioProjects,
  });

  factory CompanyTaskAssignmentDetailsStudentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskAssignmentDetailsStudentModel(
      id: _AssignmentJson.toInt(json['id']),
      profile: CompanyTaskAssignmentStudentProfileModel.fromJson(
        _AssignmentJson.map(json['profile']),
      ),
      skills: _AssignmentJson.maps(json['skills'])
          .map(CompanyTaskAssignmentStudentSkillModel.fromJson)
          .toList(),
      portfolioProjects: _AssignmentJson.maps(json['portfolio_projects'])
          .map(CompanyTaskAssignmentPortfolioProjectModel.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile': profile.toJson(),
      'skills': skills.map((skill) => skill.toJson()).toList(),
      'portfolio_projects':
          portfolioProjects.map((project) => project.toJson()).toList(),
    };
  }
}

class CompanyTaskAssignmentStudentProfileModel {
  final int id;
  final String? university;
  final String? major;
  final String? graduationYear;
  final String? phone;

  const CompanyTaskAssignmentStudentProfileModel({
    required this.id,
    required this.university,
    required this.major,
    required this.graduationYear,
    required this.phone,
  });

  factory CompanyTaskAssignmentStudentProfileModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskAssignmentStudentProfileModel(
      id: _AssignmentJson.toInt(json['id']),
      university: _AssignmentJson.nullableString(json['university']),
      major: _AssignmentJson.nullableString(json['major']),
      graduationYear: _AssignmentJson.nullableString(json['graduation_year']),
      phone: _AssignmentJson.nullableString(json['phone']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'university': university,
      'major': major,
      'graduation_year': graduationYear,
      'phone': phone,
    };
  }
}

class CompanyTaskAssignmentStudentSkillModel {
  final int id;
  final String name;
  final String category;
  final int proficiencyLevel;
  final double? confidenceScore;
  final bool verified;

  const CompanyTaskAssignmentStudentSkillModel({
    required this.id,
    required this.name,
    required this.category,
    required this.proficiencyLevel,
    required this.confidenceScore,
    required this.verified,
  });

  factory CompanyTaskAssignmentStudentSkillModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskAssignmentStudentSkillModel(
      id: _AssignmentJson.toInt(json['id']),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      proficiencyLevel: _AssignmentJson.toInt(json['proficiency_level']),
      confidenceScore: _AssignmentJson.toNullableDouble(
        json['confidence_score'],
      ),
      verified: _AssignmentJson.toBool(json['verified']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'proficiency_level': proficiencyLevel,
      'confidence_score': confidenceScore,
      'verified': verified,
    };
  }
}

class CompanyTaskAssignmentPortfolioProjectModel {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String? projectUrl;
  final String source;
  final DateTime? completionDate;
  final double? grade;

  const CompanyTaskAssignmentPortfolioProjectModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.projectUrl,
    required this.source,
    required this.completionDate,
    required this.grade,
  });

  factory CompanyTaskAssignmentPortfolioProjectModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskAssignmentPortfolioProjectModel(
      id: _AssignmentJson.toInt(json['id']),
      userId: _AssignmentJson.toInt(json['user_id']),
      title: json['title']?.toString() ?? 'مشروع بدون عنوان',
      description: json['description']?.toString() ?? '',
      projectUrl: _AssignmentJson.nullableString(json['project_url']),
      source: json['source']?.toString() ?? '',
      completionDate: _AssignmentJson.toDate(json['completion_date']),
      grade: _AssignmentJson.toNullableDouble(json['grade']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'project_url': projectUrl,
      'source': source,
      'completion_date': completionDate?.toIso8601String(),
      'grade': grade,
    };
  }
}

class CompanyTaskAssignmentDetailsMatchingModel {
  final double score;
  final List<String> reasons;

  const CompanyTaskAssignmentDetailsMatchingModel({
    required this.score,
    required this.reasons,
  });

  factory CompanyTaskAssignmentDetailsMatchingModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskAssignmentDetailsMatchingModel(
      score: _AssignmentJson.toDouble(json['score']),
      reasons: _AssignmentJson.toStringList(json['reasons']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'reasons': reasons,
    };
  }
}

class _AssignmentJson {
  static Map<String, dynamic> map(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> maps(dynamic value) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }

    return value.whereType<Map>().map(map).toList();
  }

  static int toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? toNullableDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString());
  }

  static DateTime? toDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }

  static bool toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    return value?.toString().toLowerCase() == 'true';
  }

  static String? nullableString(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  static List<String> toStringList(dynamic value) {
    if (value is! List) {
      return <String>[];
    }

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}