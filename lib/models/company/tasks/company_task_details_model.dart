class CompanyTaskDetailsModel {
  final int id;
  final CompanyTaskDetailsCompanyModel company;
  final String title;
  final String description;
  final String difficultyLevel;
  final int durationDays;
  final DateTime? deadline;
  final int maxApplicants;
  final int maxAcceptedStudents;
  final List<String> deliverables;
  final List<String> acceptanceCriteria;
  final String submissionType;
  final String status;
  final DateTime? publishedAt;
  final List<CompanyTaskDetailsSkillModel> skills;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CompanyTaskDetailsModel({
    required this.id,
    required this.company,
    required this.title,
    required this.description,
    required this.difficultyLevel,
    required this.durationDays,
    required this.deadline,
    required this.maxApplicants,
    required this.maxAcceptedStudents,
    required this.deliverables,
    required this.acceptanceCriteria,
    required this.submissionType,
    required this.status,
    required this.publishedAt,
    required this.skills,
    required this.createdAt,
    required this.updatedAt,
  });

 bool get isDraft => status == 'draft';

bool get isPublished => status == 'published';

bool get isInProgress => status == 'in_progress';

bool get isClosed => status == 'closed';

bool get isCancelled => status == 'cancelled';

bool get canEdit {
  return isDraft || isPublished;
}

bool get canCancel {
  return isDraft || isPublished;
}

bool get hasDeadline => deadline != null;

  factory CompanyTaskDetailsModel.fromJson(Map<String, dynamic> json) {
    return CompanyTaskDetailsModel(
      id: _toInt(json['id']),
      company: CompanyTaskDetailsCompanyModel.fromJson(
        json['company'] as Map<String, dynamic>? ?? {},
      ),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      difficultyLevel: json['difficulty_level']?.toString() ?? '',
      durationDays: _toInt(json['duration_days']),
      deadline: _toDate(json['deadline']),
      maxApplicants: _toInt(json['max_applicants']),
      maxAcceptedStudents: _toInt(json['max_accepted_students']),
      deliverables: _toStringList(json['deliverables']),
      acceptanceCriteria: _toStringList(json['acceptance_criteria']),
      submissionType: json['submission_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      publishedAt: _toDate(json['published_at']),
      skills: (json['skills'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(CompanyTaskDetailsSkillModel.fromJson)
          .toList(),
      createdAt: _toDate(json['created_at']),
      updatedAt: _toDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company': company.toJson(),
      'title': title,
      'description': description,
      'difficulty_level': difficultyLevel,
      'duration_days': durationDays,
      'deadline': deadline?.toIso8601String(),
      'max_applicants': maxApplicants,
      'max_accepted_students': maxAcceptedStudents,
      'deliverables': deliverables,
      'acceptance_criteria': acceptanceCriteria,
      'submission_type': submissionType,
      'status': status,
      'published_at': publishedAt?.toIso8601String(),
      'skills': skills.map((skill) => skill.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static List<String> _toStringList(dynamic value) {
    if (value is! List) return [];
    return value.map((item) => item.toString()).toList();
  }
}

class CompanyTaskDetailsCompanyModel {
  final int id;
  final String? name;
  final String industry;

  const CompanyTaskDetailsCompanyModel({
    required this.id,
    required this.name,
    required this.industry,
  });

  factory CompanyTaskDetailsCompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyTaskDetailsCompanyModel(
      id: CompanyTaskDetailsModel._toInt(json['id']),
      name: json['name']?.toString(),
      industry: json['industry']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'industry': industry,
    };
  }
}

class CompanyTaskDetailsSkillModel {
  final int id;
  final String name;
  final String category;
  final int requiredLevel;
  final double weight;
  final bool mandatory;

  const CompanyTaskDetailsSkillModel({
    required this.id,
    required this.name,
    required this.category,
    required this.requiredLevel,
    required this.weight,
    required this.mandatory,
  });

  factory CompanyTaskDetailsSkillModel.fromJson(Map<String, dynamic> json) {
    return CompanyTaskDetailsSkillModel(
      id: CompanyTaskDetailsModel._toInt(json['id']),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      requiredLevel: CompanyTaskDetailsModel._toInt(json['required_level']),
      weight: _toDouble(json['weight']),
      mandatory: json['mandatory'] == true || json['mandatory'] == 1,
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

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}