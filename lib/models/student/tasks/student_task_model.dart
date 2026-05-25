class StudentTasksResponse {
  final List<StudentTaskModel> data;

  StudentTasksResponse({required this.data});

  factory StudentTasksResponse.fromJson(Map<String, dynamic> json) {
    return StudentTasksResponse(
      data: (json['data'] as List? ?? [])
          .map((item) => StudentTaskModel.fromJson(item))
          .toList(),
    );
  }
}

class StudentTaskDetailsResponse {
  final StudentTaskDetailsModel data;

  StudentTaskDetailsResponse({required this.data});

  factory StudentTaskDetailsResponse.fromJson(Map<String, dynamic> json) {
    return StudentTaskDetailsResponse(
      data: StudentTaskDetailsModel.fromJson(json['data'] ?? {}),
    );
  }
}

class StudentTaskModel {
  final int id;
  final TaskCompanyModel company;
  final String title;
  final String difficultyLevel;
  final int durationDays;
  final String? deadline;
  final int? matchScore;

  StudentTaskModel({
    required this.id,
    required this.company,
    required this.title,
    required this.difficultyLevel,
    required this.durationDays,
    required this.deadline,
    this.matchScore,
  });

  factory StudentTaskModel.fromJson(Map<String, dynamic> json) {
    return StudentTaskModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      company: TaskCompanyModel.fromJson(json['company'] ?? {}),
      title: json['title']?.toString() ?? '',
      difficultyLevel: json['difficulty_level']?.toString() ?? '',
      durationDays: int.tryParse(json['duration_days'].toString()) ?? 0,
      deadline: json['deadline']?.toString(),
      matchScore: json['match_score'] == null
          ? null
          : int.tryParse(json['match_score'].toString()),
    );
  }
}

class StudentTaskDetailsModel {
  final int id;
  final TaskCompanyModel company;
  final String title;
  final String description;
  final String difficultyLevel;
  final int durationDays;
  final String? deadline;
  final List<String> deliverables;
  final List<String> acceptanceCriteria;
  final String submissionType;
  final String status;
  final List<TaskSkillModel> skills;
  final String? publishedAt;

  StudentTaskDetailsModel({
    required this.id,
    required this.company,
    required this.title,
    required this.description,
    required this.difficultyLevel,
    required this.durationDays,
    required this.deadline,
    required this.deliverables,
    required this.acceptanceCriteria,
    required this.submissionType,
    required this.status,
    required this.skills,
    required this.publishedAt,
  });

  factory StudentTaskDetailsModel.fromJson(Map<String, dynamic> json) {
    return StudentTaskDetailsModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      company: TaskCompanyModel.fromJson(json['company'] ?? {}),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      difficultyLevel: json['difficulty_level']?.toString() ?? '',
      durationDays: int.tryParse(json['duration_days'].toString()) ?? 0,
      deadline: json['deadline']?.toString(),
      deliverables: (json['deliverables'] as List? ?? [])
          .map((item) => item.toString())
          .toList(),
      acceptanceCriteria: (json['acceptance_criteria'] as List? ?? [])
          .map((item) => item.toString())
          .toList(),
      submissionType: json['submission_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      skills: (json['skills'] as List? ?? [])
          .map((item) => TaskSkillModel.fromJson(item))
          .toList(),
      publishedAt: json['published_at']?.toString(),
    );
  }
}

class TaskCompanyModel {
  final int id;
  final String name;
  final String industry;

  TaskCompanyModel({
    required this.id,
    required this.name,
    required this.industry,
  });

  factory TaskCompanyModel.fromJson(Map<String, dynamic> json) {
    return TaskCompanyModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'شركة غير محددة',
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

  TaskSkillModel({
    required this.id,
    required this.name,
    required this.category,
    required this.requiredLevel,
    required this.weight,
    required this.mandatory,
  });

  factory TaskSkillModel.fromJson(Map<String, dynamic> json) {
    return TaskSkillModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      requiredLevel: int.tryParse(json['required_level'].toString()) ?? 0,
      weight: int.tryParse(json['weight'].toString()) ?? 0,
      mandatory: json['mandatory'] == true,
    );
  }
}
