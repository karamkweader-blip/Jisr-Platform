import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/supervisor_projects/student_supervisor_project_controller.dart';

class StudentSupervisorProjectBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<StudentSupervisorProjectController>()) {
      Get.lazyPut<StudentSupervisorProjectController>(
        StudentSupervisorProjectController.new,
      );
    }
  }
}
