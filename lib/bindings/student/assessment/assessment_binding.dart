import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/assessment/assessment_controller.dart';

class AssessmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AssessmentController>(() => AssessmentController());
  }
}
