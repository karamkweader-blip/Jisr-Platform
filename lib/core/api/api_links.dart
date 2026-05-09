class ApiLinks {
  static const String baseUrl = 'http://10.33.50.250:8000/api';

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
  static const String resetPassword  = '$baseUrl/password/reset';


///////student
  static const String uploadCv = '$baseUrl/cvs/upload';
  static String analyzeCv(int cvId) => '$baseUrl/cvs/$cvId/analyze';

//////company


}
