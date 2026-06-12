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
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return CompanyHomeModel(
      company: CompanyHomeCompany.fromJson(
        data['company'] as Map<String, dynamic>? ?? {},
      ),
      stats: CompanyHomeStats.fromJson(
        data['stats'] as Map<String, dynamic>? ?? {},
      ),
      requiredActions: (data['required_actions'] as List? ?? [])
          .map((item) => CompanyRequiredAction.fromJson(
                item as Map<String, dynamic>? ?? {},
              ))
          .toList(),
      recentActivities: (data['recent_activities'] as List? ?? [])
          .map((item) => CompanyRecentActivity.fromJson(
                item as Map<String, dynamic>? ?? {},
              ))
          .toList(),
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
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }
}

class CompanyHomeStats {
  final int activeOpportunitiesCount;
  final int newApplicantsCount;
  final int pendingReviewsCount;
  final int activeAssignmentsCount;

  const CompanyHomeStats({
    required this.activeOpportunitiesCount,
    required this.newApplicantsCount,
    required this.pendingReviewsCount,
    required this.activeAssignmentsCount,
  });

  factory CompanyHomeStats.fromJson(Map<String, dynamic> json) {
    return CompanyHomeStats(
      activeOpportunitiesCount: json['active_opportunities_count'] as int? ?? 0,
      newApplicantsCount: json['new_applicants_count'] as int? ?? 0,
      pendingReviewsCount: json['pending_reviews_count'] as int? ?? 0,
      activeAssignmentsCount: json['active_assignments_count'] as int? ?? 0,
    );
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
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      actionLabel: json['action_label'] as String? ?? '',
      targetType: json['target_type'] as String? ?? '',
      targetId: json['target_id'] as int? ?? 0,
      studentUserId: json['student_user_id'] as int?,
      taskId: json['task_id'] as int?,
    );
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

  factory CompanyRecentActivity.fromJson(Map<String, dynamic> json) {
    return CompanyRecentActivity(
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      actionLabel: json['action_label'] as String? ?? '',
      targetType: json['target_type'] as String? ?? '',
      targetId: json['target_id'] as int? ?? 0,
    );
  }
}