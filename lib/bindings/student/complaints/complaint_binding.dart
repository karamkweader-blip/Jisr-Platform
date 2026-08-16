import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/complaints/complaint_controller.dart';

class ComplaintBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ComplaintController>(
      () => ComplaintController(),
      fenix: true,
    );
  }
}
