import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/tasks/company_task_applicant_details_controller.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/tasks/company_task_applicant_details_service.dart';

class CompanyTaskApplicantDetailsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) {
      Get.lazyPut<AuthService>(() => AuthService());
    }

    Get.lazyPut<CompanyTaskApplicantDetailsService>(
      () => CompanyTaskApplicantDetailsService(
        Get.find<AuthService>(),
      ),
    );

    Get.lazyPut<CompanyTaskApplicantDetailsController>(
      () => CompanyTaskApplicantDetailsController(
        Get.find<CompanyTaskApplicantDetailsService>(),
      ),
    );
  }
}