import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/complaints/complaint_controller.dart';

class ComplaintBinding extends Bindings {
  static void register() {
    if (Get.isRegistered<ComplaintController>()) return;
    Get.lazyPut<ComplaintController>(
      () => ComplaintController(),
      fenix: true,
    );
  }

  @override
  void dependencies() => register();
}
