import 'package:get/get.dart';
import 'package:jisr_platform/bindings/auth/company_binding.dart';
import 'package:jisr_platform/bindings/auth/forget-password/forgot_password_binding.dart';
import 'package:jisr_platform/bindings/auth/login_binding.dart';
import 'package:jisr_platform/bindings/auth/forget-password/otp_verification_binding.dart';
import 'package:jisr_platform/bindings/auth/register_student_binding.dart';
import 'package:jisr_platform/bindings/auth/forget-password/reset_password_binding.dart';
import 'package:jisr_platform/bindings/auth/role_binding.dart';
import 'package:jisr_platform/bindings/company/company_home_binding.dart';
import 'package:jisr_platform/bindings/student/cv/cv_upload_binding.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/views/auth/forget&reset/forgot_password_view.dart';
import 'package:jisr_platform/views/auth/login/login.dart';
import 'package:jisr_platform/views/auth/company/register_company_view.dart';
import 'package:jisr_platform/views/auth/forget&reset/otp_verification_view.dart';
import 'package:jisr_platform/views/auth/forget&reset/reset_password_view.dart';
import 'package:jisr_platform/views/auth/role_selection.dart';
import 'package:jisr_platform/views/company/company_home_view.dart';
import 'package:jisr_platform/views/student/home/home_view.dart';
import 'package:jisr_platform/views/auth/login/login_otp_view.dart';
import 'package:jisr_platform/views/auth/student/register_student_view.dart';
import 'package:jisr_platform/bindings/auth/login_otp_binding.dart';
import 'package:jisr_platform/bindings/student/home/home_binding.dart';
import 'package:jisr_platform/views/student/cv/cv_upload_view.dart';
import 'package:jisr_platform/bindings/student/cv/cv_analysis_binding.dart';
import 'package:jisr_platform/views/student/cv/cv_analysis_view.dart';

import 'package:jisr_platform/bindings/student/assessment/assessment_binding.dart';
import 'package:jisr_platform/views/student/assessment/assessment_view.dart';
import 'package:jisr_platform/bindings/student/profile/student_profile_binding.dart';
import 'package:jisr_platform/views/student/profile/student_profile_view.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),

    GetPage(
      name: Routes.role,
      page: () => const RoleSelectionPage(),
      binding: RoleBinding(),
    ),
    GetPage(
      name: Routes.registerCompany,
      page: () => const RegisterCompanyView(),
      binding: RegisterCompanyBinding(),
    ),
    GetPage(
      name: Routes.registerStudent,
      page: () => const RegisterStudentView(),
      binding: RegisterStudentBinding(),
    ),

    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),

    GetPage(
      name: Routes.otpVerification,
      page: () => const OtpVerificationView(),
      binding: OtpVerificationBinding(),
    ),

    GetPage(
      name: Routes.resetPassword,
      page: () => const ResetPasswordView(),
      binding: ResetPasswordBinding(),
    ),

    GetPage(
      name: Routes.loginOtp,
      page: () => const LoginOtpView(),
      binding: LoginOtpBinding(),
    ),

    GetPage(
      name: Routes.studentHome,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),

    GetPage(
      name: Routes.cvUpload,
      page: () => const CvUploadView(),
      binding: CvUploadBinding(),
    ),
    GetPage(
      name: Routes.cvAnalysis,
      page: () => const CvAnalysisView(),
      binding: CvAnalysisBinding(),
    ),

    GetPage(
      name: Routes.companyHome,
      page: () => const CompanyHomeView(),
      binding: CompanyHomeBinding(),
    ),

    GetPage(
      name: Routes.assessment,
      page: () => const AssessmentView(),
      binding: AssessmentBinding(),
    ),

    GetPage(
      name: Routes.studentProfile,
      page: () => const StudentProfileView(),
      binding: StudentProfileBinding(),
    ),
  ];
}
