import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/conversations/company_conversation_controller.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/conversations/company_conversation_service.dart';

class CompanyConversationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) {
      Get.lazyPut<AuthService>(
        () => AuthService(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<CompanyConversationService>()) {
      Get.lazyPut<CompanyConversationService>(
        () => CompanyConversationService(
          Get.find<AuthService>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<CompanyConversationController>()) {
      Get.lazyPut<CompanyConversationController>(
        () => CompanyConversationController(
          Get.find<CompanyConversationService>(),
          Get.find<AuthService>(),
        ),
        fenix: true,
      );
    }
  }
}