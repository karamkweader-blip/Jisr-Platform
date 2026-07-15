import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/points/student_points_controller.dart';

class StudentPointsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentPointsController>(() => StudentPointsController());
  }
}
