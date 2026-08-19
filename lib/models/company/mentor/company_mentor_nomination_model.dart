class CompanyMentorNominationModel {
  final int id;
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
  final String? updatedAt;

  const CompanyMentorNominationModel({
    required this.id,
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
    required this.updatedAt,
  });

  factory CompanyMentorNominationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyMentorNominationModel(
      id: _CompanyMentorJson.toInt(json['id']),
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
      mentoringTopics:
          _CompanyMentorJson.stringList(json['mentoring_topics']),
      rejectionReason:
          _CompanyMentorJson.nullableString(json['rejection_reason']),
      reviewedAt:
          _CompanyMentorJson.nullableString(json['reviewed_at']),
      createdAt:
          _CompanyMentorJson.nullableString(json['created_at']),
      updatedAt:
          _CompanyMentorJson.nullableString(json['updated_at']),
    );
  }
}

class CompanyMentorNominationRequest {
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

  const CompanyMentorNominationRequest({
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
  });

  Map<String, String> toFields() {
    return <String, String>{
      'full_name': fullName,
      'email': email,
      'whatsapp_number': whatsappNumber,
      'specialization': specialization,
      'professional_title': professionalTitle,
      'expertise': expertise,
      'bio': bio,
      'linkedin_url': linkedinUrl,
      'github_or_portfolio_url': githubOrPortfolioUrl,
    };
  }
}

class CompanyMentorPaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const CompanyMentorPaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory CompanyMentorPaginationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyMentorPaginationModel(
      currentPage: _CompanyMentorJson.toInt(
        json['current_page'],
        fallback: 1,
      ),
      lastPage: _CompanyMentorJson.toInt(
        json['last_page'],
        fallback: 1,
      ),
      perPage: _CompanyMentorJson.toInt(
        json['per_page'],
        fallback: 20,
      ),
      total: _CompanyMentorJson.toInt(json['total']),
    );
  }
}

class CompanyMentorNominationsResponse {
  final List<CompanyMentorNominationModel> nominations;
  final CompanyMentorPaginationModel pagination;

  const CompanyMentorNominationsResponse({
    required this.nominations,
    required this.pagination,
  });

  factory CompanyMentorNominationsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = _CompanyMentorJson.map(json['data']);

    return CompanyMentorNominationsResponse(
      nominations: _CompanyMentorJson.mapList(data['nominations'])
          .map(CompanyMentorNominationModel.fromJson)
          .where((nomination) => nomination.id > 0)
          .toList(),
      pagination: CompanyMentorPaginationModel.fromJson(
        _CompanyMentorJson.map(data['pagination']),
      ),
    );
  }
}

class _CompanyMentorJson {
  static int toInt(
    dynamic value, {
    int fallback = 0,
  }) {
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static String? nullableString(dynamic value) {
    final text = value?.toString().trim();

    return text == null || text.isEmpty ? null : text;
  }

  static Map<String, dynamic> map(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> mapList(dynamic value) {
    if (value is! List) {
      return const <Map<String, dynamic>>[];
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static List<String> stringList(dynamic value) {
    if (value is! List) {
      return const <String>[];
    }

    return value.map((item) => item.toString()).toList();
  }
}