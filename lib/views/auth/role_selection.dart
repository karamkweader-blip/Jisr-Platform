import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/role_controller.dart';
import 'package:jisr_platform/core/app_colors.dart';
import 'package:jisr_platform/core/widgets/rolecard.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class RoleSelectionPage extends GetView<RoleController> {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, 

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              const SizedBox(height: 40),

              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Hero(
                  tag: 'logo',
                  child: Image(
                    image: AssetImage('assets/images/logo.png'),
                    height: 100,
                  ),
                ),
              ),


              const SizedBox(height: 30),

              Text(
                "كيف تريد الانضمام؟",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "اختر نوع حسابك لنبني تجربة مخصصة لك",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey),
              ),

              const SizedBox(height: 45),

              Row(
                children: [
                  Expanded(
                    child: RoleCard(
                      role: UserRole.student,
                      title: "طالب",
                      desc: "ابحث عن فرص، طوّر مهاراتك وابنِ مسيرتك",
                      color: AppColors.primaryBlue,
                      icon: Icons.school,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RoleCard(
                      role: UserRole.company,
                      title: "شركة",
                      desc: "انشر فرصك واكتشف أفضل المواهب التقنية",
                      color: AppColors.actionYellow,
                      icon: Icons.business,
                    ),
                  ),
                ],
              ),

const SizedBox(height: 60),

              Obx(() {
                final isEnabled = controller.isSelected;
  Color buttonColor;

  if (controller.selectedRole.value == UserRole.company) {
    buttonColor = AppColors.actionYellow;
  } else if (controller.selectedRole.value == UserRole.student) {
    buttonColor = AppColors.primaryBlue;
  } else {
    buttonColor = AppColors.textGrey.withOpacity(0.5);
  }

    return AnimatedScale(
    duration: const Duration(milliseconds: 200),
    scale: isEnabled ? 1 : 0.95, //تكبير خفيف

    child: AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isEnabled ? 1 : 0.7, // يوضح  

    child: SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: controller.isSelected ? controller.onContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          disabledBackgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          controller.buttonText,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ));
}),


              const SizedBox(height: 35),

Row(
    mainAxisAlignment: MainAxisAlignment.center,
  children: [
    TextButton(
                        onPressed: () {
                       Get.offAllNamed(Routes.login);
                        }, 
                        child: const Text(
                          "سجل دخول الآن",
                          style: TextStyle(color: AppColors.actionYellow, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Text("لديك حساب؟", style: TextStyle(color: AppColors.textGrey)),
  ],
),],
          ),
        ),
      ),
    );
  }
}