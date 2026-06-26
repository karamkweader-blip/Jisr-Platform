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
  //مهمامي المسندة
  static const studentAssignedTasks = '/student-assigned-tasks';
  //تاسكاتي
  static const studentTaskApplications = '/student-task-applications';
  static const studentTaskProgress = '/student-task-progress';
  //محادثات
  static const studentConversations = '/student-conversations';
  static const studentChat = '/student-chat';
  /////company
  static const companyMain = '/company-main';
  static const companyHome = '/company-home';
  static const editCompanyProfile = '/company/profile/edit';
  static const createCompanyTask = '/company/tasks/create';
}
