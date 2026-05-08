abstract class Routes {
  static const initial = '/';

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

/////company
static const companyHome = '/company-home';

}

