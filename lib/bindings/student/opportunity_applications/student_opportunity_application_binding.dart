import 'package:get/get.dart';
import 'package:jisr_platform/bindings/student/complaints/complaint_binding.dart';
import 'package:jisr_platform/controllers/student/opportunity_applications/student_opportunity_application_controller.dart';

class StudentOpportunityApplicationBinding extends Bindings {
  @override
  void dependencies() {
    ComplaintBinding.register();
    Get.lazyPut<StudentOpportunityApplicationController>(
      () => StudentOpportunityApplicationController(),
    );
  }
}
