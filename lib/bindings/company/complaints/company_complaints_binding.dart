import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/complaints/company_complaints_controller.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/complaints/company_complaint_service.dart';

class CompanyComplaintsBinding
    extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) {
      Get.lazyPut<AuthService>(
        AuthService.new,
        fenix: true,
      );
    }

    if (!Get.isRegistered<
        CompanyComplaintService>()) {
      Get.lazyPut<CompanyComplaintService>(
        () => CompanyComplaintService(
          Get.find<AuthService>(),
        ),
        fenix: true,
      );
    }

    Get.lazyPut<CompanyComplaintsController>(
      () => CompanyComplaintsController(
        Get.find<CompanyComplaintService>(),
        Get.find<AuthService>(),
      ),
    );
  }
}