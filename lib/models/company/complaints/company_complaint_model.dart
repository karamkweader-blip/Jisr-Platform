abstract final class CompanyComplaintStatuses {
  static const String pending = 'pending';
  static const String underReview = 'under_review';
  static const String resolved = 'resolved';
  static const String rejected = 'rejected';

  static const List<String> values = <String>[
    pending,
    underReview,
    resolved,
    rejected,
  ];

  static String label(String value) {
    switch (value) {
      case pending:
        return 'قيد الانتظار';
      case underReview:
        return 'قيد المراجعة';
      case resolved:
        return 'تم الحل';
      case rejected:
        return 'مرفوضة';
      default:
        return value.isEmpty ? 'غير محددة' : value;
    }
  }
}

abstract final class CompanyComplaintContextTypes {
  static const String taskAssignment = 'company_task_assignment';
  static const String opportunityInterview = 'opportunity_interview';

  static const List<String> values = <String>[
    taskAssignment,
    opportunityInterview,
  ];

  static String label(String value) {
    switch (value) {
      case taskAssignment:
        return 'تكليف مهمة';
      case opportunityInterview:
        return 'مقابلة فرصة';
      default:
        return value.isEmpty ? 'غير محدد' : value;
    }
  }
}

class CompanyComplaintRequest {
  final String contextType;
  final int contextId;
  final String reason;

  const CompanyComplaintRequest({
    required this.contextType,
    required this.contextId,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'context_type': contextType,
      'context_id': contextId,
      'reason': reason.trim(),
    };
  }
}

class CompanyComplaintsResponse {
  final String message;
  final List<CompanyComplaintModel> complaints;
  final CompanyComplaintsPagination pagination;

  const CompanyComplaintsResponse({
    required this.message,
    required this.complaints,
    required this.pagination,
  });

  factory CompanyComplaintsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = _ComplaintJson.map(json['data']);

    return CompanyComplaintsResponse(
      message: _ComplaintJson.string(json['message']),
      complaints: _ComplaintJson.maps(data['complaints'])
          .map(CompanyComplaintModel.fromJson)
          .where((complaint) => complaint.id > 0)
          .toList(growable: false),
      pagination: CompanyComplaintsPagination.fromJson(
        _ComplaintJson.map(data['pagination']),
      ),
    );
  }
}

class CompanyComplaintModel {
  final int id;
  final String targetType;
  final CompanyComplaintReportedUser? reportedUser;
  final CompanyComplaintReportedMentor? reportedMentor;
  final CompanyComplaintContext context;
  final String reason;
  final String status;
  final String? resolutionNotes;
  final DateTime? resolvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CompanyComplaintModel({
    required this.id,
    required this.targetType,
    required this.reportedUser,
    required this.reportedMentor,
    required this.context,
    required this.reason,
    required this.status,
    required this.resolutionNotes,
    required this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyComplaintModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final reportedUser =
        _ComplaintJson.nullableMap(json['reported_user']);

    final reportedMentor =
        _ComplaintJson.nullableMap(json['reported_mentor']);

    return CompanyComplaintModel(
      id: _ComplaintJson.integer(json['id']),
      targetType: _ComplaintJson.string(json['target_type']),
      reportedUser: reportedUser == null
          ? null
          : CompanyComplaintReportedUser.fromJson(
              reportedUser,
            ),
      reportedMentor: reportedMentor == null
          ? null
          : CompanyComplaintReportedMentor.fromJson(
              reportedMentor,
            ),
      context: CompanyComplaintContext.fromJson(
        _ComplaintJson.map(json['context']),
      ),
      reason: _ComplaintJson.string(json['reason']),
      status: _ComplaintJson.string(json['status']),
      resolutionNotes: _ComplaintJson.nullableString(
        json['resolution_notes'],
      ),
      resolvedAt: _ComplaintJson.date(json['resolved_at']),
      createdAt: _ComplaintJson.date(json['created_at']),
      updatedAt: _ComplaintJson.date(json['updated_at']),
    );
  }

  String get targetName {
    final userName = reportedUser?.name.trim();

    if (userName != null && userName.isNotEmpty) {
      return userName;
    }

    final mentorName = reportedMentor?.name.trim();

    if (mentorName != null && mentorName.isNotEmpty) {
      return mentorName;
    }

    return 'مستخدم جسور';
  }

  String get targetEmail {
    final userEmail = reportedUser?.email.trim();

    if (userEmail != null && userEmail.isNotEmpty) {
      return userEmail;
    }

    final mentorEmail = reportedMentor?.email.trim();

    if (mentorEmail != null && mentorEmail.isNotEmpty) {
      return mentorEmail;
    }

    return '';
  }

  bool get hasResolution {
    return (resolutionNotes?.trim().isNotEmpty ?? false) ||
        resolvedAt != null;
  }
}

class CompanyComplaintReportedUser {
  final int id;
  final String name;
  final String email;

  const CompanyComplaintReportedUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory CompanyComplaintReportedUser.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyComplaintReportedUser(
      id: _ComplaintJson.integer(json['id']),
      name: _ComplaintJson.string(json['name']),
      email: _ComplaintJson.string(json['email']),
    );
  }
}

class CompanyComplaintReportedMentor {
  final int id;
  final String name;
  final String email;

  const CompanyComplaintReportedMentor({
    required this.id,
    required this.name,
    required this.email,
  });

  factory CompanyComplaintReportedMentor.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyComplaintReportedMentor(
      id: _ComplaintJson.integer(
        json['id'] ?? json['id_Mentor_Profile'],
      ),
      name: _ComplaintJson.string(
        json['full_name'] ?? json['name'],
      ),
      email: _ComplaintJson.string(json['email']),
    );
  }
}

class CompanyComplaintContext {
  final String type;
  final int id;

  const CompanyComplaintContext({
    required this.type,
    required this.id,
  });

  factory CompanyComplaintContext.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyComplaintContext(
      type: _ComplaintJson.string(json['type']),
      id: _ComplaintJson.integer(json['id']),
    );
  }
}

class CompanyComplaintsPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const CompanyComplaintsPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory CompanyComplaintsPagination.fromJson(
    Map<String, dynamic> json,
  ) {
    final currentPage = _ComplaintJson.integer(
      json['current_page'],
      fallback: 1,
    );

    final lastPage = _ComplaintJson.integer(
      json['last_page'],
      fallback: 1,
    );

    return CompanyComplaintsPagination(
      currentPage: currentPage < 1 ? 1 : currentPage,
      lastPage: lastPage < 1 ? 1 : lastPage,
      perPage: _ComplaintJson.integer(
        json['per_page'],
        fallback: 20,
      ),
      total: _ComplaintJson.integer(json['total']),
    );
  }
}

abstract final class _ComplaintJson {
  static Map<String, dynamic> map(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  static Map<String, dynamic>? nullableMap(dynamic value) {
    if (value is! Map) {
      return null;
    }

    return Map<String, dynamic>.from(value);
  }

  static List<Map<String, dynamic>> maps(dynamic value) {
    if (value is! List) {
      return const <Map<String, dynamic>>[];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList(growable: false);
  }

  static String string(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static String? nullableString(dynamic value) {
    final result = string(value);

    return result.isEmpty ? null : result;
  }

  static int integer(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ??
        fallback;
  }

  static DateTime? date(dynamic value) {
    final text = nullableString(value);

    return text == null ? null : DateTime.tryParse(text);
  }
}