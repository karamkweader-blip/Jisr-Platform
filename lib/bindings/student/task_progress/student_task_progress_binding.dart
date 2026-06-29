import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/task_progress/student_task_progress_controller.dart';

class StudentTaskProgressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentTaskProgressController>(
      () => StudentTaskProgressController(),
    );
  }
}
