import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/task_applications/student_task_application_controller.dart';

class StudentTaskApplicationBinding extends Bindings {
  @override
  void dependencies() {
    // استخدام lazyPut يضمن مرونة تامة وعدم تعليق الملاحة (Navigation)
    Get.lazyPut<StudentTaskApplicationController>(
      () => StudentTaskApplicationController(),
    );
  }
}
