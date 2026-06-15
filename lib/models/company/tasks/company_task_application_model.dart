class CompanyTaskApplicationModel {
  final int applicationId;
  final CompanyTaskApplicationStudentModel student;
  final int portfolioProjectsCount;
  final String status;
  final double matchScore;
  final DateTime? appliedAt;

  const CompanyTaskApplicationModel({
    required this.applicationId,
    required this.student,
    required this.portfolioProjectsCount,
    required this.status,
    required this.matchScore,
    required this.appliedAt,
  });

  factory CompanyTaskApplicationModel.fromJson(Map<String, dynamic> json) {
    return CompanyTaskApplicationModel(
      applicationId: _toInt(json['application_id']),
      student: CompanyTaskApplicationStudentModel.fromJson(
        json['student'] as Map<String, dynamic>? ?? {},
      ),
      portfolioProjectsCount: _toInt(json['portfolio_projects_count']),
      status: json['status']?.toString() ?? '',
      matchScore: _toDouble(json['match_score']),
      appliedAt: _toDate(json['applied_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'application_id': applicationId,
      'student': student.toJson(),
      'portfolio_projects_count': portfolioProjectsCount,
      'status': status,
      'match_score': matchScore,
      'applied_at': appliedAt?.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

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

class CompanyTaskApplicationStudentModel {
  final int id;
  final String name;
  final String? profilePictureUrl;

  const CompanyTaskApplicationStudentModel({
    required this.id,
    required this.name,
    required this.profilePictureUrl,
  });

  factory CompanyTaskApplicationStudentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyTaskApplicationStudentModel(
      id: CompanyTaskApplicationModel._toInt(json['id']),
      name: json['name']?.toString() ?? 'طالب بدون اسم',
      profilePictureUrl: json['profile_picture_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_picture_url': profilePictureUrl,
    };
  }
}