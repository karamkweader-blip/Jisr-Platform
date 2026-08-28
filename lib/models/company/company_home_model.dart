class CompanyHomeModel {
  final CompanyHomeCompany company;
  final CompanyHomeStats stats;
  final List<CompanyRequiredAction> requiredActions;
  final List<CompanyRecentActivity> recentActivities;

  const CompanyHomeModel({
    required this.company,
    required this.stats,
    required this.requiredActions,
    required this.recentActivities,
  });

  factory CompanyHomeModel.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);

    return CompanyHomeModel(
      company: CompanyHomeCompany.fromJson(
        _asMap(data['company']),
      ),
      stats: CompanyHomeStats.fromJson(
        _asMap(data['stats']),
      ),
      requiredActions: _asList(data['required_actions'])
          .map(
            (item) => CompanyRequiredAction.fromJson(
              _asMap(item),
            ),
          )
          .toList(growable: false),
      recentActivities: _asList(data['recent_activities'])
          .map(
            (item) => CompanyRecentActivity.fromJson(
              _asMap(item),
            ),
          )
          .toList(growable: false),
    );
  }

  bool get hasAnyActivity {
    return stats.activeOpportunitiesCount > 0 ||
        stats.newApplicantsCount > 0 ||
        stats.pendingReviewsCount > 0 ||
        stats.activeAssignmentsCount > 0 ||
        requiredActions.isNotEmpty ||
        recentActivities.isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'company': company.toJson(),
        'stats': stats.toJson(),
        'required_actions': requiredActions
            .map((item) => item.toJson())
            .toList(growable: false),
        'recent_activities': recentActivities
            .map((item) => item.toJson())
            .toList(growable: false),
      },
    };
  }
}

class CompanyHomeCompany {
  final int id;
  final String name;

  const CompanyHomeCompany({
    required this.id,
    required this.name,
  });

