import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/opportunity_applications/student_opportunity_application_controller.dart';

class StudentOpportunityApplicationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentOpportunityApplicationController>(
      () => StudentOpportunityApplicationController(),
    );
  }
}
