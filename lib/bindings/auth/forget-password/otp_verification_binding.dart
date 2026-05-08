import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/otp_verification_controller.dart';

class OtpVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OtpVerificationController());
  }
}