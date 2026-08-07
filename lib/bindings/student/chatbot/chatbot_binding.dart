import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/chatbot/chatbot_controller.dart';

class ChatbotBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ChatbotController>()) {
      Get.put<ChatbotController>(ChatbotController(), permanent: false);
    }
  }
}
