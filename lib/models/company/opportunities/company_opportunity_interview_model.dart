import 'package:jisr_platform/models/company/opportunities/company_opportunity_model.dart';

class CompanyOpportunityInterview {
  final int id;
  final DateTime? scheduledAt;
  final String meetingType;
  final String? meetingLink;
  final String? location;
  final String status;
  final String notes;
  final OpportunityInterviewActions actions;
  final OpportunityInterviewConversation? conversation;

  const CompanyOpportunityInterview({
    required this.id,
    required this.scheduledAt,
    required this.meetingType,
    required this.meetingLink,
    required this.location,
    required this.status,
    required this.notes,
    required this.actions,
    required this.conversation,
  });

  factory CompanyOpportunityInterview.fromJson(Map<String, dynamic> json) {
    return CompanyOpportunityInterview(
      id: opportunityInt(json['id']),
      scheduledAt: opportunityDate(json['scheduled_at']),
      meetingType: json['meeting_type']?.toString() ?? '',
      meetingLink: json['meeting_link']?.toString(),
      location: json['location']?.toString(),
      status: json['status']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      actions: OpportunityInterviewActions.fromJson(
        opportunityMap(json['actions']),
      ),
      conversation: json['conversation'] is Map
          ? OpportunityInterviewConversation.fromJson(
              opportunityMap(json['conversation']),
            )
          : null,
    );
  }

  bool get canReschedule => actions.canReschedule;
  bool get canCancel => actions.canCancel;
  bool get canComplete => actions.canComplete;
}

class OpportunityInterviewActions {
  final bool canReschedule;
  final bool canCancel;
  final bool canComplete;

  const OpportunityInterviewActions({
    required this.canReschedule,
    required this.canCancel,
    required this.canComplete,
  });

  factory OpportunityInterviewActions.fromJson(Map<String, dynamic> json) {
    return OpportunityInterviewActions(
      canReschedule: opportunityBool(json['can_reschedule']),
      canCancel: opportunityBool(json['can_cancel']),
      canComplete: opportunityBool(json['can_complete']),
    );
  }
}

class OpportunityInterviewConversation {
  final int id;
  final String status;

  const OpportunityInterviewConversation({required this.id, required this.status});

  factory OpportunityInterviewConversation.fromJson(Map<String, dynamic> json) {
    return OpportunityInterviewConversation(
      id: opportunityInt(json['id']),
      status: json['status']?.toString() ?? '',
    );
  }
}

class SaveOpportunityInterviewRequest {
  final String meetingType;
  final String? meetingLink;
  final String? location;
  final String? notes;
  final String scheduledAt;

  const SaveOpportunityInterviewRequest({
    required this.meetingType,
    required this.meetingLink,
    required this.location,
    required this.notes,
    required this.scheduledAt,
  });

  Map<String, String> toFormFields() {
    return {
      'meeting_type': meetingType,
      'scheduled_at': scheduledAt,
      if (meetingLink != null && meetingLink!.trim().isNotEmpty)
        'meeting_link': meetingLink!.trim(),
      if (location != null && location!.trim().isNotEmpty)
        'location': location!.trim(),
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }
}
