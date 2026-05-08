class ApiLinks {
  static const String baseUrl = 'http://10.33.50.250:8000/api';
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';

  static const String forgotPassword = '$baseUrl/password/forgot';
  static const String verifyResetOtp = '$baseUrl/password/reset/verify-otp';
  static const String resendResetOtp = '$baseUrl/otp/resend';
  static const String resetPassword  = '$baseUrl/password/reset';


  static const String verifyLoginOtp = '$baseUrl/login/verify-otp';
  static const String logout = '$baseUrl/logout';
  static const String logoutAll = '$baseUrl/logout-all';
}
