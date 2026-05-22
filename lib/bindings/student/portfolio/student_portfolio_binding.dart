import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/portfolio/student_portfolio_controller.dart';

class StudentPortfolioBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentPortfolioController>(() => StudentPortfolioController());
  }
}
