class AssignedTaskResponse {
  final bool success;
  final String message;
  final StudentAssignedTaskModel data;

  AssignedTaskResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AssignedTaskResponse.fromJson(Map<String, dynamic> json) {
    return AssignedTaskResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: StudentAssignedTaskModel.fromJson(json['data'] ?? {}),
    );
  }
}

class StudentAssignedTaskModel {
  final int id;
  final int projectTaskId;
  final String title;
  final String description;
  final String status;
  final int estimatedHours;
  final String? submissionUrl;
  final String? githubBranchOrLink;
  final String? supervisorFeedback;
  final AssignedStudentModel assignedStudent;
  final String? startedAt;
  final String? submittedAt;
  final String? reviewedAt;
  final String? completedAt;
  final int orderIndex;

  StudentAssignedTaskModel({
    required this.id,
    required this.projectTaskId,
    required this.title,
    required this.description,
    required this.status,
    required this.estimatedHours,
    this.submissionUrl,
    this.githubBranchOrLink,
    this.supervisorFeedback,
    required this.assignedStudent,
    this.startedAt,
    this.submittedAt,
    this.reviewedAt,
    this.completedAt,
    required this.orderIndex,
  });

  factory StudentAssignedTaskModel.fromJson(Map<String, dynamic> json) {
    return StudentAssignedTaskModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      projectTaskId: int.tryParse(json['project_task_id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      estimatedHours: int.tryParse(json['estimated_hours'].toString()) ?? 0,
      submissionUrl: json['submission_url']?.toString(),
      githubBranchOrLink: json['github_branch_or_link']?.toString(),
      supervisorFeedback: json['supervisor_feedback']?.toString(),
      assignedStudent: AssignedStudentModel.fromJson(
        json['assigned_student'] ?? {},
      ),
      startedAt: json['started_at']?.toString(),
      submittedAt: json['submitted_at']?.toString(),
      reviewedAt: json['reviewed_at']?.toString(),
      completedAt: json['completed_at']?.toString(),
      orderIndex: int.tryParse(json['order_index'].toString()) ?? 0,
    );
  }

  StudentAssignedTaskModel copyWith({
    String? status,
    String? startedAt,
    String? submittedAt,
    String? completedAt,
  }) {
    return StudentAssignedTaskModel(
      id: id,
      projectTaskId: projectTaskId,
      title: title,
      description: description,
      status: status ?? this.status,
      estimatedHours: estimatedHours,
      submissionUrl: submissionUrl,
      githubBranchOrLink: githubBranchOrLink,
      supervisorFeedback: supervisorFeedback,
      assignedStudent: assignedStudent,
      startedAt: startedAt ?? this.startedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt,
      completedAt: completedAt ?? this.completedAt,
      orderIndex: orderIndex,
    );
  }
}

class AssignedStudentModel {
  final int id;
  final String name;
  final String email;

  AssignedStudentModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory AssignedStudentModel.fromJson(Map<String, dynamic> json) {
    return AssignedStudentModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}
