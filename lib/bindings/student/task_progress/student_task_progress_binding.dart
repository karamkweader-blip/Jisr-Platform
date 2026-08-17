import 'package:get/get.dart';
import 'package:jisr_platform/bindings/student/complaints/complaint_binding.dart';
import 'package:jisr_platform/controllers/student/task_progress/student_task_progress_controller.dart';

class StudentTaskProgressBinding extends Bindings {
  @override
  void dependencies() {
    ComplaintBinding.register();
    Get.lazyPut<StudentTaskProgressController>(
      () => StudentTaskProgressController(),
    );
  }
}
