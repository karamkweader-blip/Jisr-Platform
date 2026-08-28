import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/api/api_error_presenter.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/auth/register_company_request.dart';
import 'package:jisr_platform/services/auth/register/register_company_service.dart';
import 'package:jisr_platform/routes/app_routes.dart';

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
   allowedExtensions: [
  'pdf',
  'jpg',
  'jpeg',
  'png',
  'doc',
  'docx',
],
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
    JisrSnackbar.show(
      title: 'ملف التوثيق مطلوب',
      message:
          'يرجى رفع مستند يثبت بيانات الشركة قبل إنشاء الحساب.',
      type: JisrSnackbarType.warning,
    );
    return;
  }

  try {
    isLoading.value = true;

    final request = RegisterCompanyRequest(
      name: companyNameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      location: locationController.text.trim(),
      industry: companyFieldController.text.trim(),
      website: websiteController.text.trim(),
      documentationFilePath:
          selectedFilePath.value!,
    );

    await _service.register(request);

    Get.until(
      (route) =>
          route.settings.name == Routes.login,
    );

    JisrSnackbar.show(
      title: 'تم إنشاء الحساب',
      message:
          'تم إنشاء حساب الشركة بنجاح. سيصبح تسجيل الدخول متاحًا بعد موافقة الإدارة على التوثيق.',
      type: JisrSnackbarType.success,
    );
  } catch (error) {
    ApiErrorPresenter.show(error);
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