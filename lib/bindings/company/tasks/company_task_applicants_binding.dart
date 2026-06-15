import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/tasks/company_task_applicants_controller.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/tasks/company_task_applicants_service.dart';

class CompanyTaskApplicantsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) {
      Get.lazyPut<AuthService>(() => AuthService());
    }

    Get.lazyPut<CompanyTaskApplicantsService>(
      () => CompanyTaskApplicantsService(
        Get.find<AuthService>(),
      ),
    );

    Get.lazyPut<CompanyTaskApplicantsController>(
      () => CompanyTaskApplicantsController(
        Get.find<CompanyTaskApplicantsService>(),
      ),
    );
  }
}