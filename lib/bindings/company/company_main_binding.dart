import 'package:get/get.dart';
import 'package:jisr_platform/bindings/notifications/notifications_binding.dart';
import 'package:jisr_platform/controllers/auth/auth_actions_controller.dart';
import 'package:jisr_platform/controllers/company/company_drawer_controller.dart';
import 'package:jisr_platform/controllers/company/company_main_controller.dart';
import 'package:jisr_platform/controllers/company/conversations/company_conversation_controller.dart';
import 'package:jisr_platform/controllers/company/home/company_home_controller.dart';
import 'package:jisr_platform/controllers/company/opportunities/company_opportunities_controller.dart';
import 'package:jisr_platform/controllers/company/profile/company_profile_controller.dart';
import 'package:jisr_platform/controllers/company/tasks/company_tasks_controller.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/company_home_service.dart';
import 'package:jisr_platform/services/company/company_profile_service.dart';
import 'package:jisr_platform/services/company/complaints/company_complaint_service.dart';
import 'package:jisr_platform/services/company/conversations/company_conversation_service.dart';
import 'package:jisr_platform/services/company/opportunities/company_opportunity_service.dart';
import 'package:jisr_platform/services/company/tasks/company_task_assignments_service.dart';
import 'package:jisr_platform/services/company/tasks/company_task_service.dart';

class CompanyMainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompanyMainController>(
      CompanyMainController.new,
    );

    Get.lazyPut<AuthService>(
      AuthService.new,
    );
    
NotificationsBinding().dependencies();

    if (!Get.isRegistered<AuthActionsController>()) {
      Get.lazyPut<AuthActionsController>(
        AuthActionsController.new,
        fenix: true,
      );
    }

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

if (!Get.isRegistered<CompanyComplaintService>()) {
  Get.lazyPut<CompanyComplaintService>(
    () => CompanyComplaintService(
      Get.find<AuthService>(),
    ),
    fenix: true,
  );
}
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

    Get.lazyPut<CompanyOpportunityService>(
      () => CompanyOpportunityService(
        Get.find<AuthService>(),
      ),
    );

    Get.lazyPut<CompanyOpportunitiesController>(
      () => CompanyOpportunitiesController(
        Get.find<CompanyOpportunityService>(),
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

    Get.lazyPut<CompanyConversationService>(
      () => CompanyConversationService(
        Get.find<AuthService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<CompanyConversationController>(
      () => CompanyConversationController(
        Get.find<CompanyConversationService>(),
        Get.find<AuthService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<CompanyDrawerController>(
      () => CompanyDrawerController(
        authController:
            Get.find<AuthActionsController>(),
        mainController:
            Get.find<CompanyMainController>(),
        profileController:
            Get.find<CompanyProfileController>(),
      ),
    );
  }
}