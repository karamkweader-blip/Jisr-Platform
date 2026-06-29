import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/models/company/company_profile_model.dart';
import 'package:jisr_platform/services/company/company_profile_service.dart';

class EditCompanyProfileController extends GetxController {
  final CompanyProfileService _profileService;

  EditCompanyProfileController(this._profileService);

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final industryController = TextEditingController();
  final locationController = TextEditingController();
  final websiteController = TextEditingController();

  final RxBool isSubmitting = false.obs;

  late final CompanyProfileModel originalProfile;

  String originalName = '';
  String originalEmail = '';
  String originalIndustry = '';
  String originalLocation = '';
  String originalWebsite = '';

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args is! CompanyProfileModel) {
      Get.snackbar(
        'خطأ',
        'تعذر تحميل بيانات التعديل',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    originalProfile = args;

    final user = originalProfile.primaryUser;

    originalName = user?.name ?? '';
    originalEmail = user?.email ?? '';
    originalIndustry = originalProfile.industry;
    originalLocation = originalProfile.location;
    originalWebsite = originalProfile.website;

    nameController.text = originalName;
    emailController.text = originalEmail;
    industryController.text = originalIndustry;
    locationController.text = originalLocation;
    websiteController.text = originalWebsite;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    industryController.dispose();
    locationController.dispose();
    websiteController.dispose();
    super.onClose();
  }

  Future<void> submitChanges() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final body = _buildChangedFieldsBody();

    if (body.isEmpty) {
      Get.snackbar(
        'لا توجد تغييرات',
        'لم تقم بتعديل أي بيانات',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSubmitting.value = true;

      await _profileService.updateCompanyProfile(body: body);

      Get.back(result: true);

      Get.snackbar(
        'تم التحديث',
        'تم تحديث ملف الشركة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Map<String, dynamic> _buildChangedFieldsBody() {
    final body = <String, dynamic>{};

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final industry = industryController.text.trim();
    final location = locationController.text.trim();
    final website = websiteController.text.trim();

    if (name != originalName.trim()) {
      body['name'] = name;
    }

    if (email != originalEmail.trim()) {
      body['email'] = email;
    }

    if (industry != originalIndustry.trim()) {
      body['industry'] = industry;
    }

    if (location != originalLocation.trim()) {
      body['location'] = location;
    }

    if (website != originalWebsite.trim()) {
      body['website'] = website;
    }

    return body;
  }
}