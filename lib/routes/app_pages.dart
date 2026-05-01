import 'package:get/get.dart';
import 'package:jisr_platform/bindings/auth/company_binding.dart';
import 'package:jisr_platform/bindings/auth/forget-password/forgot_password_binding.dart';
import 'package:jisr_platform/bindings/auth/login_binding.dart';
import 'package:jisr_platform/bindings/auth/otp_verification_binding.dart';
import 'package:jisr_platform/bindings/auth/register_student_binding.dart';
import 'package:jisr_platform/bindings/auth/forget-password/reset_password_binding.dart';
import 'package:jisr_platform/bindings/auth/role_binding.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/views/auth/forgot_password_view.dart';
import 'package:jisr_platform/views/auth/login.dart';
import 'package:jisr_platform/views/auth/company/register_company_view.dart';
import 'package:jisr_platform/views/auth/otp_verification_view.dart';
import 'package:jisr_platform/views/auth/reset_password_view.dart';
import 'package:jisr_platform/views/auth/role_selection.dart';
import 'package:jisr_platform/views/auth/student/login_otp_view.dart';
import 'package:jisr_platform/views/auth/student/register_student_view.dart';
import 'package:jisr_platform/bindings/auth/login_otp_binding.dart';

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
  ];
}
