class CompanyTaskAssignmentModel {
  final int assignmentId;
  final String status;
  final CompanyTaskAssignmentTaskModel task;
  final CompanyTaskAssignmentStudentModel student;
  final CompanyTaskAssignmentMatchingModel matching;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final DateTime? completedAt;

  const CompanyTaskAssignmentModel({
    required this.assignmentId,
    required this.status,
    required this.task,
    required this.student,
    required this.matching,
    required this.startedAt,
    required this.submittedAt,
    required this.completedAt,
  });

  factory CompanyTaskAssignmentModel.fromJson(Map<String, dynamic> json) {
    return CompanyTaskAssignmentModel(
      assignmentId: _toInt(json['assignment_id']),
      status: json['status']?.toString() ?? '',
      task: CompanyTaskAssignmentTaskModel.fromJson(
        Map<String, dynamic>.from(json['task'] as Map? ?? {}),
      ),
      student: CompanyTaskAssignmentStudentModel.fromJson(
        Map<String, dynamic>.from(json['student'] as Map? ?? {}),
      ),
      matching: CompanyTaskAssignmentMatchingModel.fromJson(
        Map<String, dynamic>.from(json['matching'] as Map? ?? {}),
      ),
      startedAt: _toDate(json['started_at']),
      submittedAt: _toDate(json['submitted_at']),
      completedAt: _toDate(json['completed_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignment_id': assignmentId,
      'status': status,
      'task': task.toJson(),
      'student': student.toJson(),
      'matching': matching.toJson(),
      'started_at': startedAt?.toIso8601String(),
      'submitted_at': submittedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  bool get isWorking => status == 'working';

  bool get isSubmitted => status == 'submitted';

  bool get isCompleted => status == 'completed';

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}

class CompanyTaskAssignmentTaskModel {
  final int id;
  final String title;
  final String difficultyLevel;
  final DateTime? deadline;

  const CompanyTaskAssignmentTaskModel({
    required this.id,
    required this.title,
    required this.difficultyLevel,
    required this.deadline,
  });

  factory CompanyTaskAssignmentTaskModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskAssignmentTaskModel(
      id: CompanyTaskAssignmentModel._toInt(json['id']),
      title: json['title']?.toString() ?? 'مهمة بدون عنوان',
      difficultyLevel: json['difficulty_level']?.toString() ?? '',
      deadline: CompanyTaskAssignmentModel._toDate(json['deadline']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'difficulty_level': difficultyLevel,
      'deadline': deadline?.toIso8601String(),
    };
  }
}

class CompanyTaskAssignmentStudentModel {
  final int id;
  final String name;
  final String email;
  final String? profilePictureUrl;

  const CompanyTaskAssignmentStudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
  });

  factory CompanyTaskAssignmentStudentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskAssignmentStudentModel(
      id: CompanyTaskAssignmentModel._toInt(json['id']),
      name: json['name']?.toString() ?? 'طالب بدون اسم',
      email: json['email']?.toString() ?? '',
      profilePictureUrl: json['profile_picture_url']?.toString(),
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

class CompanyTaskAssignmentMatchingModel {
  final double score;

  const CompanyTaskAssignmentMatchingModel({
    required this.score,
  });

  factory CompanyTaskAssignmentMatchingModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskAssignmentMatchingModel(
      score: CompanyTaskAssignmentModel._toDouble(json['score']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
    };
  }
}