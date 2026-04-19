import 'package:get/get.dart';
import 'package:jisr_platform/routes/app_routes.dart';

enum UserRole {student, company }

class RoleController extends GetxController {
  var selectedRole = Rxn<UserRole>();

  void selectRole(UserRole role) {
    selectedRole.value = role;
  }

  bool get isSelected => selectedRole.value != null;

  String get buttonText {
    if (selectedRole.value == UserRole.student) {
      return "متابعة كـ طالب ←";
    } else if (selectedRole.value == UserRole.company) {
      return "متابعة كـ شركة ←";
    } else {
      return "اختر نوع الحساب أولاً";
    }    
  }

  void onContinue() {
  if (!isSelected) return;

  if (selectedRole.value == UserRole.student) {
    Get.toNamed('/student-home');
  } else {
    Get.toNamed(Routes.registerCompany);
  }
}
}