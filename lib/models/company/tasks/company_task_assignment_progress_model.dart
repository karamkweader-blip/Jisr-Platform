class CompanyTaskAssignmentProgressModel {
  final CompanyTaskAssignmentProgressSummaryModel assignment;
  final List<CompanyTaskProgressUpdateModel> progressUpdates;

  const CompanyTaskAssignmentProgressModel({
    required this.assignment,
    required this.progressUpdates,
  });

  factory CompanyTaskAssignmentProgressModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final updates = _AssignmentProgressJson.maps(json['progress_updates'])
        .map(CompanyTaskProgressUpdateModel.fromJson)
        .toList()
      ..sort((first, second) {
        final firstDate = first.createdAt?.millisecondsSinceEpoch ?? 0;
        final secondDate = second.createdAt?.millisecondsSinceEpoch ?? 0;

        return secondDate.compareTo(firstDate);
      });

    return CompanyTaskAssignmentProgressModel(
      assignment: CompanyTaskAssignmentProgressSummaryModel.fromJson(
        _AssignmentProgressJson.map(json['assignment']),
      ),
      progressUpdates: updates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignment': assignment.toJson(),
      'progress_updates':
          progressUpdates.map((update) => update.toJson()).toList(),
    };
  }

  int get latestProgressPercentage {
    if (progressUpdates.isEmpty) {
      return 0;
    }

    return progressUpdates.first.progress.percentage.clamp(0, 100).toInt();
  }

  CompanyTaskProgressUpdateModel? get latestProgressUpdate {
    if (progressUpdates.isEmpty) {
      return null;
    }

    return progressUpdates.first;
  }
}

class CompanyTaskAssignmentProgressSummaryModel {
  final int id;
  final String status;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final CompanyTaskProgressStudentModel student;
  final CompanyTaskProgressTaskModel task;

  const CompanyTaskAssignmentProgressSummaryModel({
    required this.id,
    required this.status,
    required this.startedAt,
    required this.submittedAt,
    required this.student,
    required this.task,
  });

  factory CompanyTaskAssignmentProgressSummaryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskAssignmentProgressSummaryModel(
      id: _AssignmentProgressJson.toInt(json['id']),
      status: json['status']?.toString() ?? '',
      startedAt: _AssignmentProgressJson.toDate(json['started_at']),
      submittedAt: _AssignmentProgressJson.toDate(json['submitted_at']),
      student: CompanyTaskProgressStudentModel.fromJson(
        _AssignmentProgressJson.map(json['student']),
      ),
      task: CompanyTaskProgressTaskModel.fromJson(
        _AssignmentProgressJson.map(json['task']),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'started_at': startedAt?.toIso8601String(),
      'submitted_at': submittedAt?.toIso8601String(),
      'student': student.toJson(),
      'task': task.toJson(),
    };
  }
}

class CompanyTaskProgressStudentModel {
  final int id;
  final String name;
  final String email;
  final String? profilePictureUrl;

  const CompanyTaskProgressStudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
  });

  factory CompanyTaskProgressStudentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskProgressStudentModel(
      id: _AssignmentProgressJson.toInt(json['id']),
      name: json['name']?.toString() ?? 'الطالب',
      email: json['email']?.toString() ?? '',
      profilePictureUrl: _AssignmentProgressJson.nullableString(
        json['profile_picture_url'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_picture_url': profilePictureUrl,
    };
  }
}

class CompanyTaskProgressTaskModel {
  final int id;
  final String title;
  final DateTime? deadline;

  const CompanyTaskProgressTaskModel({
    required this.id,
    required this.title,
    required this.deadline,
  });

  factory CompanyTaskProgressTaskModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskProgressTaskModel(
      id: _AssignmentProgressJson.toInt(json['id']),
      title: json['title']?.toString() ?? 'مهمة بدون عنوان',
      deadline: _AssignmentProgressJson.toDate(json['deadline']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline?.toIso8601String(),
    };
  }
}

class CompanyTaskProgressUpdateModel {
  final int id;
  final int assignmentId;
  final CompanyTaskProgressStudentModel student;
  final CompanyTaskProgressContentModel progress;
  final CompanyTaskProgressLinksModel links;
  final List<CompanyTaskProgressAttachmentModel> attachments;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CompanyTaskProgressUpdateModel({
    required this.id,
    required this.assignmentId,
    required this.student,
    required this.progress,
    required this.links,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyTaskProgressUpdateModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskProgressUpdateModel(
      id: _AssignmentProgressJson.toInt(json['id']),
      assignmentId: _AssignmentProgressJson.toInt(json['assignment_id']),
      student: CompanyTaskProgressStudentModel.fromJson(
        _AssignmentProgressJson.map(json['student']),
      ),
      progress: CompanyTaskProgressContentModel.fromJson(
        _AssignmentProgressJson.map(json['progress']),
      ),
      links: CompanyTaskProgressLinksModel.fromJson(
        _AssignmentProgressJson.map(json['links']),
      ),
      attachments: _AssignmentProgressJson.attachments(json['attachments']),
      createdAt: _AssignmentProgressJson.toDate(json['created_at']),
      updatedAt: _AssignmentProgressJson.toDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'student': student.toJson(),
      'progress': progress.toJson(),
      'links': links.toJson(),
      'attachments': attachments.map((item) => item.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class CompanyTaskProgressContentModel {
  final String title;
  final String description;
  final int percentage;

  const CompanyTaskProgressContentModel({
    required this.title,
    required this.description,
    required this.percentage,
  });

  factory CompanyTaskProgressContentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskProgressContentModel(
      title: json['title']?.toString() ?? 'تحديث تقدم',
      description: json['description']?.toString() ?? '',
      percentage: _AssignmentProgressJson.toInt(json['percentage']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'percentage': percentage,
    };
  }
}

class CompanyTaskProgressLinksModel {
  final String? githubUrl;
  final String? demoUrl;

  const CompanyTaskProgressLinksModel({
    required this.githubUrl,
    required this.demoUrl,
  });

  factory CompanyTaskProgressLinksModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskProgressLinksModel(
      githubUrl: _AssignmentProgressJson.nullableString(json['github_url']),
      demoUrl: _AssignmentProgressJson.nullableString(json['demo_url']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'github_url': githubUrl,
      'demo_url': demoUrl,
    };
  }
}

class CompanyTaskProgressAttachmentModel {
  final String url;

  const CompanyTaskProgressAttachmentModel({
    required this.url,
  });

  factory CompanyTaskProgressAttachmentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskProgressAttachmentModel(
      url: json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
    };
  }
}

class _AssignmentProgressJson {
  static Map<String, dynamic> map(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> maps(dynamic value) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }

    return value.whereType<Map>().map(map).toList();
  }

  static List<CompanyTaskProgressAttachmentModel> attachments(dynamic value) {
    if (value is! List) {
      return <CompanyTaskProgressAttachmentModel>[];
    }

    return value
        .map((item) {
          if (item is Map) {
            return CompanyTaskProgressAttachmentModel.fromJson(map(item));
          }

          return CompanyTaskProgressAttachmentModel(
            url: item?.toString() ?? '',
          );
        })
        .where((attachment) => attachment.url.trim().isNotEmpty)
        .toList();
  }

  static int toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? toDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }

  static String? nullableString(dynamic value) {
    final text = value?.toString().trim() ?? '';

    return text.isEmpty ? null : text;
  }
}