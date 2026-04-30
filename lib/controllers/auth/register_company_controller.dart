import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
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
    if (!validateStep(1)) {
      return;
    }

    try {
      isLoading.value = true;

      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'تم',
        'تم إرسال طلبك بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
      
//       if (Get.isRegistered<LoginController>()) {
//   Get.delete<LoginController>(force: true);
// }
// Get.offAllNamed(Routes.login);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إرسال الطلب',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
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