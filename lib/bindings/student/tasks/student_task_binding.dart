import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/tasks/student_task_controller.dart';

class StudentTaskBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentTaskController>(() => StudentTaskController());
  }
}
