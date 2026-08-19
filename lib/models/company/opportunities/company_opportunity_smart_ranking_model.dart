import 'package:jisr_platform/models/company/opportunities/company_opportunity_model.dart';

class CompanyOpportunitySmartRankingResponse {
  final bool success;
  final String message;
  final List<CompanyOpportunityRankedCandidate> candidates;
  final CompanyOpportunityRankingMeta meta;

  const CompanyOpportunitySmartRankingResponse({
    required this.success,
    required this.message,
    required this.candidates,
    required this.meta,
  });

  factory CompanyOpportunitySmartRankingResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyOpportunitySmartRankingResponse(
      success: opportunityBool(json['success']),
      message: json['message']?.toString() ?? '',
      candidates: opportunityList(json['data'])
          .map(
            (item) =>
                CompanyOpportunityRankedCandidate.fromJson(
              opportunityMap(item),
            ),
          )
          .where(
            (candidate) =>
                candidate.applicationId > 0 &&
                candidate.student.id > 0,
          )
          .toList(),
      meta: CompanyOpportunityRankingMeta.fromJson(
        opportunityMap(json['meta']),
      ),
    );
  }
}

class CompanyOpportunityRankedCandidate {
  final int rank;
  final int applicationId;
  final String applicationStatus;
  final DateTime? appliedAt;
  final CompanyOpportunityRankedStudent student;
  final CompanyOpportunityRankingScores scores;
  final CompanyOpportunityRankingMetrics metrics;
  final CompanyOpportunityRankingExplanation explanation;

  const CompanyOpportunityRankedCandidate({
    required this.rank,
    required this.applicationId,
    required this.applicationStatus,
    required this.appliedAt,
    required this.student,
    required this.scores,
    required this.metrics,
    required this.explanation,
  });

  factory CompanyOpportunityRankedCandidate.fromJson(
    Map<String, dynamic> json,
  ) {
    final nestedScores = opportunityMap(
      json['scores'],
    );

    final normalizedScores = <String, dynamic>{
      'skill_score':
          nestedScores['skill_score'] ??
              json['skill_score'],
      'project_score':
          nestedScores['project_score'] ??
              json['project_score'],
      'tag_score':
          nestedScores['tag_score'] ??
              json['tag_score'],
      'activity_score':
          nestedScores['activity_score'] ??
              json['activity_score'],
      'freshness_score':
          nestedScores['freshness_score'] ??
              json['freshness'],
      'final_score':
          nestedScores['final_score'] ??
              json['final_score'],
    };

    return CompanyOpportunityRankedCandidate(
      rank: opportunityInt(json['rank']),
      applicationId: opportunityInt(
        json['application_id'],
      ),
      applicationStatus:
          json['application_status']
                  ?.toString() ??
              '',
      appliedAt: opportunityDate(
        json['applied_at'],
      ),
      student:
          CompanyOpportunityRankedStudent.fromJson(
        opportunityMap(json['student']),
      ),
      scores:
          CompanyOpportunityRankingScores.fromJson(
        normalizedScores,
      ),
      metrics:
          CompanyOpportunityRankingMetrics.fromJson(
        opportunityMap(json['metrics']),
      ),
      explanation:
          CompanyOpportunityRankingExplanation.fromJson(
        opportunityMap(json['explanation']),
      ),
    );
  }

  bool get hasMissingMandatorySkills {
    return metrics.missingMandatorySkills.isNotEmpty;
  }
}

class CompanyOpportunityRankedStudent {
  final int id;
  final String name;
  final String email;
  final String? profilePictureUrl;

  const CompanyOpportunityRankedStudent({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
  });

  factory CompanyOpportunityRankedStudent.fromJson(
    Map<String, dynamic> json,
  ) {
    final imageUrl =
        json['profile_picture_url']
            ?.toString()
            .trim();

    return CompanyOpportunityRankedStudent(
      id: opportunityInt(json['id']),
      name: json['name']
                  ?.toString()
                  .trim()
                  .isNotEmpty ==
              true
          ? json['name'].toString().trim()
          : 'طالب',
      email:
          json['email']?.toString().trim() ?? '',
      profilePictureUrl:
          imageUrl == null || imageUrl.isEmpty
              ? null
              : imageUrl,
    );
  }
}

class CompanyOpportunityRankingScores {
  final double skillScore;
  final double projectScore;
  final double tagScore;
  final double activityScore;
  final double freshnessScore;
  final double finalScore;

  const CompanyOpportunityRankingScores({
    required this.skillScore,
    required this.projectScore,
    required this.tagScore,
    required this.activityScore,
    required this.freshnessScore,
    required this.finalScore,
  });

