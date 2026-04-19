import 'package:get/get.dart';
import 'package:jisr_platform/bindings/auth/company_binding.dart';
import 'package:jisr_platform/bindings/auth/login_binding.dart';
import 'package:jisr_platform/bindings/auth/role_binding.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/views/auth/login.dart';
import 'package:jisr_platform/views/auth/company/register_company_view.dart';
import 'package:jisr_platform/views/auth/role_selection.dart';


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
      binding: CompanyBinding(),
    ),
   
  ];
}