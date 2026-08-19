import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/opportunities/company_opportunity_candidates_controller.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/opportunities/company_opportunity_candidate_service.dart';
import 'package:jisr_platform/services/company/opportunities/company_opportunity_matching_service.dart';

class CompanyOpportunityCandidatesBinding
    extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) {
      Get.lazyPut<AuthService>(
        AuthService.new,
        fenix: true,
      );
    }

    if (!Get.isRegistered<
        CompanyOpportunityCandidateService>()) {
      Get.lazyPut<
          CompanyOpportunityCandidateService>(
        () => CompanyOpportunityCandidateService(
          Get.find<AuthService>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<
        CompanyOpportunityMatchingService>()) {
      Get.lazyPut<
          CompanyOpportunityMatchingService>(
        () => CompanyOpportunityMatchingService(
          Get.find<AuthService>(),
        ),
        fenix: true,
      );
    }

    Get.lazyPut<
        CompanyOpportunityCandidatesController>(
      () =>
          CompanyOpportunityCandidatesController(
        Get.find<
            CompanyOpportunityCandidateService>(),
        Get.find<
            CompanyOpp  ortunityMatchingService>(),
        Get.find<AuthService>(),
      ),
    );
  }
}