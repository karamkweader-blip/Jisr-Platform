import 'package:jisr_platform/models/company/opportunities/company_opportunity_interview_model.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_model.dart';

class CompanyOpportunityCandidate {
  final int applicationId;
  final OpportunityCandidateStudent student;
  final OpportunityCandidateSummary opportunity;
  final OpportunityCandidateCv? cv;
  final String coverLetter;
  final String applicationStatus;
  final String displayStatus;
  final double? matchScore;
  final List<String> matchReasons;
  final CompanyOpportunityInterview? interview;
  final OpportunityCandidateActions actions;
  final DateTime? reviewedAt;
  final String reviewerNotes;
  final DateTime? appliedAt;
  final DateTime? createdAt;

  const CompanyOpportunityCandidate({
    required this.applicationId,
    required this.student,
    required this.opportunity,
    required this.cv,
    required this.coverLetter,
    required this.applicationStatus,
    required this.displayStatus,
    required this.matchScore,
    required this.matchReasons,
    required this.interview,
    required this.actions,
    required this.reviewedAt,
    required this.reviewerNotes,
    required this.appliedAt,
    required this.createdAt,
  });

  factory CompanyOpportunityCandidate.fromJson(Map<String, dynamic> json) {
    return CompanyOpportunityCandidate(
      applicationId: opportunityInt(json['application_id'] ?? json['id']),
      student: OpportunityCandidateStudent.fromJson(
        opportunityMap(json['student']),
      ),
      opportunity: OpportunityCandidateSummary.fromJson(
        opportunityMap(json['opportunity']),
      ),
      cv: json['cv'] is Map
          ? OpportunityCandidateCv.fromJson(opportunityMap(json['cv']))
          : null,
      coverLetter: json['cover_letter']?.toString() ?? '',
      applicationStatus: json['application_status']?.toString() ?? '',
      displayStatus: json['display_status']?.toString() ?? '',
      matchScore: opportunityDoubleOrNull(json['match_score']),
      matchReasons: opportunityList(json['match_reasons'])
          .map((item) => item.toString())
          .toList(),
      interview: json['interview'] is Map
          ? CompanyOpportunityInterview.fromJson(opportunityMap(json['interview']))
          : null,
      actions: OpportunityCandidateActions.fromJson(
        opportunityMap(json['actions']),
      ),
      reviewedAt: opportunityDate(json['reviewed_at']),
      reviewerNotes: json['reviewer_notes']?.toString() ?? '',
      appliedAt: opportunityDate(json['applied_at']),
      createdAt: opportunityDate(json['created_at']),
    );
  }
}

class OpportunityCandidateCv {
  final int id;
  final String fileUrl;
  final bool isPrimary;
  final DateTime? uploadedAt;

  const OpportunityCandidateCv({
    required this.id,
    required this.fileUrl,
    required this.isPrimary,
    required this.uploadedAt,
  });

  factory OpportunityCandidateCv.fromJson(Map<String, dynamic> json) {
    return OpportunityCandidateCv(
      id: opportunityInt(json['id']),
      fileUrl: json['file_url']?.toString() ?? '',
      isPrimary: opportunityBool(json['is_primary']),
      uploadedAt: opportunityDate(json['uploaded_at']),
    );
  }
}

class OpportunityCandidateStudent {
  final int id;
  final String name;
  final String email;
  final String? profilePictureUrl;
  final String university;
  final String major;
  final int? graduationYear;

  const OpportunityCandidateStudent({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
    required this.university,
    required this.major,
    required this.graduationYear,
  });

  factory OpportunityCandidateStudent.fromJson(Map<String, dynamic> json) {
    final year = opportunityInt(json['graduation_year']);
    return OpportunityCandidateStudent(
      id: opportunityInt(json['id']),
      name: json['name']?.toString() ?? 'طالب',
      email: json['email']?.toString() ?? '',
      profilePictureUrl: json['profile_picture_url']?.toString(),
      university: json['university']?.toString() ?? '',
      major: json['major']?.toString() ?? '',
      graduationYear: year == 0 ? null : year,
    );
  }
}

class OpportunityCandidateSummary {
  final int id;
  final String title;
  final String type;
  final String status;

  const OpportunityCandidateSummary({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
  });

  factory OpportunityCandidateSummary.fromJson(Map<String, dynamic> json) {
    return OpportunityCandidateSummary(
      id: opportunityInt(json['id'] ?? json['id_Resource']),
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

class OpportunityCandidateActions {
  final bool canScheduleInterview;
  final bool canViewInterview;
  final bool canAccept;
  final bool canReject;

  const OpportunityCandidateActions({
    required this.canScheduleInterview,
    required this.canViewInterview,
    required this.canAccept,
    required this.canReject,
  });

  factory OpportunityCandidateActions.fromJson(Map<String, dynamic> json) {
    return OpportunityCandidateActions(
      canScheduleInterview: opportunityBool(json['can_schedule_interview']),
      canViewInterview: opportunityBool(json['can_view_interview']),
      canAccept: opportunityBool(json['can_accept']),
      canReject: opportunityBool(json['can_reject']),
    );
  }
}
