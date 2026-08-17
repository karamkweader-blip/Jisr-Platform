import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/opportunities/company_opportunity_details_controller.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/opportunities/company_opportunity_service.dart';

class CompanyOpportunityDetailsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) Get.lazyPut<AuthService>(AuthService.new);
    if (!Get.isRegistered<CompanyOpportunityService>()) {
      Get.lazyPut<CompanyOpportunityService>(
        () => CompanyOpportunityService(Get.find<AuthService>()),
      );
    }
    Get.lazyPut<CompanyOpportunityDetailsController>(
      () => CompanyOpportunityDetailsController(Get.find<CompanyOpportunityService>()),
    );
  }
}
