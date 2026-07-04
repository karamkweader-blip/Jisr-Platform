import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/opportunities/student_opportunity_controller.dart';

class StudentOpportunityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentOpportunityController>(
      () => StudentOpportunityController(),
    );
  }
}
