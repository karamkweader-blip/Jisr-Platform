class CompanyTaskAssignmentSubmissionModel {
  final int id;
  final int assignmentId;
  final String status;
  final CompanyTaskSubmissionStudentModel student;
  final CompanyTaskSubmissionTaskModel task;
  final CompanyTaskFinalSubmissionModel submission;
  final CompanyTaskSubmissionStatsModel stats;
  final DateTime? submittedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CompanyTaskAssignmentSubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.status,
    required this.student,
    required this.task,
    required this.submission,
    required this.stats,
    required this.submittedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyTaskAssignmentSubmissionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskAssignmentSubmissionModel(
      id: _SubmissionJson.toInt(json['id']),
      assignmentId: _SubmissionJson.toInt(json['assignment_id']),
      status: json['status']?.toString() ?? '',
      student: CompanyTaskSubmissionStudentModel.fromJson(
        _SubmissionJson.map(json['student']),
      ),
      task: CompanyTaskSubmissionTaskModel.fromJson(
        _SubmissionJson.map(json['task']),
      ),
      submission: CompanyTaskFinalSubmissionModel.fromJson(
        _SubmissionJson.map(json['submission']),
      ),
      stats: CompanyTaskSubmissionStatsModel.fromJson(
        _SubmissionJson.map(json['stats']),
      ),
      submittedAt: _SubmissionJson.toDate(json['submitted_at']),
      createdAt: _SubmissionJson.toDate(json['created_at']),
      updatedAt: _SubmissionJson.toDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'status': status,
      'student': student.toJson(),
      'task': task.toJson(),
      'submission': submission.toJson(),
      'stats': stats.toJson(),
      'submitted_at': submittedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class CompanyTaskSubmissionStudentModel {
  final int id;
  final String name;
  final String email;
  final String? profilePictureUrl;

  const CompanyTaskSubmissionStudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
  });

  factory CompanyTaskSubmissionStudentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskSubmissionStudentModel(
      id: _SubmissionJson.toInt(json['id']),
      name: json['name']?.toString() ?? 'الطالب',
      email: json['email']?.toString() ?? '',
      profilePictureUrl: _SubmissionJson.nullableString(
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

class CompanyTaskSubmissionTaskModel {
  final int id;
  final String title;
  final DateTime? deadline;
  final String submissionType;

  const CompanyTaskSubmissionTaskModel({
    required this.id,
    required this.title,
    required this.deadline,
    required this.submissionType,
  });

  factory CompanyTaskSubmissionTaskModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskSubmissionTaskModel(
      id: _SubmissionJson.toInt(json['id']),
      title: json['title']?.toString() ?? 'مهمة بدون عنوان',
      deadline: _SubmissionJson.toDate(json['deadline']),
      submissionType: json['submission_type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline?.toIso8601String(),
      'submission_type': submissionType,
    };
  }
}

class CompanyTaskFinalSubmissionModel {
  final String? githubUrl;
  final String? demoUrl;
  final CompanyTaskSubmissionZipFileModel? zipFile;
  final String notes;

  const CompanyTaskFinalSubmissionModel({
    required this.githubUrl,
    required this.demoUrl,
    required this.zipFile,
    required this.notes,
  });

  bool get hasGithubUrl => githubUrl != null;

  bool get hasDemoUrl => demoUrl != null;

  bool get hasZipFile => zipFile?.url.isNotEmpty ?? false;

  bool get hasAnySubmissionContent {
    return hasGithubUrl ||
        hasDemoUrl ||
        hasZipFile ||
        notes.trim().isNotEmpty;
  }

  factory CompanyTaskFinalSubmissionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawZipFile = json['zip_file'];

    return CompanyTaskFinalSubmissionModel(
      githubUrl: _SubmissionJson.nullableString(json['github_url']),
      demoUrl: _SubmissionJson.nullableString(json['demo_url']),
      zipFile: rawZipFile is Map
          ? CompanyTaskSubmissionZipFileModel.fromJson(
              _SubmissionJson.map(rawZipFile),
            )
          : null,
      notes: json['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'github_url': githubUrl,
      'demo_url': demoUrl,
      'zip_file': zipFile?.toJson(),
      'notes': notes,
    };
  }
}

class CompanyTaskSubmissionZipFileModel {
  final String url;

  const CompanyTaskSubmissionZipFileModel({
    required this.url,
  });

  factory CompanyTaskSubmissionZipFileModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskSubmissionZipFileModel(
      url: json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
    };
  }
}

class CompanyTaskSubmissionStatsModel {
  final int acceptedStudentsCount;
  final int submissionsCount;

  const CompanyTaskSubmissionStatsModel({
    required this.acceptedStudentsCount,
    required this.submissionsCount,
  });

  factory CompanyTaskSubmissionStatsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskSubmissionStatsModel(
      acceptedStudentsCount: _SubmissionJson.toInt(
        json['accepted_students_count'],
      ),
      submissionsCount: _SubmissionJson.toInt(
        json['submissions_count'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accepted_students_count': acceptedStudentsCount,
      'submissions_count': submissionsCount,
    };
  }
}

class _SubmissionJson {
  static Map<String, dynamic> map(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
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