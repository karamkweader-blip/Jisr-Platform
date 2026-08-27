class CompanyStudentDetailsModel {
  final int id;
  final String name;
  final String email;
  final String? profilePictureUrl;
  final String? bio;
  final bool isVerifiedByAdmin;
  final CompanyStudentProfileModel profile;
  final List<CompanyStudentSkillModel> skills;
  final List<CompanyStudentCvModel> cvs;
  final List<CompanyStudentPortfolioProjectModel>
      portfolioProjects;

  const CompanyStudentDetailsModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
    required this.bio,
    required this.isVerifiedByAdmin,
    required this.profile,
    required this.skills,
    required this.cvs,
    required this.portfolioProjects,
  });

  factory CompanyStudentDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawProfile = json['student_profile'];

    return CompanyStudentDetailsModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString().trim() ?? '',
      email: json['email']?.toString().trim() ?? '',
      profilePictureUrl: _nullableString(
        json['profile_picture_url'],
      ),
      bio: _nullableString(json['bio']),
      isVerifiedByAdmin: _parseBool(
        json['is_verified_by_admin'],
      ),
      profile: CompanyStudentProfileModel.fromJson(
        rawProfile is Map
            ? Map<String, dynamic>.from(rawProfile)
            : const <String, dynamic>{},
      ),
      skills: _mapList(
        json['skills'],
        CompanyStudentSkillModel.fromJson,
      ),
      cvs: _mapList(
        json['cvs'],
        CompanyStudentCvModel.fromJson,
      ),
      portfolioProjects: _mapList(
        json['portfolio_projects'],
        CompanyStudentPortfolioProjectModel.fromJson,
      ),
    );
  }
}

class CompanyStudentProfileModel {
  final String? university;
  final String? major;
  final String? graduationYear;
  final String? phone;

  const CompanyStudentProfileModel({
    required this.university,
    required this.major,
    required this.graduationYear,
    required this.phone,
  });

  factory CompanyStudentProfileModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyStudentProfileModel(
      university: _nullableString(json['university']),
      major: _nullableString(json['major']),
      graduationYear: _nullableString(
        json['graduation_year'],
      ),
      phone: _nullableString(json['phone']),
    );
  }
}

class CompanyStudentSkillModel {
  final int id;
  final String name;
  final String category;
  final int proficiencyLevel;
  final double confidenceScore;
  final String source;
  final bool verified;

  const CompanyStudentSkillModel({
    required this.id,
    required this.name,
    required this.category,
    required this.proficiencyLevel,
    required this.confidenceScore,
    required this.source,
    required this.verified,
  });

  factory CompanyStudentSkillModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyStudentSkillModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString().trim() ?? '',
      category: json['category']?.toString().trim() ?? '',
      proficiencyLevel: _parseInt(
        json['proficiency_level'],
      ),
      confidenceScore: _parseDouble(
        json['confidence_score'],
      ),
      source: json['source']?.toString().trim() ?? '',
      verified: _parseBool(json['verified']),
    );
  }
}

class CompanyStudentCvModel {
  final int id;
  final String fileUrl;
  final bool isPrimary;
  final DateTime? uploadedAt;

  const CompanyStudentCvModel({
    required this.id,
    required this.fileUrl,
    required this.isPrimary,
    required this.uploadedAt,
  });

  factory CompanyStudentCvModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyStudentCvModel(
      id: _parseInt(json['id']),
      fileUrl: json['file_url']?.toString().trim() ?? '',
      isPrimary: _parseBool(json['is_primary']),
      uploadedAt: DateTime.tryParse(
        json['uploaded_at']?.toString() ?? '',
      ),
    );
  }
}

class CompanyStudentPortfolioProjectModel {
  final int id;
  final String title;
  final String? description;
  final String? projectUrl;
  final List<String> technologies;

  const CompanyStudentPortfolioProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.projectUrl,
    required this.technologies,
  });

  factory CompanyStudentPortfolioProjectModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawTechnologies =
        json['technologies'] ?? json['skills'];

    return CompanyStudentPortfolioProjectModel(
      id: _parseInt(json['id']),
      title: _nullableString(
            json['title'] ?? json['name'],
          ) ??
          'مشروع بدون عنوان',
      description: _nullableString(
        json['description'],
      ),
      projectUrl: _nullableString(
        json['project_url'] ??
            json['url'] ??
            json['repository_url'] ??
            json['github_url'],
      ),
      technologies: rawTechnologies is List
          ? rawTechnologies
              .map((item) {
                if (item is Map) {
                  return item['name']
                          ?.toString()
                          .trim() ??
                      '';
                }

                return item.toString().trim();
              })
              .where((item) => item.isNotEmpty)
              .toList()
          : const <String>[],
    );
  }
}

List<T> _mapList<T>(
  Object? value,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (value is! List) {
    return <T>[];
  }

  return value
      .whereType<Map>()
      .map(
        (item) => fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .toList();
}

int _parseInt(
  Object? value, {
  int fallback = 0,
}) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _parseDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString() ?? '') ?? 0;
}

bool _parseBool(Object? value) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value != 0;
  }

  return value?.toString().toLowerCase() == 'true' ||
      value == '1';
}

String? _nullableString(Object? value) {
  final normalized = value?.toString().trim();

  return normalized == null || normalized.isEmpty
      ? null
      : normalized;
}