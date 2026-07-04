class CompanyTaskSubmissionReviewModel {
  final int id;
  final int submissionId;
  final int assignmentId;
  final CompanyTaskReviewTaskModel task;
  final CompanyTaskReviewStudentModel student;
  final CompanyTaskReviewCompanyModel company;
  final CompanyTaskReviewScoresModel scores;
  final String finalDecision;
  final String feedback;
  final DateTime? reviewedAt;
  final DateTime? createdAt;

  const CompanyTaskSubmissionReviewModel({
    required this.id,
    required this.submissionId,
    required this.assignmentId,
    required this.task,
    required this.student,
    required this.company,
    required this.scores,
    required this.finalDecision,
    required this.feedback,
    required this.reviewedAt,
    required this.createdAt,
  });

  factory CompanyTaskSubmissionReviewModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskSubmissionReviewModel(
      id: _ReviewJson.toInt(json['id']),
      submissionId: _ReviewJson.toInt(json['submission_id']),
      assignmentId: _ReviewJson.toInt(json['assignment_id']),
      task: CompanyTaskReviewTaskModel.fromJson(
        _ReviewJson.map(json['task']),
      ),
      student: CompanyTaskReviewStudentModel.fromJson(
        _ReviewJson.map(json['student']),
      ),
      company: CompanyTaskReviewCompanyModel.fromJson(
        _ReviewJson.map(json['company']),
      ),
      scores: CompanyTaskReviewScoresModel.fromJson(
        _ReviewJson.map(json['scores']),
      ),
      finalDecision: json['final_decision']?.toString() ?? '',
      feedback: json['feedback']?.toString() ?? '',
      reviewedAt: _ReviewJson.toDate(json['reviewed_at']),
      createdAt: _ReviewJson.toDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'submission_id': submissionId,
      'assignment_id': assignmentId,
      'task': task.toJson(),
      'student': student.toJson(),
      'company': company.toJson(),
      'scores': scores.toJson(),
      'final_decision': finalDecision,
      'feedback': feedback,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class CompanyTaskReviewRequest {
  final int qualityScore;
  final int commitmentScore;
  final int communicationScore;
  final String finalDecision;
  final String feedback;

  const CompanyTaskReviewRequest({
    required this.qualityScore,
    required this.commitmentScore,
    required this.communicationScore,
    required this.finalDecision,
    required this.feedback,
  });

  bool get hasValidScores {
    return qualityScore >= 0 &&
        qualityScore <= 100 &&
        commitmentScore >= 0 &&
        commitmentScore <= 100 &&
        communicationScore >= 0 &&
        communicationScore <= 100;
  }

  bool get hasFeedback => feedback.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'quality_score': qualityScore,
      'commitment_score': commitmentScore,
      'communication_score': communicationScore,
      'final_decision': finalDecision,
      'feedback': feedback.trim(),
    };
  }
}

class CompanyTaskReviewTaskModel {
  final int id;
  final String title;
  final DateTime? deadline;

  const CompanyTaskReviewTaskModel({
    required this.id,
    required this.title,
    required this.deadline,
  });

  factory CompanyTaskReviewTaskModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskReviewTaskModel(
      id: _ReviewJson.toInt(json['id']),
      title: json['title']?.toString() ?? 'مهمة بدون عنوان',
      deadline: _ReviewJson.toDate(json['deadline']),
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

class CompanyTaskReviewStudentModel {
  final int id;
  final String name;
  final String email;
  final String? profilePictureUrl;

  const CompanyTaskReviewStudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
  });

  factory CompanyTaskReviewStudentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskReviewStudentModel(
      id: _ReviewJson.toInt(json['id']),
      name: json['name']?.toString() ?? 'الطالب',
      email: json['email']?.toString() ?? '',
      profilePictureUrl: _ReviewJson.nullableString(
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

class CompanyTaskReviewCompanyModel {
  final int id;
  final String name;

  const CompanyTaskReviewCompanyModel({
    required this.id,
    required this.name,
  });

  factory CompanyTaskReviewCompanyModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskReviewCompanyModel(
      id: _ReviewJson.toInt(json['id']),
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class CompanyTaskReviewScoresModel {
  final int quality;
  final int commitment;
  final int communication;
  final double total;

  const CompanyTaskReviewScoresModel({
    required this.quality,
    required this.commitment,
    required this.communication,
    required this.total,
  });

  factory CompanyTaskReviewScoresModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskReviewScoresModel(
      quality: _ReviewJson.toInt(json['quality']),
      commitment: _ReviewJson.toInt(json['commitment']),
      communication: _ReviewJson.toInt(json['communication']),
      total: _ReviewJson.toDouble(json['total']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quality': quality,
      'commitment': commitment,
      'communication': communication,
      'total': total,
    };
  }
}

class _ReviewJson {
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

  static double toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
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