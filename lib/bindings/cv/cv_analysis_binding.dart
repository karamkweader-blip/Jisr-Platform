import 'package:get/get.dart';
import 'package:jisr_platform/controllers/cv/cv/cv_analysis_controller.dart';

class CvAnalysisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CvAnalysisController>(() => CvAnalysisController());
  }
}
