import 'package:get/get.dart';
import 'package:jisr_platform/models/company/company_profile_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/company/company_profile_service.dart';

class CompanyProfileController extends GetxController {
  final CompanyProfileService _profileService;

  CompanyProfileController(this._profileService);

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<CompanyProfileModel> profile = Rxn<CompanyProfileModel>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _profileService.getCompanyProfile();
      profile.value = result;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  String verificationLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'موثّق';
      case 'pending':
        return 'قيد المراجعة';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'غير موثّق';
    }
  }


Future<void> goToEditProfile() async {
  final currentProfile = profile.value;

  if (currentProfile == null) {
    Get.snackbar(
      'تنبيه',
      'لا توجد بيانات جاهزة للتعديل',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  final shouldRefresh = await Get.toNamed(
    Routes.editCompanyProfile,
    arguments: currentProfile,
  );

  if (shouldRefresh == true) {
    fetchProfile();
  }
}

}