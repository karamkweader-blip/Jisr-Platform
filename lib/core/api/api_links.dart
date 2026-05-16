class ApiLinks {
  static const String baseUrl = 'http://192.168.50.37:8001/api';

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

  //////company
}
