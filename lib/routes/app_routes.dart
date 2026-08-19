abstract class Routes {
  static const initial = '/';
  static const HOME = '/home';
  /////authentication
  static const login = '/login';
  static const role = '/role';
  static const registerCompany = '/register-company';
  static const registerStudent = '/register-student';
  static const loginOtp = '/login-otp';

  ///reset
  static const forgotPassword = '/forgot-password';
  static const otpVerification = '/otp-verification';
  static const resetPassword = '/reset-password';

  ///student
  static const studentHome = '/student-home';
  static const cvUpload = '/cv-upload';
  static const cvAnalysis = '/cv-analysis';
  static const assessment = '/assessment';
  //ملف شخصي
  static const studentProfile = '/student-profile';
  //بروتفوليم
  static const studentPortfolio = '/student-portfolio';
  static const studentPortfolioDetails = '/student-portfolio-details';
  //task
  static const studentTasks = '/student-tasks';
  static const studentTaskDetails = '/student-task-details';
  //فرص العمل
  static const studentOpportunities = '/student-opportunities';
  static const studentOpportunityDetails = '/student-opportunity-details';
  static const studentOpportunityApplications =
      '/student-opportunity-applications';
  static const studentOpportunityApplicationDetails =
      '/student-opportunity-application-details';
  //مهمامي المسندة
  static const studentAssignedTasks = '/student-assigned-tasks';
  //تاسكاتي
  static const studentTaskApplications = '/student-task-applications';
  static const studentTaskProgress = '/student-task-progress';
  //محادثات
  static const studentConversations = '/student-conversations';
  static const studentChat = '/student-chat';
  // مساعد جسر الذكي
  static const studentChatbot = '/student-chatbot';
  static const studentChatbotChat = '/student-chatbot/chat';
  // بوستات مجتمع تقني
  static const studentCommunityPosts = '/student-community-posts';
  // نقاط الطالب
  static const studentPoints = '/student-points';
  // تحليل سوق العمل
  static const studentMarketAnalysis = '/student-market-analysis';
  // الإرشاد المهني
  static const studentMentors = '/student-mentors';
  static const studentMentorDetails = '/student-mentors/details';
  /////company
  static const companyMain = '/company-main';
  static const companyMarketAnalysis = '/company/market-analysis';
  static const companyHome = '/company-home';
  static const editCompanyProfile = '/company/profile/edit';
  /////tasks
  static const createCompanyTask = '/company/tasks/create';
  static const companyTaskDetails = '/company/tasks/details';
  static const companyTaskApplicantDetails = '/company/tasks/applicant-details';
  static const companyTaskApplicants = '/company/tasks/applicants';
  static const companyTaskAssignments = '/company/task-assignments';
  static const companyTaskAssignmentWorkspace =
      '/company/task-assignments/workspace';
  //// opportunities
  static const companyOpportunityForm = '/company/opportunities/form';
  static const companyOpportunityDetails = '/company/opportunities/details';
  static const companyOpportunityCandidates =
      '/company/opportunities/candidates';
  static const companyOpportunityCandidateDetails =
      '/company/opportunities/candidates/details';
  static const companyOpportunityInterview =
      '/company/opportunities/interview';
  //// conversations
  static const companyChat = '/company/conversations/chat';

  static const String companyMentorNominations =
    '/company/mentor-nominations';

static const String companyMentorNominationForm =
    '/company/mentor-nominations/create';

static const companyComplaints = '/company/complaints';
}
