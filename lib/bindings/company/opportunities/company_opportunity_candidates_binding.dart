import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/opportunities/company_opportunity_candidates_controller.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/opportunities/company_opportunity_candidate_service.dart';

class CompanyOpportunityCandidatesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) Get.lazyPut<AuthService>(AuthService.new);
    if (!Get.isRegistered<CompanyOpportunityCandidateService>()) {
      Get.lazyPut<CompanyOpportunityCandidateService>(
        () => CompanyOpportunityCandidateService(Get.find<AuthService>()),
      );
    }
    Get.lazyPut<CompanyOpportunityCandidatesController>(
      () => CompanyOpportunityCandidatesController(
        Get.find<CompanyOpportunityCandidateService>(),
      ),
    );
  }
}
