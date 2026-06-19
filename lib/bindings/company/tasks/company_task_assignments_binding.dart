import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/tasks/company_task_assignments_controller.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/tasks/company_task_assignments_service.dart';

class CompanyTaskAssignmentsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) {
      Get.lazyPut<AuthService>(() => AuthService());
    }

    if (!Get.isRegistered<CompanyTaskAssignmentsService>()) {
      Get.lazyPut<CompanyTaskAssignmentsService>(
        () => CompanyTaskAssignmentsService(
          Get.find<AuthService>(),
        ),
      );
    }

    Get.lazyPut<CompanyTaskAssignmentsController>(
      () => CompanyTaskAssignmentsController(
        Get.find<CompanyTaskAssignmentsService>(),
      ),
    );
  }
}