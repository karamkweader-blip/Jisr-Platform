class ProjectAssignmentTasksResponse {
  final bool success;
  final String message;
  final List<StudentAssignedTaskModel> tasks;
  final ProjectAssignmentTasksPagination pagination;

  const ProjectAssignmentTasksResponse({
    required this.success,
    required this.message,
    required this.tasks,
    required this.pagination,
  });

  factory ProjectAssignmentTasksResponse.fromJson(Map<String, dynamic> json) {
    final data = _ProjectEvaluationJson.map(json['data']);
    return ProjectAssignmentTasksResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      tasks: _ProjectEvaluationJson.list(data['tasks'])
          .map((item) => StudentAssignedTaskModel.fromJson(item))
          .toList(),
      pagination: ProjectAssignmentTasksPagination.fromJson(
        _ProjectEvaluationJson.map(data['pagination']),
      ),
    );
  }
}

class ProjectAssignmentTasksPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const ProjectAssignmentTasksPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory ProjectAssignmentTasksPagination.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProjectAssignmentTasksPagination(
      currentPage: _ProjectEvaluationJson.toInt(json['current_page']),
      lastPage: _ProjectEvaluationJson.toInt(json['last_page']),
      perPage: _ProjectEvaluationJson.toInt(json['per_page']),
      total: _ProjectEvaluationJson.toInt(json['total']),
    );
  }
}

class StudentEvaluationAppealsResponse {
  final bool success;
  final String message;
  final List<ProjectEvaluationAppealModel> appeals;
  final ProjectAssignmentTasksPagination pagination;

  const StudentEvaluationAppealsResponse({
    required this.success,
    required this.message,
    required this.appeals,
    required this.pagination,
  });

