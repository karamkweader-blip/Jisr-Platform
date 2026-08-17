import 'package:jisr_platform/models/company/opportunities/company_opportunity_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_model.dart';

enum CompanyFeedKind { task, internship, job }

class CompanyOpportunityFeedItem {
  final int id;
  final String title;
  final String description;
  final String status;
  final DateTime? deadline;
  final CompanyFeedKind kind;
  final int applicationsCount;
  final String meta;

  const CompanyOpportunityFeedItem({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.deadline,
    required this.kind,
    required this.applicationsCount,
    required this.meta,
  });

  factory CompanyOpportunityFeedItem.fromTask(CompanyTaskModel task) {
    return CompanyOpportunityFeedItem(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      deadline: task.deadline,
      kind: CompanyFeedKind.task,
      applicationsCount: task.maxApplicants,
      meta: '${task.durationDays} يوم',
    );
  }

  factory CompanyOpportunityFeedItem.fromOpportunity(
    CompanyOpportunityModel opportunity,
  ) {
    return CompanyOpportunityFeedItem(
      id: opportunity.id,
      title: opportunity.title,
      description: opportunity.description,
      status: opportunity.status,
      deadline: opportunity.deadline,
      kind: opportunity.type == 'job'
          ? CompanyFeedKind.job
          : CompanyFeedKind.internship,
      applicationsCount: opportunity.applicationsCount,
      meta: opportunity.location,
    );
  }
}
