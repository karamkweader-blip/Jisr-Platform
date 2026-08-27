import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/cv/student_cv_selection_controller.dart';

class StudentCvSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentCvSelectionController>(
      () => StudentCvSelectionController(),
    );
  }
}
