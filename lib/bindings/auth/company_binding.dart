import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/register_company_controller.dart';

class CompanyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RegisterCompanyController());
  }
}