import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/mentor/company_mentor_nomination_form_controller.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/mentor/company_mentor_nomination_service.dart';

class CompanyMentorNominationFormBinding
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
        CompanyMentorNominationService>()) {
      Get.lazyPut<CompanyMentorNominationService>(
        () => CompanyMentorNominationService(
          Get.find<AuthService>(),
        ),
        fenix: true,
      );
    }

    Get.lazyPut<
        CompanyMentorNominationFormController>(
      () => CompanyMentorNominationFormController(
        Get.find<CompanyMentorNominationService>(),
        Get.find<AuthService>(),
      ),
    );
  }
}