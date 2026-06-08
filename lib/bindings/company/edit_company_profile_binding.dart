import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/edit_company_profile_controller.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/company_profile_service.dart';

class EditCompanyProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) {
      Get.lazyPut<AuthService>(() => AuthService());
    }

    if (!Get.isRegistered<CompanyProfileService>()) {
      Get.lazyPut<CompanyProfileService>(
        () => CompanyProfileService(Get.find<AuthService>()),
      );
    }

    Get.lazyPut<EditCompanyProfileController>(
      () => EditCompanyProfileController(
        Get.find<CompanyProfileService>(),
      ),
    );
  }
}