  factory StudentEvaluationAppealsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = _ProjectEvaluationJson.map(json['data']);
    return StudentEvaluationAppealsResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      appeals: _ProjectEvaluationJson.list(data['appeals'])
          .map((item) => ProjectEvaluationAppealModel.fromJson(item))
          .toList(),
      pagination: ProjectAssignmentTasksPagination.fromJson(
        _ProjectEvaluationJson.map(data['pagination']),
      ),
    );
  }
}

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
  final String source;
  final int id;
  final int projectAssignmentId;
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
  final ProjectTaskAssignmentModel assignment;

  StudentAssignedTaskModel({
    required this.source,
    required this.id,
    required this.projectAssignmentId,
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
    required this.assignment,
  });

  factory StudentAssignedTaskModel.fromJson(Map<String, dynamic> json) {
    return StudentAssignedTaskModel(
      source: json['source']?.toString() ?? '',
      id: int.tryParse(json['id'].toString()) ?? 0,
      projectAssignmentId:
          int.tryParse(json['project_assignment_id'].toString()) ?? 0,
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
      assignment: ProjectTaskAssignmentModel.fromJson(
        _ProjectEvaluationJson.map(json['assignment']),
      ),
    );
  }

  StudentAssignedTaskModel copyWith({
    String? status,
    String? startedAt,
    String? submittedAt,
    String? completedAt,
  }) {
    return StudentAssignedTaskModel(
      source: source,
      id: id,
      projectAssignmentId: projectAssignmentId,
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
      assignment: assignment,
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

class ProjectTaskAssignmentModel {
  final int id;
  final String status;
  final int progressPercentage;
  final String? assignedAt;
  final String? submittedAt;
  final ProjectTaskTemplateModel projectTemplate;
  final ProjectTaskSupervisorModel supervisor;

  const ProjectTaskAssignmentModel({
    required this.id,
    required this.status,
    required this.progressPercentage,
    required this.assignedAt,
    required this.submittedAt,
    required this.projectTemplate,
    required this.supervisor,
  });

  factory ProjectTaskAssignmentModel.fromJson(Map<String, dynamic> json) {
    return ProjectTaskAssignmentModel(
      id: _ProjectEvaluationJson.toInt(json['id']),
      status: json['status']?.toString() ?? '',
      progressPercentage: _ProjectEvaluationJson.toInt(
        json['progress_percentage'],
      ),
      assignedAt: _ProjectEvaluationJson.nullableString(json['assigned_at']),
      submittedAt: _ProjectEvaluationJson.nullableString(
        json['submitted_at'],
      ),
      projectTemplate: ProjectTaskTemplateModel.fromJson(
        _ProjectEvaluationJson.map(json['project_template']),
      ),
      supervisor: ProjectTaskSupervisorModel.fromJson(
        _ProjectEvaluationJson.map(json['supervisor']),
      ),
    );
  }
}

class ProjectTaskTemplateModel {
  final int id;
  final String title;
  final String level;

  const ProjectTaskTemplateModel({
    required this.id,
    required this.title,
    required this.level,
  });

  factory ProjectTaskTemplateModel.fromJson(Map<String, dynamic> json) {
    return ProjectTaskTemplateModel(
      id: _ProjectEvaluationJson.toInt(json['id']),
      title: json['title']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
    );
  }
}

class ProjectTaskSupervisorModel {
  final int id;
  final String name;
  final String email;

  const ProjectTaskSupervisorModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory ProjectTaskSupervisorModel.fromJson(Map<String, dynamic> json) {
    return ProjectTaskSupervisorModel(
      id: _ProjectEvaluationJson.toInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

class StudentProjectEvaluationResponse {
  final int projectAssignmentId;
  final bool hasEvaluation;
  final ProjectEvaluationModel? evaluation;
  final AppealWindowModel? appealWindow;
  final bool canAppeal;
  final List<ProjectEvaluationAppealModel> appeals;

  const StudentProjectEvaluationResponse({
    required this.projectAssignmentId,
    required this.hasEvaluation,
    required this.evaluation,
    required this.appealWindow,
    required this.canAppeal,
    required this.appeals,
  });

  factory StudentProjectEvaluationResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = _ProjectEvaluationJson.map(json['data'] ?? json);
    final evaluationJson = data['evaluation'];
    final appealWindowJson = data['appeal_window'];

    return StudentProjectEvaluationResponse(
      projectAssignmentId: _ProjectEvaluationJson.toInt(
        data['project_assignment_id'],
      ),
      hasEvaluation: data['has_evaluation'] == true,
      evaluation: evaluationJson is Map
          ? ProjectEvaluationModel.fromJson(
              Map<String, dynamic>.from(evaluationJson),
            )
          : null,
      appealWindow: appealWindowJson is Map
          ? AppealWindowModel.fromJson(
              Map<String, dynamic>.from(appealWindowJson),
            )
          : null,
      canAppeal: data['can_appeal'] == true,
      appeals: _ProjectEvaluationJson.list(data['appeals'])
          .map((item) => ProjectEvaluationAppealModel.fromJson(item))
          .toList(),
    );
  }
}

class ProjectEvaluationModel {
  final int id;
  final int projectAssignmentId;
  final ProjectEvaluationPersonModel? student;
  final ProjectEvaluationPersonModel? supervisor;
  final String totalScore;
  final String finalGrade;
  final String status;
  final String? generalComment;
  final Map<String, dynamic>? summaryMetrics;
  final String? evaluatedAt;
  final String? appealStartedAt;
  final String? appealDeadlineAt;
  final ProjectEvaluationAssignmentModel? assignment;
  final List<ProjectEvaluationItemModel> items;

  const ProjectEvaluationModel({
    required this.id,
    required this.projectAssignmentId,
    required this.student,
    required this.supervisor,
    required this.totalScore,
    required this.finalGrade,
    required this.status,
    required this.generalComment,
    required this.summaryMetrics,
    required this.evaluatedAt,
    required this.appealStartedAt,
    required this.appealDeadlineAt,
    required this.assignment,
    required this.items,
  });

  factory ProjectEvaluationModel.fromJson(Map<String, dynamic> json) {
    final studentJson = json['student'];
    final supervisorJson = json['supervisor'];
    final assignmentJson = json['assignment'];
    final summaryMetricsJson = json['summary_metrics'];

    return ProjectEvaluationModel(
      id: _ProjectEvaluationJson.toInt(json['id']),
      projectAssignmentId: _ProjectEvaluationJson.toInt(
        json['project_assignment_id'],
      ),
      student: studentJson is Map
          ? ProjectEvaluationPersonModel.fromJson(
              Map<String, dynamic>.from(studentJson),
            )
          : null,
      supervisor: supervisorJson is Map
          ? ProjectEvaluationPersonModel.fromJson(
              Map<String, dynamic>.from(supervisorJson),
            )
          : null,
      totalScore: json['total_score']?.toString() ?? '',
      finalGrade: json['final_grade']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      generalComment: _ProjectEvaluationJson.nullableString(
        json['general_comment'],
      ),
      summaryMetrics: summaryMetricsJson is Map
          ? Map<String, dynamic>.from(summaryMetricsJson)
          : null,
      evaluatedAt: _ProjectEvaluationJson.nullableString(json['evaluated_at']),
      appealStartedAt: _ProjectEvaluationJson.nullableString(
        json['appeal_started_at'],
      ),
      appealDeadlineAt: _ProjectEvaluationJson.nullableString(
        json['appeal_deadline_at'],
      ),
      assignment: assignmentJson is Map
          ? ProjectEvaluationAssignmentModel.fromJson(
              Map<String, dynamic>.from(assignmentJson),
            )
          : null,
      items: _ProjectEvaluationJson.list(json['items'])
          .map((item) => ProjectEvaluationItemModel.fromJson(item))
          .toList(),
    );
  }
}

class ProjectEvaluationPersonModel {
  final int id;
  final String name;
  final String email;

  const ProjectEvaluationPersonModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory ProjectEvaluationPersonModel.fromJson(Map<String, dynamic> json) {
    return ProjectEvaluationPersonModel(
      id: _ProjectEvaluationJson.toInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

class ProjectEvaluationAssignmentModel {
  final int id;
  final String status;
  final int progressPercentage;
  final String projectTitle;
  final String projectLevel;

  const ProjectEvaluationAssignmentModel({
    required this.id,
    required this.status,
    required this.progressPercentage,
    required this.projectTitle,
    required this.projectLevel,
  });

  factory ProjectEvaluationAssignmentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final template = _ProjectEvaluationJson.map(json['project_template']);
    return ProjectEvaluationAssignmentModel(
      id: _ProjectEvaluationJson.toInt(json['id']),
      status: json['status']?.toString() ?? '',
      progressPercentage: _ProjectEvaluationJson.toInt(
        json['progress_percentage'],
      ),
      projectTitle: template['title']?.toString() ?? '',
      projectLevel: template['level']?.toString() ?? '',
    );
  }
}

class ProjectEvaluationItemModel {
  final int id;
  final String score;
  final String? comment;
  final String? evidence;
  final List<String> evidenceImages;
  final ProjectEvaluationCriteriaModel criteria;

  const ProjectEvaluationItemModel({
    required this.id,
    required this.score,
    required this.comment,
    required this.evidence,
    required this.evidenceImages,
    required this.criteria,
  });

  factory ProjectEvaluationItemModel.fromJson(Map<String, dynamic> json) {
    return ProjectEvaluationItemModel(
      id: _ProjectEvaluationJson.toInt(json['id']),
      score: json['score']?.toString() ?? '',
      comment: _ProjectEvaluationJson.nullableString(json['comment']),
      evidence: _ProjectEvaluationJson.nullableString(json['evidence']),
      evidenceImages: (json['evidence_images'] as List? ?? const [])
          .map((item) => item.toString())
          .toList(),
      criteria: ProjectEvaluationCriteriaModel.fromJson(
        _ProjectEvaluationJson.map(json['criteria']),
      ),
    );
  }
}

class ProjectEvaluationCriteriaModel {
  final int id;
  final String name;
  final String? description;
  final String category;
  final String maxScore;
  final String weight;
  final Map<String, dynamic> scoringAnchors;

  const ProjectEvaluationCriteriaModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.maxScore,
    required this.weight,
    required this.scoringAnchors,
  });

  factory ProjectEvaluationCriteriaModel.fromJson(Map<String, dynamic> json) {
    return ProjectEvaluationCriteriaModel(
      id: _ProjectEvaluationJson.toInt(json['id']),
      name: json['name']?.toString() ?? '',
      description: _ProjectEvaluationJson.nullableString(json['description']),
      category: json['category']?.toString() ?? '',
      maxScore: json['max_score']?.toString() ?? '',
      weight: json['weight']?.toString() ?? '',
      scoringAnchors: _ProjectEvaluationJson.map(json['scoring_anchors']),
    );
  }
}

class AppealWindowModel {
  final String? startedAt;
  final String? deadlineAt;
  final bool isOpen;
  final int durationHours;

  const AppealWindowModel({
    required this.startedAt,
    required this.deadlineAt,
    required this.isOpen,
    required this.durationHours,
  });

  factory AppealWindowModel.fromJson(Map<String, dynamic> json) {
    return AppealWindowModel(
      startedAt: _ProjectEvaluationJson.nullableString(json['started_at']),
      deadlineAt: _ProjectEvaluationJson.nullableString(json['deadline_at']),
      isOpen: json['is_open'] == true,
      durationHours: _ProjectEvaluationJson.toInt(json['duration_hours']),
    );
  }
}

class ProjectEvaluationAppealModel {
  final int id;
  final int projectEvaluationId;
  final String reason;
  final String status;
  final bool isPending;
  final Map<String, dynamic>? evaluationSnapshot;
  final String? reviewNotes;
  final String? reviewedAt;
  final int? revisionRequestId;
  final String? createdAt;
  final ProjectEvaluationPersonModel? reviewedBy;
  final ProjectEvaluationModel? evaluation;

  const ProjectEvaluationAppealModel({
    required this.id,
    required this.projectEvaluationId,
    required this.reason,
    required this.status,
    required this.isPending,
    required this.evaluationSnapshot,
    required this.reviewNotes,
    required this.reviewedAt,
    required this.revisionRequestId,
    required this.createdAt,
    required this.reviewedBy,
    required this.evaluation,
  });

  factory ProjectEvaluationAppealModel.fromJson(Map<String, dynamic> json) {
    final snapshot = json['evaluation_snapshot'];
    final reviewedBy = json['reviewed_by'];
    final evaluation = json['evaluation'];
    final revisionRequestId = _ProjectEvaluationJson.toNullableInt(
      json['revision_request_id'],
    );

    return ProjectEvaluationAppealModel(
      id: _ProjectEvaluationJson.toInt(json['id']),
      projectEvaluationId: _ProjectEvaluationJson.toInt(
        json['project_evaluation_id'],
      ),
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      isPending: json['is_pending'] == true || json['status'] == 'pending',
      evaluationSnapshot: snapshot is Map
          ? Map<String, dynamic>.from(snapshot)
          : null,
      reviewNotes: _ProjectEvaluationJson.nullableString(json['review_notes']),
      reviewedAt: _ProjectEvaluationJson.nullableString(json['reviewed_at']),
      revisionRequestId: revisionRequestId,
      createdAt: _ProjectEvaluationJson.nullableString(json['created_at']),
      reviewedBy: reviewedBy is Map
          ? ProjectEvaluationPersonModel.fromJson(
              Map<String, dynamic>.from(reviewedBy),
            )
          : null,
      evaluation: evaluation is Map
          ? ProjectEvaluationModel.fromJson(
              Map<String, dynamic>.from(evaluation),
            )
          : null,
    );
  }
}

class _ProjectEvaluationJson {
  static int toInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

  static int? toNullableInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static String? nullableString(dynamic value) {
    final result = value?.toString().trim();
    return result == null || result.isEmpty ? null : result;
  }

  static Map<String, dynamic> map(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> list(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
