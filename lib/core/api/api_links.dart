class ApiLinks {
  static const String baseUrl = 'http://192.168.50.17:8001/api';

  ////////authentication
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String verifyLoginOtp = '$baseUrl/login/verify-otp';
  static const String logout = '$baseUrl/logout';
  static const String logoutAll = '$baseUrl/logout-all';

  /////////////////reset password
  static const String forgotPassword = '$baseUrl/password/forgot';
  static const String verifyResetOtp = '$baseUrl/password/reset/verify-otp';
  static const String resendResetOtp = '$baseUrl/otp/resend';
  static const String resetPassword = '$baseUrl/password/reset';

  ///////student
  static const String uploadCv = '$baseUrl/cvs/upload';
  static String analyzeCv(int cvId) => '$baseUrl/cvs/$cvId/analyze';
  static const String createAssessment = '$baseUrl/assessments';

  static String nextAssessmentQuestion({
    required int assessmentSessionId,
    required int skillId,
  }) =>
      '$baseUrl/assessments/$assessmentSessionId/skills/$skillId/next-question';

  static String submitAssessmentAnswer({
    required int assessmentSessionId,
    required int attemptId,
  }) => '$baseUrl/assessments/$assessmentSessionId/attempts/$attemptId/answer';
  static String completeAssessment({required int assessmentSessionId}) =>
      '$baseUrl/assessments/$assessmentSessionId/complete';
  static const String studentProfile = '$baseUrl/student/profile';
  static const String editStudentProfile = '$baseUrl/student/profile/edit';
  //بروتفوليم
  static const String portfolioProjects = '$baseUrl/student/portfolio-projects';

  static String portfolioProjectDetails(int projectId) =>
      '$baseUrl/student/portfolio-projects/$projectId';

  static String updatePortfolioProject(int projectId) =>
      '$baseUrl/student/portfolio-projects/$projectId';

  static String deletePortfolioProject(int projectId) =>
      '$baseUrl/student/portfolio-projects/$projectId';
  // tasks
  static const String exploreTasks = '$baseUrl/student/tasks/explore';

  static const String recommendedTasks = '$baseUrl/student/tasks/recommended';

  static String taskDetails(int taskId) => '$baseUrl/student/tasks/$taskId';
  static String applyToTask(int taskId) =>
      '$baseUrl/student/tasks/$taskId/apply';
  //مهامي المسندة
  // assigned tasks
  static const String assignedTasksMock = '';

  static String startAssignedTask(int taskId) =>
      '$baseUrl/supervisor/assignment-tasks/$taskId/start';

  static String submitAssignedTask(int taskId) =>
      '$baseUrl/supervisor/assignment-tasks/$taskId/submit';
  // تاسكاتي
  // my task applications
  static const String allMyTasks = '$baseUrl/student/tasks/allMyTask';
  static const String appliedTasks = '$baseUrl/student/tasks/applied';
  static const String acceptedTasks = '$baseUrl/student/tasks/accepted';
  static const String rejectedTasks = '$baseUrl/student/tasks/rejected';

  // conversations
  static const String taskConversations =
      '$baseUrl/conversations/task-conversations';

  static const String allConversations = '$baseUrl/conversations/all';

  static const String closedConversations = '$baseUrl/conversations/closed';

  static String conversationMessages(int conversationId) =>
      '$baseUrl/conversations/messages/$conversationId';

  static String updateConversationMessage(int messageId) =>
      '$baseUrl/conversations/messages/update/$messageId';

  static String markConversationAsRead(int conversationId) =>
      '$baseUrl/conversations/$conversationId/read';

  // task assignment progress & final submission
  static String taskAssignmentProgress(int assignmentId) =>
      '$baseUrl/student/task-assignments/$assignmentId/progress';

  static String taskAssignmentSubmission(int assignmentId) =>
      '$baseUrl/student/task-assignments/$assignmentId/submission';
  //////company
  static const String companyHome = '$baseUrl/company/home';
  static const String companyTasks = '$baseUrl/company/tasks';
  static const String companyProfile = '$baseUrl/company/profile';
  static const String editCompanyProfile = '$baseUrl/company/profile/edit';

  static String publishCompanyTask(int taskId) =>
      '$baseUrl/company/tasks/$taskId/publish';
  static const String skills = '$baseUrl/skills';
}
