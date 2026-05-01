import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/login_otp_controller.dart';

class LoginOtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginOtpController>(() => LoginOtpController());
  }
}
