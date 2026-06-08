import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/create_company_task_controller.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/company_task_service.dart';

class CreateCompanyTaskBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) {
      Get.lazyPut<AuthService>(() => AuthService());
    }

    if (!Get.isRegistered<CompanyTaskService>()) {
      Get.lazyPut<CompanyTaskService>(
        () => CompanyTaskService(Get.find<AuthService>()),
      );
    }

    Get.lazyPut<CreateCompanyTaskController>(
      () => CreateCompanyTaskController(Get.find<CompanyTaskService>()),
    );
  }
}