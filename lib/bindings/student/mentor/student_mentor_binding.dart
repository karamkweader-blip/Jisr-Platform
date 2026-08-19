import 'package:get/get.dart';
import 'package:jisr_platform/bindings/student/complaints/complaint_binding.dart';
import 'package:jisr_platform/controllers/student/mentor/student_mentor_controller.dart';

class StudentMentorBinding extends Bindings {
  @override
  void dependencies() {
    ComplaintBinding.register();
    Get.lazyPut<StudentMentorController>(() => StudentMentorController());
  }
}
