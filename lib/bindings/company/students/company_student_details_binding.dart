import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/students/company_student_details_controller.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/students/company_student_service.dart';

class CompanyStudentDetailsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) {
      Get.lazyPut<AuthService>(
        AuthService.new,
        fenix: true,
      );
    }

    if (!Get.isRegistered<
        CompanyStudentService>()) {
      Get.lazyPut<CompanyStudentService>(
        () => CompanyStudentService(
          Get.find<AuthService>(),
        ),
        fenix: true,
      );
    }

    Get.lazyPut<
        CompanyStudentDetailsController>(
      () => CompanyStudentDetailsController(
        Get.find<CompanyStudentService>(),
      ),
    );
  }
}