import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/api/api_error_presenter.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/auth/register_student_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/auth/register/register_student_service.dart';

class RegisterStudentController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController =
      TextEditingController();

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;

  final RegisterStudentService _service =
      RegisterStudentService();

  late final String role;

  @override
  void onInit() {
    super.onInit();
    role = Get.arguments?['role'] ?? 'student';
  }

  Future<void> registerStudent() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      isLoading.value = true;

      final model = RegisterStudentModel(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        passwordConfirmation:
            confirmPasswordController.text,
        role: role,
      );

      await _service.register(model);

      Get.until(
        (route) =>
            route.settings.name == Routes.login,
      );

      JisrSnackbar.show(
        title: 'تم إنشاء الحساب',
        message:
            'تم إنشاء حساب الطالب بنجاح. يمكنك تسجيل الدخول الآن.',
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}