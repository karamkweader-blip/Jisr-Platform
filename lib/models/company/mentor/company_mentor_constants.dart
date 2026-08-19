class CompanyMentorSpecializations {
  static const String backend = 'backend';
  static const String frontend = 'frontend';
  static const String flutter = 'flutter';
  static const String ai = 'ai';
  static const String devops = 'devops';

  static const List<String> values = <String>[
    backend,
    frontend,
    flutter,
    ai,
    devops,
  ];

  static String label(String value) {
    switch (value) {
      case backend:
        return 'Backend';
      case frontend:
        return 'Frontend';
      case flutter:
        return 'Flutter';
      case ai:
        return 'AI';
      case devops:
        return 'DevOps';
      default:
        return value;
    }
  }
}

class CompanyMentorTopics {
  static const String careerGuidance = 'career_guidance';
  static const String projectReview = 'project_review';
  static const String interviewPreparation = 'interview_preparation';
  static const String cvReview = 'cv_review';

  static const List<String> values = <String>[
    careerGuidance,
    projectReview,
    interviewPreparation,
    cvReview,
  ];

  static String label(String value) {
    switch (value) {
      case careerGuidance:
        return 'الإرشاد المهني';
      case projectReview:
        return 'مراجعة المشاريع';
      case interviewPreparation:
        return 'التحضير للمقابلات';
      case cvReview:
        return 'مراجعة السيرة الذاتية';
      default:
        return value;
    }
  }
}

class CompanyMentorNominationStatuses {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';

  static const List<String> values = <String>[
    pending,
    approved,
    rejected,
  ];

  static String label(String value) {
    switch (value) {
      case pending:
        return 'قيد المراجعة';
      case approved:
        return 'تمت الموافقة';
      case rejected:
        return 'مرفوض';
      default:
        return value.isEmpty ? 'غير محدد' : value;
    }
  }
}