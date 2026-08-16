import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/opportunities/company_opportunity_form_controller.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/opportunities/company_opportunity_service.dart';
import 'package:jisr_platform/services/company/tasks/company_task_service.dart';

class CompanyOpportunityFormBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) Get.lazyPut<AuthService>(AuthService.new);
    if (!Get.isRegistered<CompanyOpportunityService>()) {
      Get.lazyPut<CompanyOpportunityService>(
        () => CompanyOpportunityService(Get.find<AuthService>()),
      );
    }
    if (!Get.isRegistered<CompanyTaskService>()) {
      Get.lazyPut<CompanyTaskService>(
        () => CompanyTaskService(Get.find<AuthService>()),
      );
    }
    Get.lazyPut<CompanyOpportunityFormController>(
      () => CompanyOpportunityFormController(
        Get.find<CompanyOpportunityService>(),
        Get.find<CompanyTaskService>(),
      ),
    );
  }
}
