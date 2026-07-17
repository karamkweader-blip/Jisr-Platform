import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/auth_actions_controller.dart';
import 'package:jisr_platform/controllers/company/company_main_controller.dart';
import 'package:jisr_platform/controllers/company/home/company_home_controller.dart';
import 'package:jisr_platform/controllers/company/profile/company_profile_controller.dart';
import 'package:jisr_platform/controllers/company/tasks/company_tasks_controller.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/company_home_service.dart';
import 'package:jisr_platform/services/company/company_profile_service.dart';
import 'package:jisr_platform/services/company/tasks/company_task_assignments_service.dart';
import 'package:jisr_platform/services/company/tasks/company_task_service.dart';

class CompanyMainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompanyMainController>(
      () => CompanyMainController(),
    );

    Get.lazyPut<AuthService>(
      () => AuthService(),
    );

    Get.lazyPut<CompanyHomeService>(
      () => CompanyHomeService(
        Get.find<AuthService>(),
      ),
    );

    Get.lazyPut<CompanyTaskAssignmentsService>(
      () => CompanyTaskAssignmentsService(
        Get.find<AuthService>(),
      ),
    );

    Get.lazyPut<CompanyHomeController>(
      () => CompanyHomeController(
        Get.find<CompanyHomeService>(),
        Get.find<CompanyTaskAssignmentsService>(),
      ),
    );

    Get.lazyPut<CompanyTaskService>(
      () => CompanyTaskService(
        Get.find<AuthService>(),
      ),
    );

    Get.lazyPut<CompanyTasksController>(
      () => CompanyTasksController(
        Get.find<CompanyTaskService>(),
      ),
    );

    Get.lazyPut<CompanyProfileService>(
      () => CompanyProfileService(
        Get.find<AuthService>(),
      ),
    );

    Get.lazyPut<CompanyProfileController>(
      () => CompanyProfileController(
        Get.find<CompanyProfileService>(),
      ),
    );

    if (!Get.isRegistered<AuthActionsController>()) {
      Get.lazyPut<AuthActionsController>(
        () => AuthActionsController(),
        fenix: true,
      );
    }
  }
}