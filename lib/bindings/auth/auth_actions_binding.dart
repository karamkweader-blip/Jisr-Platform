import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/auth_actions_controller.dart';

class AuthActionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthActionsController>(
      () => AuthActionsController(),
      fenix: true,
    );
  }
}
