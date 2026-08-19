import 'package:get/get.dart';
import 'package:jisr_platform/bindings/student/complaints/complaint_binding.dart';
import 'package:jisr_platform/controllers/student/assigned_tasks/student_assigned_task_controller.dart';

class StudentAssignedTaskBinding extends Bindings {
  @override
  void dependencies() {
    ComplaintBinding.register();
    Get.lazyPut<StudentAssignedTaskController>(
      () => StudentAssignedTaskController(),
    );
  }
}