  factory CompanyHomeCompany.fromJson(Map<String, dynamic> json) {
    return CompanyHomeCompany(
      id: _asInt(json['id']),
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

class CompanyHomeStats {
  final CompanyHomeActiveOpportunities activeOpportunities;
  final CompanyHomeNewApplicants newApplicants;
  final CompanyHomeAssignmentStat activeAssignments;
  final CompanyHomeAssignmentStat pendingReviews;

  const CompanyHomeStats({
    required this.activeOpportunities,
    required this.newApplicants,
    required this.activeAssignments,
    required this.pendingReviews,
  });

  int get activeOpportunitiesCount => activeOpportunities.count;

  int get newApplicantsCount => newApplicants.count;

  int get activeAssignmentsCount => activeAssignments.count;

  int get pendingReviewsCount => pendingReviews.count;

  factory CompanyHomeStats.fromJson(Map<String, dynamic> json) {
    return CompanyHomeStats(
      activeOpportunities: CompanyHomeActiveOpportunities.fromJson(
        _asMap(json['active_opportunities']),
      ),
      newApplicants: CompanyHomeNewApplicants.fromJson(
        _asMap(json['new_applicants']),
      ),
      activeAssignments: CompanyHomeAssignmentStat.fromJson(
        _asMap(json['active_assignments']),
      ),
      pendingReviews: CompanyHomeAssignmentStat.fromJson(
        _asMap(json['pending_reviews']),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_opportunities': activeOpportunities.toJson(),
      'new_applicants': newApplicants.toJson(),
      'active_assignments': activeAssignments.toJson(),
      'pending_reviews': pendingReviews.toJson(),
    };
  }
}

class CompanyHomeActiveOpportunities {
  final int count;
  final List<int> ids;

  const CompanyHomeActiveOpportunities({
    required this.count,
    required this.ids,
  });

  factory CompanyHomeActiveOpportunities.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyHomeActiveOpportunities(
      count: _asInt(json['count']),
      ids: _asList(json['ids'])
          .map(_asInt)
          .where((id) => id > 0)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'ids': ids,
    };
  }
}

class CompanyHomeNewApplicants {
  final int count;
  final List<CompanyHomeNewApplicantItem> items;

  const CompanyHomeNewApplicants({
    required this.count,
    required this.items,
  });

  factory CompanyHomeNewApplicants.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyHomeNewApplicants(
      count: _asInt(json['count']),
      items: _asList(json['items'])
          .map(
            (item) => CompanyHomeNewApplicantItem.fromJson(
              _asMap(item),
            ),
          )
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'items': items
          .map((item) => item.toJson())
          .toList(growable: false),
    };
  }
}

class CompanyHomeNewApplicantItem {
  final int applicationId;
  final int studentUserId;
  final int taskId;

  const CompanyHomeNewApplicantItem({
    required this.applicationId,
    required this.studentUserId,
    required this.taskId,
  });

  factory CompanyHomeNewApplicantItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyHomeNewApplicantItem(
      applicationId: _asInt(json['application_id']),
      studentUserId: _asInt(json['student_user_id']),
      taskId: _asInt(json['task_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'application_id': applicationId,
      'student_user_id': studentUserId,
      'task_id': taskId,
    };
  }
}

class CompanyHomeAssignmentStat {
  final int count;
  final List<CompanyHomeAssignmentItem> items;

  const CompanyHomeAssignmentStat({
    required this.count,
    required this.items,
  });

  factory CompanyHomeAssignmentStat.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyHomeAssignmentStat(
      count: _asInt(json['count']),
      items: _asList(json['items'])
          .map(
            (item) => CompanyHomeAssignmentItem.fromJson(
              _asMap(item),
            ),
          )
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'items': items
          .map((item) => item.toJson())
          .toList(growable: false),
    };
  }
}

class CompanyHomeAssignmentItem {
  final int assignmentId;
  final int taskId;
  final int studentUserId;

  const CompanyHomeAssignmentItem({
    required this.assignmentId,
    required this.taskId,
    required this.studentUserId,
  });

  factory CompanyHomeAssignmentItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyHomeAssignmentItem(
      assignmentId: _asInt(json['assignment_id']),
      taskId: _asInt(json['task_id']),
      studentUserId: _asInt(json['student_user_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignment_id': assignmentId,
      'task_id': taskId,
      'student_user_id': studentUserId,
    };
  }
}

class CompanyRequiredAction {
  final String type;
  final String title;
  final String description;
  final String actionLabel;
  final String targetType;
  final int targetId;
  final int? studentUserId;
  final int? taskId;

  const CompanyRequiredAction({
    required this.type,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.targetType,
    required this.targetId,
    this.studentUserId,
    this.taskId,
  });

  factory CompanyRequiredAction.fromJson(Map<String, dynamic> json) {
    return CompanyRequiredAction(
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      actionLabel: json['action_label']?.toString() ?? '',
      targetType: json['target_type']?.toString() ?? '',
      targetId: _asInt(json['target_id']),
      studentUserId: _asNullableInt(
        json['student_user_id'],
      ),
      taskId: _asNullableInt(
        json['task_id'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'action_label': actionLabel,
      'target_type': targetType,
      'target_id': targetId,
      if (studentUserId != null)
        'student_user_id': studentUserId,
      if (taskId != null) 'task_id': taskId,
    };
  }
}

class CompanyRecentActivity {
  final String type;
  final String title;
  final String description;
  final String actionLabel;
  final String targetType;
  final int targetId;

  const CompanyRecentActivity({
    required this.type,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.targetType,
    required this.targetId,
  });

  factory CompanyRecentActivity.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyRecentActivity(
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      actionLabel: json['action_label']?.toString() ?? '',
      targetType: json['target_type']?.toString() ?? '',
      targetId: _asInt(json['target_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'action_label': actionLabel,
      'target_type': targetType,
      'target_id': targetId,
    };
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return value.map(
      (key, value) => MapEntry(
        key.toString(),
        value,
      ),
    );
  }

  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) {
    return value;
  }

  return const <dynamic>[];
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

int? _asNullableInt(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(
    value.toString(),
  );
}