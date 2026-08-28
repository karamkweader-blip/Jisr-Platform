class StudentSupervisorProjectsResponse {
  final String message;
  final List<StudentSupervisorProjectModel> projects;
  final StudentSupervisorProjectsPagination pagination;

  const StudentSupervisorProjectsResponse({
    required this.message,
    required this.projects,
    required this.pagination,
  });

  factory StudentSupervisorProjectsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = SupervisorProjectJson.map(json['data']);
    return StudentSupervisorProjectsResponse(
      message: SupervisorProjectJson.string(json['message']),
      projects: SupervisorProjectJson.list(data['projects'])
          .map(StudentSupervisorProjectModel.fromJson)
          .toList(),
      pagination: StudentSupervisorProjectsPagination.fromJson(
        SupervisorProjectJson.map(data['pagination']),
      ),
    );
  }
}

class StudentSupervisorProjectDetailsResponse {
  final String message;
  final StudentSupervisorProjectModel project;

  const StudentSupervisorProjectDetailsResponse({
    required this.message,
    required this.project,
  });

  factory StudentSupervisorProjectDetailsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentSupervisorProjectDetailsResponse(
      message: SupervisorProjectJson.string(json['message']),
      project: StudentSupervisorProjectModel.fromJson(
        SupervisorProjectJson.map(json['data']),
      ),
    );
  }
}

class StudentSupervisorProjectApplyResponse {
  final String message;
  final int applicationId;
  final int projectTemplateId;
  final String status;
  final String? appliedAt;

  const StudentSupervisorProjectApplyResponse({
    required this.message,
    required this.applicationId,
    required this.projectTemplateId,
    required this.status,
    required this.appliedAt,
  });

  factory StudentSupervisorProjectApplyResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = SupervisorProjectJson.map(json['data']);
    return StudentSupervisorProjectApplyResponse(
      message: SupervisorProjectJson.string(json['message']),
      applicationId: SupervisorProjectJson.integer(data['application_id']),
      projectTemplateId:
          SupervisorProjectJson.integer(data['project_template_id']),
      status: SupervisorProjectJson.string(data['status']),
      appliedAt: SupervisorProjectJson.nullableString(data['applied_at']),
    );
  }
}

class StudentSupervisorProjectApplicationsResponse {
  final String message;
  final List<StudentSupervisorProjectApplicationItem> pending;
  final List<StudentSupervisorProjectApplicationItem> accepted;
  final List<StudentSupervisorProjectApplicationItem> rejected;

  const StudentSupervisorProjectApplicationsResponse({
    required this.message,
    required this.pending,
    required this.accepted,
    required this.rejected,
  });

  List<StudentSupervisorProjectApplicationItem> get all => <StudentSupervisorProjectApplicationItem>[
        ...pending,
        ...accepted,
        ...rejected,
      ];

  factory StudentSupervisorProjectApplicationsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = SupervisorProjectJson.map(json['data']);
    List<StudentSupervisorProjectApplicationItem> parse(String key) =>
        SupervisorProjectJson.list(data[key])
            .map(StudentSupervisorProjectApplicationItem.fromJson)
            .toList();

    return StudentSupervisorProjectApplicationsResponse(
      message: SupervisorProjectJson.string(json['message']),
      pending: parse('pending'),
      accepted: parse('accepted'),
      rejected: parse('rejected'),
    );
  }
}

class StudentSupervisorProjectModel {
  final int id;
  final String title;
  final String? description;
  final String level;
  final String? expectedOutcome;
  final StudentSupervisorProjectSupervisor supervisor;
  final StudentSupervisorProjectTasksSummary tasksSummary;
  final StudentSupervisorProjectCapacity capacity;
  final StudentSupervisorProjectApplicationState? application;
  final StudentSupervisorProjectActions actions;
  final List<StudentSupervisorProjectTask> tasks;
  final String? createdAt;
  final String? updatedAt;

