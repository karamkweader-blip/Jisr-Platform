class StudentOpportunityApplicationsResponse {
  final bool success;
  final String message;
  final List<StudentOpportunityApplicationModel> data;

  StudentOpportunityApplicationsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StudentOpportunityApplicationsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentOpportunityApplicationsResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List? ?? [])
          .map((item) => StudentOpportunityApplicationModel.fromJson(item))
          .toList(),
    );
  }
}

class StudentOpportunityApplicationDetailsResponse {
  final bool success;
  final String message;
  final StudentOpportunityApplicationModel data;

  StudentOpportunityApplicationDetailsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StudentOpportunityApplicationDetailsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentOpportunityApplicationDetailsResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: StudentOpportunityApplicationModel.fromJson(json['data'] ?? {}),
    );
  }
}

class StudentOpportunityApplicationModel {
  final int id;
  final StudentAppliedOpportunityModel opportunity;
  final String? cv;
  final String coverLetter;
  final String status;
  final String displayStatus;
  final String matchScore;
  final List<String> matchReasons;
  final dynamic interview;
  final String? reviewedAt;
  final String? reviewerNotes;
  final String? appliedAt;
  final String? createdAt;

  StudentOpportunityApplicationModel({
    required this.id,
    required this.opportunity,
    required this.cv,
    required this.coverLetter,
    required this.status,
    required this.displayStatus,
    required this.matchScore,
    required this.matchReasons,
    required this.interview,
    required this.reviewedAt,
    required this.reviewerNotes,
    required this.appliedAt,
    required this.createdAt,
  });

  factory StudentOpportunityApplicationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentOpportunityApplicationModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      opportunity: StudentAppliedOpportunityModel.fromJson(
        json['opportunity'] ?? {},
      ),
      cv: json['cv']?.toString(),
      coverLetter: json['cover_letter']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      displayStatus: json['display_status']?.toString() ?? '',
      matchScore: json['match_score']?.toString() ?? '',
      matchReasons: (json['match_reasons'] as List? ?? [])
          .map((item) => item.toString())
          .toList(),
      interview: json['interview'],
      reviewedAt: json['reviewed_at']?.toString(),
      reviewerNotes: json['reviewer_notes']?.toString(),
      appliedAt: json['applied_at']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class StudentAppliedOpportunityModel {
  final int id;
  final String title;
  final String type;
  final String status;
  final String? deadline;
  final StudentAppliedOpportunityCompanyModel company;

  StudentAppliedOpportunityModel({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.deadline,
    required this.company,
  });

  factory StudentAppliedOpportunityModel.fromJson(Map<String, dynamic> json) {
    return StudentAppliedOpportunityModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      deadline: json['deadline']?.toString(),
      company: StudentAppliedOpportunityCompanyModel.fromJson(
        json['company'] ?? {},
      ),
    );
  }
}

class StudentAppliedOpportunityCompanyModel {
  final int id;
  final String name;
  final String industry;

  StudentAppliedOpportunityCompanyModel({
    required this.id,
    required this.name,
    required this.industry,
  });

  factory StudentAppliedOpportunityCompanyModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawName = json['name']?.toString();
    final industry = json['industry']?.toString() ?? '';

    return StudentAppliedOpportunityCompanyModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: rawName == null || rawName.trim().isEmpty
          ? 'شركة غير محددة'
          : rawName,
      industry: industry,
    );
  }
}
