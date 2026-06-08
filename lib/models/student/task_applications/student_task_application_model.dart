class TaskApplicationsListResponse {
  final bool status;
  final String message;
  final List<StudentTaskApplicationModel> data;

  TaskApplicationsListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TaskApplicationsListResponse.fromJson(Map<String, dynamic> json) {
    return TaskApplicationsListResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List? ?? [])
          .map((item) => StudentTaskApplicationModel.fromJson(item))
          .toList(),
    );
  }
}

class AllMyTasksResponse {
  final bool status;
  final String message;
  final List<StudentTaskApplicationModel> all;
  final List<StudentTaskApplicationModel> applied;
  final List<StudentTaskApplicationModel> accepted;
  final List<StudentTaskApplicationModel> rejected;

  AllMyTasksResponse({
    required this.status,
    required this.message,
    required this.all,
    required this.applied,
    required this.accepted,
    required this.rejected,
  });

  factory AllMyTasksResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    final appliedList = (data['applied'] as List? ?? [])
        .map((item) => StudentTaskApplicationModel.fromJson(item))
        .toList();

    final acceptedList = (data['accepted'] as List? ?? [])
        .map((item) => StudentTaskApplicationModel.fromJson(item))
        .toList();

    final rejectedList = (data['rejected'] as List? ?? [])
        .map((item) => StudentTaskApplicationModel.fromJson(item))
        .toList();

    return AllMyTasksResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      applied: appliedList,
      accepted: acceptedList,
      rejected: rejectedList,
      all: [...appliedList, ...acceptedList, ...rejectedList],
    );
  }
}

class StudentTaskApplicationModel {
  final int? assignmentId;
  final int? applicationId;
  final int taskId;
  final String status;
  final String? coverLetter;
  final String? companyNotes;
  final String? matchScore;
  final String? appliedAt;
  final String? reviewedAt;
  final String? startedAt;
  final TaskApplicationReviewModel? application;
  final TaskApplicationTaskModel task;

  StudentTaskApplicationModel({
    this.assignmentId,
    this.applicationId,
    required this.taskId,
    required this.status,
    this.coverLetter,
    this.companyNotes,
    this.matchScore,
    this.appliedAt,
    this.reviewedAt,
    this.startedAt,
    this.application,
    required this.task,
  });

  factory StudentTaskApplicationModel.fromJson(Map<String, dynamic> json) {
    final application = json['application'] is Map<String, dynamic>
        ? TaskApplicationReviewModel.fromJson(json['application'])
        : null;

    return StudentTaskApplicationModel(
      assignmentId: json['assignment_id'] == null
          ? null
          : int.tryParse(json['assignment_id'].toString()),
      applicationId: json['application_id'] == null
          ? null
          : int.tryParse(json['application_id'].toString()),
      taskId:
          int.tryParse(json['task_id'].toString()) ??
          int.tryParse((json['task']?['id']).toString()) ??
          0,
      status: json['status']?.toString() ?? application?.status ?? 'pending',
      coverLetter: json['cover_letter']?.toString(),
      companyNotes:
          json['company_notes']?.toString() ?? application?.companyNotes,
      matchScore: json['match_score']?.toString(),
      appliedAt: json['applied_at']?.toString(),
      reviewedAt: json['reviewed_at']?.toString() ?? application?.reviewedAt,
      startedAt: json['started_at']?.toString(),
      application: application,
      task: TaskApplicationTaskModel.fromJson(json['task'] ?? {}),
    );
  }
}

class TaskApplicationReviewModel {
  final String status;
  final String? companyNotes;
  final String? reviewedAt;

  TaskApplicationReviewModel({
    required this.status,
    this.companyNotes,
    this.reviewedAt,
  });

  factory TaskApplicationReviewModel.fromJson(Map<String, dynamic> json) {
    return TaskApplicationReviewModel(
      status: json['status']?.toString() ?? '',
      companyNotes: json['company_notes']?.toString(),
      reviewedAt: json['reviewed_at']?.toString(),
    );
  }
}

class TaskApplicationTaskModel {
  final int id;
  final String title;
  final String description;
  final String difficultyLevel;
  final int durationDays;
  final String? deadline;
  final String status;
  final TaskApplicationCompanyModel company;
  final List<TaskApplicationSkillModel> skills;

  TaskApplicationTaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficultyLevel,
    required this.durationDays,
    required this.deadline,
    required this.status,
    required this.company,
    required this.skills,
  });

  factory TaskApplicationTaskModel.fromJson(Map<String, dynamic> json) {
    return TaskApplicationTaskModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      difficultyLevel: json['difficulty_level']?.toString() ?? '',
      durationDays: int.tryParse(json['duration_days'].toString()) ?? 0,
      deadline: json['deadline']?.toString(),
      status: json['status']?.toString() ?? '',
      company: TaskApplicationCompanyModel.fromJson(json['company'] ?? {}),
      skills: (json['skills'] as List? ?? [])
          .map((item) => TaskApplicationSkillModel.fromJson(item))
          .toList(),
    );
  }
}

class TaskApplicationCompanyModel {
  final int id;
  final String name;
  final String industry;

  TaskApplicationCompanyModel({
    required this.id,
    required this.name,
    required this.industry,
  });

  factory TaskApplicationCompanyModel.fromJson(Map<String, dynamic> json) {
    return TaskApplicationCompanyModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'شركة غير محددة',
      industry: json['industry']?.toString() ?? '',
    );
  }
}

class TaskApplicationSkillModel {
  final int id;
  final String name;

  TaskApplicationSkillModel({required this.id, required this.name});

  factory TaskApplicationSkillModel.fromJson(Map<String, dynamic> json) {
    return TaskApplicationSkillModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}
