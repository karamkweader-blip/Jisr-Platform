import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/conversations/student_conversation_controller.dart';

class StudentConversationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<StudentConversationController>()) {
      Get.put<StudentConversationController>(
        StudentConversationController(),
        permanent: false,
      );
    }
  }
}