  const StudentSupervisorProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.expectedOutcome,
    required this.supervisor,
    required this.tasksSummary,
    required this.capacity,
    required this.application,
    required this.actions,
    required this.tasks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentSupervisorProjectModel.fromJson(Map<String, dynamic> json) {
    final rawApplication = json['application'];
    return StudentSupervisorProjectModel(
      id: SupervisorProjectJson.integer(json['id']),
      title: SupervisorProjectJson.string(json['title']),
      description: SupervisorProjectJson.nullableString(json['description']),
      level: SupervisorProjectJson.string(json['level']),
      expectedOutcome:
          SupervisorProjectJson.nullableString(json['expected_outcome']),
      supervisor: StudentSupervisorProjectSupervisor.fromJson(
        SupervisorProjectJson.map(json['supervisor']),
      ),
      tasksSummary: StudentSupervisorProjectTasksSummary.fromJson(
        SupervisorProjectJson.map(json['tasks_summary']),
      ),
      capacity: StudentSupervisorProjectCapacity.fromJson(
        SupervisorProjectJson.map(json['capacity']),
      ),
      application: rawApplication is Map
          ? StudentSupervisorProjectApplicationState.fromJson(
              Map<String, dynamic>.from(rawApplication),
            )
          : null,
      actions: StudentSupervisorProjectActions.fromJson(
        SupervisorProjectJson.map(json['actions']),
      ),
      tasks: SupervisorProjectJson.list(json['tasks'])
          .map(StudentSupervisorProjectTask.fromJson)
          .toList()
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
      createdAt: SupervisorProjectJson.nullableString(json['created_at']),
      updatedAt: SupervisorProjectJson.nullableString(json['updated_at']),
    );
  }
}

class StudentSupervisorProjectSupervisor {
  final int id;
  final String name;
  final String? specialization;
  final bool isVolunteer;

  const StudentSupervisorProjectSupervisor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.isVolunteer,
  });

  factory StudentSupervisorProjectSupervisor.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentSupervisorProjectSupervisor(
      id: SupervisorProjectJson.integer(json['id']),
      name: SupervisorProjectJson.string(json['name']),
      specialization:
          SupervisorProjectJson.nullableString(json['specialization']),
      isVolunteer: json['is_volunteer'] == true,
    );
  }
}

class StudentSupervisorProjectTasksSummary {
  final int count;
  final int estimatedTotalHours;

  const StudentSupervisorProjectTasksSummary({
    required this.count,
    required this.estimatedTotalHours,
  });

  factory StudentSupervisorProjectTasksSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentSupervisorProjectTasksSummary(
      count: SupervisorProjectJson.integer(json['count']),
      estimatedTotalHours:
          SupervisorProjectJson.integer(json['estimated_total_hours']),
    );
  }
}

class StudentSupervisorProjectCapacity {
  final int? maxStudents;
  final int activeApplicationsCount;
  final int? remainingSlots;
  final bool isFull;

  const StudentSupervisorProjectCapacity({
    required this.maxStudents,
    required this.activeApplicationsCount,
    required this.remainingSlots,
    required this.isFull,
  });

  factory StudentSupervisorProjectCapacity.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentSupervisorProjectCapacity(
      maxStudents: SupervisorProjectJson.nullableInteger(json['max_students']),
      activeApplicationsCount:
          SupervisorProjectJson.integer(json['active_applications_count']),
      remainingSlots:
          SupervisorProjectJson.nullableInteger(json['remaining_slots']),
      isFull: json['is_full'] == true,
    );
  }
}

class StudentSupervisorProjectApplicationState {
  final int applicationId;
  final String status;
  final int? projectAssignmentId;
  final String? appliedAt;

  const StudentSupervisorProjectApplicationState({
    required this.applicationId,
    required this.status,
    required this.projectAssignmentId,
    required this.appliedAt,
  });

  factory StudentSupervisorProjectApplicationState.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentSupervisorProjectApplicationState(
      applicationId:
          SupervisorProjectJson.integer(json['application_id']),
      status: SupervisorProjectJson.string(json['status']),
      projectAssignmentId:
          SupervisorProjectJson.nullableInteger(json['project_assignment_id']),
      appliedAt: SupervisorProjectJson.nullableString(json['applied_at']),
    );
  }
}

class StudentSupervisorProjectActions {
  final bool canApply;
  final String? applyBlockReason;
  final bool canOpenAssignment;

  const StudentSupervisorProjectActions({
    required this.canApply,
    required this.applyBlockReason,
    required this.canOpenAssignment,
  });

  factory StudentSupervisorProjectActions.fromJson(Map<String, dynamic> json) {
    return StudentSupervisorProjectActions(
      canApply: json['can_apply'] == true,
      applyBlockReason:
          SupervisorProjectJson.nullableString(json['apply_block_reason']),
      canOpenAssignment: json['can_open_assignment'] == true,
    );
  }
}

class StudentSupervisorProjectTask {
  final int id;
  final String title;
  final String? description;
  final int estimatedHours;
  final int orderIndex;

  const StudentSupervisorProjectTask({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedHours,
    required this.orderIndex,
  });

  factory StudentSupervisorProjectTask.fromJson(Map<String, dynamic> json) {
    return StudentSupervisorProjectTask(
      id: SupervisorProjectJson.integer(json['id']),
      title: SupervisorProjectJson.string(json['title']),
      description: SupervisorProjectJson.nullableString(json['description']),
      estimatedHours:
          SupervisorProjectJson.integer(json['estimated_hours']),
      orderIndex: SupervisorProjectJson.integer(json['order_index']),
    );
  }
}

class StudentSupervisorProjectsPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const StudentSupervisorProjectsPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  const StudentSupervisorProjectsPagination.empty()
      : currentPage = 1,
        lastPage = 1,
        perPage = 15,
        total = 0;

  factory StudentSupervisorProjectsPagination.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentSupervisorProjectsPagination(
      currentPage: SupervisorProjectJson.integer(json['current_page'], 1),
      lastPage: SupervisorProjectJson.integer(json['last_page'], 1),
      perPage: SupervisorProjectJson.integer(json['per_page'], 15),
      total: SupervisorProjectJson.integer(json['total']),
    );
  }
}

class StudentSupervisorProjectApplicationItem {
  final int applicationId;
  final int projectTemplateId;
  final String status;
  final String? message;
  final String? supervisorNotes;
  final String? appliedAt;
  final String? reviewedAt;
  final int? projectAssignmentId;
  final StudentSupervisorProjectApplicationTemplate projectTemplate;
  final StudentSupervisorProjectAssignmentSummary? projectAssignment;

  const StudentSupervisorProjectApplicationItem({
    required this.applicationId,
    required this.projectTemplateId,
    required this.status,
    required this.message,
    required this.supervisorNotes,
    required this.appliedAt,
    required this.reviewedAt,
    required this.projectAssignmentId,
    required this.projectTemplate,
    required this.projectAssignment,
  });

  factory StudentSupervisorProjectApplicationItem.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawAssignment = json['project_assignment'];
    return StudentSupervisorProjectApplicationItem(
      applicationId:
          SupervisorProjectJson.integer(json['application_id']),
      projectTemplateId:
          SupervisorProjectJson.integer(json['project_template_id']),
      status: SupervisorProjectJson.string(json['status']),
      message: SupervisorProjectJson.nullableString(json['message']),
      supervisorNotes:
          SupervisorProjectJson.nullableString(json['supervisor_notes']),
      appliedAt: SupervisorProjectJson.nullableString(json['applied_at']),
      reviewedAt: SupervisorProjectJson.nullableString(json['reviewed_at']),
      projectAssignmentId:
          SupervisorProjectJson.nullableInteger(json['project_assignment_id']),
      projectTemplate: StudentSupervisorProjectApplicationTemplate.fromJson(
        SupervisorProjectJson.map(json['project_template']),
      ),
      projectAssignment: rawAssignment is Map
          ? StudentSupervisorProjectAssignmentSummary.fromJson(
              Map<String, dynamic>.from(rawAssignment),
            )
          : null,
    );
  }
}

class StudentSupervisorProjectApplicationTemplate {
  final int id;
  final String title;
  final String? description;
  final String level;
  final String? expectedOutcome;
  final int? maxStudents;

  const StudentSupervisorProjectApplicationTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.expectedOutcome,
    required this.maxStudents,
  });

  factory StudentSupervisorProjectApplicationTemplate.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentSupervisorProjectApplicationTemplate(
      id: SupervisorProjectJson.integer(json['id']),
      title: SupervisorProjectJson.string(json['title']),
      description: SupervisorProjectJson.nullableString(json['description']),
      level: SupervisorProjectJson.string(json['level']),
      expectedOutcome:
          SupervisorProjectJson.nullableString(json['expected_outcome']),
      maxStudents: SupervisorProjectJson.nullableInteger(json['max_students']),
    );
  }
}

class StudentSupervisorProjectAssignmentSummary {
  final int id;
  final String status;
  final int progressPercentage;
  final String? assignedAt;

  const StudentSupervisorProjectAssignmentSummary({
    required this.id,
    required this.status,
    required this.progressPercentage,
    required this.assignedAt,
  });

  factory StudentSupervisorProjectAssignmentSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentSupervisorProjectAssignmentSummary(
      id: SupervisorProjectJson.integer(json['id']),
      status: SupervisorProjectJson.string(json['status']),
      progressPercentage:
          SupervisorProjectJson.integer(json['progress_percentage']),
      assignedAt: SupervisorProjectJson.nullableString(json['assigned_at']),
    );
  }
}

abstract class SupervisorProjectJson {
  static Map<String, dynamic> map(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> list(dynamic value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  static String string(dynamic value) => value?.toString() ?? '';

  static String? nullableString(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int integer(dynamic value, [int fallback = 0]) =>
      int.tryParse(value?.toString() ?? '') ?? fallback;

  static int? nullableInteger(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }
}