  factory CompanyOpportunityRankingScores.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyOpportunityRankingScores(
      skillScore:
          opportunityDoubleOrNull(
                json['skill_score'],
              ) ??
              0,
      projectScore:
          opportunityDoubleOrNull(
                json['project_score'],
              ) ??
              0,
      tagScore:
          opportunityDoubleOrNull(
                json['tag_score'],
              ) ??
              0,
      activityScore:
          opportunityDoubleOrNull(
                json['activity_score'],
              ) ??
              0,
      freshnessScore:
          opportunityDoubleOrNull(
                json['freshness_score'],
              ) ??
              0,
      finalScore:
          opportunityDoubleOrNull(
                json['final_score'],
              ) ??
              0,
    );
  }
}

class CompanyOpportunityRankingMetrics {
  final int matchedSkillsCount;
  final int partiallyMatchedSkillsCount;
  final int totalSkillsCount;
  final List<String> missingMandatorySkills;
  final int projectEvaluationsCount;
  final int matchedTagsCount;
  final int totalTagsCount;
  final int activityPoints;
  final int freshDays;

  const CompanyOpportunityRankingMetrics({
    required this.matchedSkillsCount,
    required this.partiallyMatchedSkillsCount,
    required this.totalSkillsCount,
    required this.missingMandatorySkills,
    required this.projectEvaluationsCount,
    required this.matchedTagsCount,
    required this.totalTagsCount,
    required this.activityPoints,
    required this.freshDays,
  });

  factory CompanyOpportunityRankingMetrics.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyOpportunityRankingMetrics(
      matchedSkillsCount: opportunityInt(
        json['matched_skills_count'],
      ),
      partiallyMatchedSkillsCount:
          opportunityInt(
        json['partially_matched_skills_count'],
      ),
      totalSkillsCount: opportunityInt(
        json['total_skills_count'],
      ),
      missingMandatorySkills:
          _stringList(
        json['missing_mandatory_skills'],
      ),
      projectEvaluationsCount:
          opportunityInt(
        json['project_evaluations_count'],
      ),
      matchedTagsCount: opportunityInt(
        json['matched_tags_count'],
      ),
      totalTagsCount: opportunityInt(
        json['total_tags_count'],
      ),
      activityPoints: opportunityInt(
        json['activity_points'],
      ),
      freshDays: opportunityInt(
        json['fresh_days'],
      ),
    );
  }
}

class CompanyOpportunityRankingExplanation {
  final List<String> reasons;
  final List<String> missing;

  const CompanyOpportunityRankingExplanation({
    required this.reasons,
    required this.missing,
  });

  factory CompanyOpportunityRankingExplanation.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyOpportunityRankingExplanation(
      reasons: _stringList(json['reasons']),
      missing: _stringList(json['missing']),
    );
  }
}

class CompanyOpportunityRankingMeta {
  final int candidateCount;
  final CompanyOpportunityRankingWeights weights;
  final String scoreScale;

  const CompanyOpportunityRankingMeta({
    required this.candidateCount,
    required this.weights,
    required this.scoreScale,
  });

  factory CompanyOpportunityRankingMeta.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyOpportunityRankingMeta(
      candidateCount: opportunityInt(
        json['candidate_count'],
      ),
      weights:
          CompanyOpportunityRankingWeights.fromJson(
        opportunityMap(json['weights']),
      ),
      scoreScale:
          json['score_scale']?.toString() ?? '0-100',
    );
  }

  static const CompanyOpportunityRankingMeta empty =
      CompanyOpportunityRankingMeta(
    candidateCount: 0,
    weights:
        CompanyOpportunityRankingWeights.empty,
    scoreScale: '0-100',
  );
}

class CompanyOpportunityRankingWeights {
  final double skills;
  final double projects;
  final double tags;
  final double activity;
  final double freshness;

  const CompanyOpportunityRankingWeights({
    required this.skills,
    required this.projects,
    required this.tags,
    required this.activity,
    required this.freshness,
  });

  factory CompanyOpportunityRankingWeights.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyOpportunityRankingWeights(
      skills:
          opportunityDoubleOrNull(
                json['skills'],
              ) ??
              0,
      projects:
          opportunityDoubleOrNull(
                json['projects'],
              ) ??
              0,
      tags:
          opportunityDoubleOrNull(
                json['tags'],
              ) ??
              0,
      activity:
          opportunityDoubleOrNull(
                json['activity'],
              ) ??
              0,
      freshness:
          opportunityDoubleOrNull(
                json['freshness'],
              ) ??
              0,
    );
  }

  static const CompanyOpportunityRankingWeights empty =
      CompanyOpportunityRankingWeights(
    skills: 0,
    projects: 0,
    tags: 0,
    activity: 0,
    freshness: 0,
  );
}

List<String> _stringList(dynamic value) {
  return opportunityList(value)
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList();
}