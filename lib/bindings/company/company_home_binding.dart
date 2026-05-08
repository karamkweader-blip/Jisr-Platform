import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/company_home_controller.dart';

class CompanyHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompanyHomeController>(() => CompanyHomeController());
  }
}