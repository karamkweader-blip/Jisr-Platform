import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/opportunities/company_opportunity_interview_controller.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/opportunities/company_opportunity_interview_service.dart';

class CompanyOpportunityInterviewBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) Get.lazyPut<AuthService>(AuthService.new);
    if (!Get.isRegistered<CompanyOpportunityInterviewService>()) {
      Get.lazyPut<CompanyOpportunityInterviewService>(
        () => CompanyOpportunityInterviewService(Get.find<AuthService>()),
      );
    }
    Get.lazyPut<CompanyOpportunityInterviewController>(
      () => CompanyOpportunityInterviewController(
        Get.find<CompanyOpportunityInterviewService>(),
      ),
    );
  }
}
