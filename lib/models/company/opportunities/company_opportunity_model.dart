class CompanyOpportunityModel {
  final int id;
  final OpportunityCompany company;
  final String title;
  final String description;
  final String type;
  final String location;
  final double? salaryMin;
  final double? salaryMax;
  final String status;
  final DateTime? deadline;
  final DateTime? postedAt;
  final int applicationsCount;
  final List<CompanyOpportunitySkill> skills;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CompanyOpportunityModel({
    required this.id,
    required this.company,
    required this.title,
    required this.description,
    required this.type,
    required this.location,
    required this.salaryMin,
    required this.salaryMax,
    required this.status,
    required this.deadline,
    required this.postedAt,
    required this.applicationsCount,
    required this.skills,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyOpportunityModel.fromJson(Map<String, dynamic> json) {
    return CompanyOpportunityModel(
      id: opportunityInt(json['id_Resource'] ?? json['id']),
      company: OpportunityCompany.fromJson(opportunityMap(json['company'])),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      salaryMin: opportunityDoubleOrNull(json['salary_min']),
      salaryMax: opportunityDoubleOrNull(json['salary_max']),
      status: json['status']?.toString() ?? '',
      deadline: opportunityDate(json['deadline']),
      postedAt: opportunityDate(json['posted_at']),
      applicationsCount: opportunityInt(json['applications_count']),
      skills: opportunityList(json['skills'])
          .map((item) => CompanyOpportunitySkill.fromJson(opportunityMap(item)))
          .where((skill) => skill.id > 0)
          .toList(),
      createdAt: opportunityDate(json['created_at']),
      updatedAt: opportunityDate(json['updated_at']),
    );
  }

  bool get isDraft => status == 'draft';
  bool get isPublished => status == 'published';
  bool get canEdit => isDraft;
  bool get canPublish => isDraft;
  bool get canClose => status == 'published';
  bool get canCancel => status == 'draft' || status == 'published';

  Map<String, dynamic> toJson() {
    return {
      'id_Resource': id,
      'company': company.toJson(),
      'title': title,
      'description': description,
      'type': type,
      'location': location,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'status': status,
      'deadline': deadline?.toIso8601String(),
      'posted_at': postedAt?.toIso8601String(),
      'applications_count': applicationsCount,
      'skills': skills.map((skill) => skill.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class OpportunityCompany {
  final int id;
  final String name;

  const OpportunityCompany({required this.id, required this.name});

  factory OpportunityCompany.fromJson(Map<String, dynamic> json) {
    return OpportunityCompany(
      id: opportunityInt(json['id_Company'] ?? json['id']),
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id_Company': id, 'name': name};
}

class CompanyOpportunitySkill {
  final int id;
  final String name;
  final int requiredLevel;
  final bool mandatory;
  final double weight;

  const CompanyOpportunitySkill({
    required this.id,
    required this.name,
    required this.requiredLevel,
    required this.mandatory,
    required this.weight,
  });

  factory CompanyOpportunitySkill.fromJson(Map<String, dynamic> json) {
    return CompanyOpportunitySkill(
      id: opportunityInt(json['id_Skill'] ?? json['id'] ?? json['skill_id']),
      name: json['name']?.toString() ?? '',
      requiredLevel: opportunityInt(json['required_level']),
      mandatory: opportunityBool(json['mandatory']),
      weight: opportunityDoubleOrNull(json['weight']) ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_Skill': id,
      'name': name,
      'required_level': requiredLevel,
      'mandatory': mandatory,
      'weight': weight,
    };
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'skill_id': id,
      'required_level': requiredLevel,
      'mandatory': mandatory,
      'weight': weight,
    };
  }
}

class SaveCompanyOpportunityRequest {
  final String title;
  final String description;
  final String type;
  final String location;
  final double salaryMin;
  final double salaryMax;
  final String deadline;
  final List<CompanyOpportunitySkill> skills;

  const SaveCompanyOpportunityRequest({
    required this.title,
    required this.description,
    required this.type,
    required this.location,
    required this.salaryMin,
    required this.salaryMax,
    required this.deadline,
    required this.skills,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'location': location,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'deadline': deadline,
      'skills': skills.map((skill) => skill.toRequestJson()).toList(),
    };
  }
}

int opportunityInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double? opportunityDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool opportunityBool(dynamic value) {
  if (value is bool) return value;
  return value == 1 || value?.toString().toLowerCase() == 'true';
}

DateTime? opportunityDate(dynamic value) {
  if (value == null || value.toString().trim().isEmpty) return null;
  return DateTime.tryParse(value.toString());
}

Map<String, dynamic> opportunityMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<dynamic> opportunityList(dynamic value) {
  return value is List ? value : <dynamic>[];
}
