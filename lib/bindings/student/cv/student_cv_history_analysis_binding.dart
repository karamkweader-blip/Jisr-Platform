import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/cv/student_cv_history_analysis_controller.dart';

class StudentCvHistoryAnalysisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentCvHistoryAnalysisController>(
      () => StudentCvHistoryAnalysisController(),
    );
  }
}
