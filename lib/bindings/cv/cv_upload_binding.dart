import 'package:get/get.dart';
import 'package:jisr_platform/controllers/cv/cv_upload_controller.dart';

class CvUploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CvUploadController>(() => CvUploadController());
  }
}
