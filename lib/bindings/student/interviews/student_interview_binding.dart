import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/interviews/student_interview_controller.dart';

class StudentInterviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentInterviewController>(() => StudentInterviewController());
  }
}
