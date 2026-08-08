import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/conversations/student_conversation_controller.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/student/conversations/student_conversation_service.dart';

class StudentConversationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) {
      Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    }

    if (!Get.isRegistered<StudentConversationService>()) {
      Get.lazyPut<StudentConversationService>(
        () => StudentConversationService(Get.find<AuthService>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<StudentConversationController>()) {
      Get.lazyPut<StudentConversationController>(
        () => StudentConversationController(
          Get.find<StudentConversationService>(),
          Get.find<AuthService>(),
        ),
        fenix: true,
      );
    }
  }
}
