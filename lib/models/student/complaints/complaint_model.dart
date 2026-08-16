abstract class ComplaintContextTypes {
  static const String projectAssignment = 'project_assignment';
  static const String companyTaskAssignment = 'company_task_assignment';
  static const String opportunityInterview = 'opportunity_interview';
  static const String communityPost = 'community_post';
  static const String communityComment = 'community_comment';
  static const String mentorProfile = 'mentor_profile';

  static const Set<String> values = <String>{
    projectAssignment,
    companyTaskAssignment,
    opportunityInterview,
    communityPost,
    communityComment,
    mentorProfile,
  };
}

class ComplaintRequestModel {
  final String contextType;
  final int contextId;
  final String reason;

  const ComplaintRequestModel({
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

class ComplaintSubmissionResponse {
  final String message;
  final ComplaintSubmissionModel complaint;

  const ComplaintSubmissionResponse({
    required this.message,
    required this.complaint,
  });

  factory ComplaintSubmissionResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return ComplaintSubmissionResponse(
      message: json['message']?.toString() ?? 'تم إرسال الشكوى بنجاح',
      complaint: ComplaintSubmissionModel.fromJson(
        rawData is Map
            ? Map<String, dynamic>.from(rawData)
            : const <String, dynamic>{},
      ),
    );
  }
}

class ComplaintSubmissionModel {
  final int id;
  final String targetType;
  final String contextType;
  final int contextId;
  final String reason;
  final String status;
  final String? createdAt;

  const ComplaintSubmissionModel({
    required this.id,
    required this.targetType,
    required this.contextType,
    required this.contextId,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory ComplaintSubmissionModel.fromJson(Map<String, dynamic> json) {
    final rawContext = json['context'];
    final context = rawContext is Map
        ? Map<String, dynamic>.from(rawContext)
        : const <String, dynamic>{};

    return ComplaintSubmissionModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      targetType: json['target_type']?.toString() ?? '',
      contextType: context['type']?.toString() ?? '',
      contextId: int.tryParse(context['id'].toString()) ?? 0,
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
    );
  }
}
