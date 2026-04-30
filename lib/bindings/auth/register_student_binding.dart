import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/register_student_controller.dart';

class RegisterStudentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterStudentController>(
      () => RegisterStudentController(),
    );
  }
}