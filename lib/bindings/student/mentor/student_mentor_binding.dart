import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/mentor/student_mentor_controller.dart';

class StudentMentorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentMentorController>(() => StudentMentorController());
  }
}
