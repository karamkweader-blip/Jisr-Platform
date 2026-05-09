import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/cv/cv_upload_controller.dart';

class CvUploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CvUploadController>(() => CvUploadController());
  }
}
