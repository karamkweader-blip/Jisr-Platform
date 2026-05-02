import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/models/auth/register_company_request.dart';
import 'package:jisr_platform/services/auth/register_company_service.dart';

class RegisterCompanyController extends GetxController {
  final RxInt currentStep = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  late final PageController pageController;

  final GlobalKey<FormState> stepOneFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> stepTwoFormKey = GlobalKey<FormState>();

  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final TextEditingController companyFieldController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();


final RegisterCompanyService _service = RegisterCompanyService();

final RxnString selectedFilePath = RxnString();

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

Future<void> pickFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'txt', 'doc', 'docx'],
  );

  if (result != null && result.files.single.path != null) {
    selectedFilePath.value = result.files.single.path!;
  }
}

  bool validateStep(int step) {
    switch (step) {
      case 0:
        return stepOneFormKey.currentState?.validate() ?? false;
      case 1:
        return stepTwoFormKey.currentState?.validate() ?? false;
      case 2:
        return true;
      default:
        return false;
    }
  }

  Future<void> nextStep() async {
    if (!validateStep(currentStep.value)) {
      return;
    }

    if (currentStep.value < 2) {
      currentStep.value++;
      await pageController.animateToPage(
        currentStep.value,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> prevStep() async {
    if (currentStep.value > 0) {
      currentStep.value--;
      await pageController.animateToPage(
        currentStep.value,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> onPageChanged(int index) async {
    if (index == currentStep.value) {
      return;
    }

    if (index > currentStep.value) {
      final isValid = validateStep(currentStep.value);
      if (!isValid) {
        await pageController.animateToPage(
          currentStep.value,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
        return;
      }
    }

    currentStep.value = index;
  }

  Future<void> submit() async {
  if (!validateStep(1)) return;

  if (selectedFilePath.value == null) {
    Get.snackbar('تنبيه', 'يرجى رفع ملف التوثيق');
    return;
  }

  try {
    isLoading.value = true;

    final request = RegisterCompanyRequest(
      name: companyNameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      location: locationController.text.trim(),
      industry: companyFieldController.text.trim(),
      website: websiteController.text.trim(),
      documentationFilePath: selectedFilePath.value!,);

    await _service.register(request);

    Get.snackbar(
      'تم',
      'تم إنشاء حساب الشركة بنجاح',
      snackPosition: SnackPosition.BOTTOM,
    );

    Get.offAllNamed('/login');

  } catch (e) {
    Get.snackbar(
      'خطأ',
      e.toString(),
      snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isLoading.value = false;
  }
}
  @override
  void onClose() {
    pageController.dispose();
    companyNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    companyFieldController.dispose();
    locationController.dispose();
    websiteController.dispose();
    super.onClose();
  }
}