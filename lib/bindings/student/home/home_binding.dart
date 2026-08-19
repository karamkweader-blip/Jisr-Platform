import 'package:get/get.dart';
import 'package:jisr_platform/bindings/notifications/notifications_binding.dart';
import 'package:jisr_platform/controllers/auth/auth_actions_controller.dart';
import 'package:jisr_platform/controllers/student/home/home_controller.dart';
import 'package:jisr_platform/controllers/student/opportunities/student_opportunity_controller.dart';
import 'package:jisr_platform/controllers/student/opportunity_applications/student_opportunity_application_controller.dart';
import 'package:jisr_platform/controllers/student/task_applications/student_task_application_controller.dart';
import 'package:jisr_platform/controllers/student/tasks/student_task_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {

    NotificationsBinding().dependencies();

    Get.lazyPut<HomeController>(
      () => HomeController(),
    );

    Get.lazyPut<
        StudentOpportunityApplicationController>(
      () =>
          StudentOpportunityApplicationController(),
    );

    Get.lazyPut<
        StudentTaskApplicationController>(
      () =>
          StudentTaskApplicationController(),
    );

    Get.lazyPut<StudentTaskController>(
      () => StudentTaskController(),
    );

    Get.lazyPut<
        StudentOpportunityController>(
      () =>
          StudentOpportunityController(),
    );

    Get.lazyPut<AuthActionsController>(
      () => AuthActionsController(),
      fenix: true,
    );
  }
}