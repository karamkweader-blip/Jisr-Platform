class CompanyTaskModel {
  final int id;
  final TaskCompanyModel company;
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
  final List<TaskSkillModel> skills;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CompanyTaskModel({
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

  factory CompanyTaskModel.fromJson(Map<String, dynamic> json) {
    return CompanyTaskModel(
      id: _parseInt(json['id']),
      company: TaskCompanyModel.fromJson(
        json['company'] is Map<String, dynamic>
            ? json['company'] as Map<String, dynamic>
            : <String, dynamic>{},
      ),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      difficultyLevel: json['difficulty_level']?.toString() ?? '',
      durationDays: _parseInt(json['duration_days']),
      deadline: _parseDateTime(json['deadline']),
      maxApplicants: _parseInt(json['max_applicants']),
      maxAcceptedStudents: _parseInt(
        json['max_accepted_students'],
      ),
      deliverables: (json['deliverables'] as List? ?? [])
          .map((item) => item.toString())
          .toList(),
      acceptanceCriteria:
          (json['acceptance_criteria'] as List? ?? [])
              .map((item) => item.toString())
              .toList(),
      submissionType: json['submission_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      publishedAt: _parseDateTime(json['published_at']),
      skills: (json['skills'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(TaskSkillModel.fromJson)
          .toList(),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  bool get isDraft => status == 'draft';

  bool get isPublished => status == 'published';
}

class TaskCompanyModel {
  final int id;
  final String name;
  final String industry;

  const TaskCompanyModel({
    required this.id,
    required this.name,
    required this.industry,
  });

  factory TaskCompanyModel.fromJson(Map<String, dynamic> json) {
    return TaskCompanyModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      industry: json['industry']?.toString() ?? '',
    );
  }
}

class TaskSkillModel {
  final int id;
  final String name;
  final String category;
  final int requiredLevel;
  final int weight;
  final bool mandatory;

  const TaskSkillModel({
    required this.id,
    required this.name,
    required this.category,
    required this.requiredLevel,
    required this.weight,
    required this.mandatory,
  });

  factory TaskSkillModel.fromJson(Map<String, dynamic> json) {
    return TaskSkillModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      requiredLevel: _parseInt(
        json['required_level'],
        fallback: 1,
      ),
      weight: _parseInt(json['weight']),
      mandatory: _parseBool(json['mandatory']),
    );
  }
}

class AvailableSkillModel {
  final int id;
  final String name;
  final String category;

  const AvailableSkillModel({
    required this.id,
    required this.name,
    required this.category,
  });

  factory AvailableSkillModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AvailableSkillModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
    );
  }
}

class SelectedTaskSkill {
  final AvailableSkillModel skill;
  final int requiredLevel;
  final int weight;
  final bool mandatory;

  const SelectedTaskSkill({
    required this.skill,
    required this.requiredLevel,
    required this.weight,
    required this.mandatory,
  });

  Map<String, dynamic> toJson() {
    return {
      'skill_id': skill.id,
      'required_level': requiredLevel,
      'weight': weight,
      'mandatory': mandatory,
    };
  }
}

class CreateCompanyTaskRequest {
  final String title;
  final String description;
  final String difficultyLevel;
  final int durationDays;
  final String deadline;
  final int maxApplicants;
  final int maxAcceptedStudents;
  final List<String> deliverables;
  final List<String> acceptanceCriteria;
  final String submissionType;
  final List<SelectedTaskSkill> skills;

  const CreateCompanyTaskRequest({
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
    required this.skills,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'difficulty_level': difficultyLevel,
      'duration_days': durationDays,
      'deadline': deadline,
      'max_applicants': maxApplicants,
      'max_accepted_students': maxAcceptedStudents,
      'deliverables': deliverables,
      'acceptance_criteria': acceptanceCriteria,
      'submission_type': submissionType,
      'skills': skills.map((skill) => skill.toJson()).toList(),
    };
  }
}

class UpdateCompanyTaskRequest {
  final String? title;
  final String? description;
  final String? difficultyLevel;
  final int? durationDays;
  final String? deadline;
  final int? maxApplicants;
  final int? maxAcceptedStudents;
  final List<String>? deliverables;
  final List<String>? acceptanceCriteria;
  final String? submissionType;
  final List<SelectedTaskSkill>? skills;

  const UpdateCompanyTaskRequest({
    this.title,
    this.description,
    this.difficultyLevel,
    this.durationDays,
    this.deadline,
    this.maxApplicants,
    this.maxAcceptedStudents,
    this.deliverables,
    this.acceptanceCriteria,
    this.submissionType,
    this.skills,
  });

  bool get isEmpty => toJson().isEmpty;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (title != null) {
      data['title'] = title;
    }

    if (description != null) {
      data['description'] = description;
    }

    if (difficultyLevel != null) {
      data['difficulty_level'] = difficultyLevel;
    }

    if (durationDays != null) {
      data['duration_days'] = durationDays;
    }

    if (deadline != null) {
      data['deadline'] = deadline;
    }

    if (maxApplicants != null) {
      data['max_applicants'] = maxApplicants;
    }

    if (maxAcceptedStudents != null) {
      data['max_accepted_students'] = maxAcceptedStudents;
    }

    if (deliverables != null) {
      data['deliverables'] = deliverables;
    }

    if (acceptanceCriteria != null) {
      data['acceptance_criteria'] = acceptanceCriteria;
    }

    if (submissionType != null) {
      data['submission_type'] = submissionType;
    }

    if (skills != null) {
      data['skills'] = skills!.map((skill) => skill.toJson()).toList();
    }

    return data;
  }
}

int _parseInt(
  dynamic value, {
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

bool _parseBool(dynamic value) {
  if (value is bool) {
    return value;
  }

  if (value is int) {
    return value == 1;
  }

  final normalized = value?.toString().toLowerCase();

  return normalized == 'true' || normalized == '1';
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) {
    return null;
  }

  return DateTime.tryParse(value.toString());
}