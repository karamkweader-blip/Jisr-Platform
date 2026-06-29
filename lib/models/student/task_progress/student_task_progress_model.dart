class TaskProgressResponse {
  final bool status;
  final String message;
  final TaskProgressData data;

  TaskProgressResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TaskProgressResponse.fromJson(Map<String, dynamic> json) {
    return TaskProgressResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: TaskProgressData.fromJson(json['data'] ?? {}),
    );
  }
}

class TaskProgressData {
  final TaskAssignmentInfo assignment;
  final List<TaskProgressUpdateModel> progressUpdates;

  TaskProgressData({required this.assignment, required this.progressUpdates});

  factory TaskProgressData.fromJson(Map<String, dynamic> json) {
    return TaskProgressData(
      assignment: TaskAssignmentInfo.fromJson(json['assignment'] ?? {}),
      progressUpdates: (json['progress_updates'] as List? ?? [])
          .map((item) => TaskProgressUpdateModel.fromJson(item))
          .toList(),
    );
  }
}

class TaskAssignmentInfo {
  final int id;
  final String status;
  final String? startedAt;
  final TaskProgressTaskInfo task;

  TaskAssignmentInfo({
    required this.id,
    required this.status,
    required this.startedAt,
    required this.task,
  });

  factory TaskAssignmentInfo.fromJson(Map<String, dynamic> json) {
    return TaskAssignmentInfo(
      id: int.tryParse(json['id'].toString()) ?? 0,
      status: json['status']?.toString() ?? '',
      startedAt: json['started_at']?.toString(),
      task: TaskProgressTaskInfo.fromJson(json['task'] ?? {}),
    );
  }
}

class TaskProgressTaskInfo {
  final int id;
  final String title;
  final String? deadline;

  TaskProgressTaskInfo({
    required this.id,
    required this.title,
    required this.deadline,
  });

  factory TaskProgressTaskInfo.fromJson(Map<String, dynamic> json) {
    return TaskProgressTaskInfo(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? 'تاسك',
      deadline: json['deadline']?.toString(),
    );
  }
}

class TaskProgressUpdateResponse {
  final bool status;
  final String message;
  final TaskProgressUpdateModel data;

  TaskProgressUpdateResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TaskProgressUpdateResponse.fromJson(Map<String, dynamic> json) {
    return TaskProgressUpdateResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: TaskProgressUpdateModel.fromJson(json['data'] ?? {}),
    );
  }
}

class TaskProgressUpdateModel {
  final int id;
  final int assignmentId;
  final TaskProgressStudentModel student;
  final TaskProgressInfo progress;
  final TaskProgressLinks links;
  final List<TaskProgressAttachmentModel> attachments;
  final String? createdAt;
  final String? updatedAt;

  TaskProgressUpdateModel({
    required this.id,
    required this.assignmentId,
    required this.student,
    required this.progress,
    required this.links,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskProgressUpdateModel.fromJson(Map<String, dynamic> json) {
    return TaskProgressUpdateModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      assignmentId: int.tryParse(json['assignment_id'].toString()) ?? 0,
      student: TaskProgressStudentModel.fromJson(json['student'] ?? {}),
      progress: TaskProgressInfo.fromJson(json['progress'] ?? {}),
      links: TaskProgressLinks.fromJson(json['links'] ?? {}),
      attachments: (json['attachments'] as List? ?? [])
          .map((item) => TaskProgressAttachmentModel.fromJson(item))
          .toList(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class TaskProgressStudentModel {
  final int id;
  final String name;
  final String email;
  final String? profilePictureUrl;

  TaskProgressStudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
  });

  factory TaskProgressStudentModel.fromJson(Map<String, dynamic> json) {
    return TaskProgressStudentModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profilePictureUrl: json['profile_picture_url']?.toString(),
    );
  }
}

class TaskProgressInfo {
  final String title;
  final String description;
  final int percentage;

  TaskProgressInfo({
    required this.title,
    required this.description,
    required this.percentage,
  });

  factory TaskProgressInfo.fromJson(Map<String, dynamic> json) {
    return TaskProgressInfo(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      percentage: int.tryParse(json['percentage'].toString()) ?? 0,
    );
  }
}

class TaskProgressLinks {
  final String? githubUrl;
  final String? demoUrl;

  TaskProgressLinks({required this.githubUrl, required this.demoUrl});

  factory TaskProgressLinks.fromJson(Map<String, dynamic> json) {
    return TaskProgressLinks(
      githubUrl: json['github_url']?.toString(),
      demoUrl: json['demo_url']?.toString(),
    );
  }
}

class TaskProgressAttachmentModel {
  final String url;

  TaskProgressAttachmentModel({required this.url});

  factory TaskProgressAttachmentModel.fromJson(Map<String, dynamic> json) {
    return TaskProgressAttachmentModel(url: json['url']?.toString() ?? '');
  }
}
