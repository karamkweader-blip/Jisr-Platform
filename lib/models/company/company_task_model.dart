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
      id: json['id'] as int? ?? 0,
      company: TaskCompanyModel.fromJson(
        json['company'] as Map<String, dynamic>? ?? {},
      ),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      difficultyLevel: json['difficulty_level'] as String? ?? '',
      durationDays: json['duration_days'] as int? ?? 0,
      deadline: DateTime.tryParse(json['deadline'] as String? ?? ''),
      maxApplicants: json['max_applicants'] as int? ?? 0,
      maxAcceptedStudents: json['max_accepted_students'] as int? ?? 0,
      deliverables: (json['deliverables'] as List? ?? [])
          .map((item) => item.toString())
          .toList(),
      acceptanceCriteria: (json['acceptance_criteria'] as List? ?? [])
          .map((item) => item.toString())
          .toList(),
      submissionType: json['submission_type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? ''),
      skills: (json['skills'] as List? ?? [])
          .map((item) => TaskSkillModel.fromJson(
                item as Map<String, dynamic>? ?? {},
              ))
          .toList(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
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
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      industry: json['industry'] as String? ?? '',
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
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      requiredLevel: json['required_level'] as int? ?? 1,
      weight: json['weight'] as int? ?? 0,
      mandatory: json['mandatory'] as bool? ?? false,
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

  factory AvailableSkillModel.fromJson(Map<String, dynamic> json) {
    return AvailableSkillModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
    );
  }
}

class SelectedTaskSkill {
  final AvailableSkillModel skill;
  final int requiredLevel;
  final bool mandatory;

  const SelectedTaskSkill({
    required this.skill,
    required this.requiredLevel,
    required this.mandatory,
  });

  Map<String, dynamic> toJsonWithWeight(int weight) {
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
      'skills': _skillsToJson(),
    };
  }

  List<Map<String, dynamic>> _skillsToJson() {
    if (skills.isEmpty) return [];

    final baseWeight = 100 ~/ skills.length;
    final remaining = 100 - (baseWeight * skills.length);

    return List.generate(skills.length, (index) {
      final weight = index == 0 ? baseWeight + remaining : baseWeight;
      return skills[index].toJsonWithWeight(weight);
    });
  }
}