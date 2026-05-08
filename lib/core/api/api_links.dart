class ApiLinks {
  static const String baseUrl = 'http://192.168.50.46:8001/api';

  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String verifyLoginOtp = '$baseUrl/login/verify-otp';
<<<<<<< Updated upstream
=======
  static const String logout = '$baseUrl/logout';
  static const String logoutAll = '$baseUrl/logout-all';
  static const String uploadCv = '$baseUrl/cvs/upload';
  static String analyzeCv(int cvId) => '$baseUrl/cvs/$cvId/analyze';
>>>>>>> Stashed changes
}
