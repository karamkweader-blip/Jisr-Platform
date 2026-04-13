import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import '../../core/app_colors.dart'; 
import '../../core/app_decorations.dart'; 
import '../../controllers/auth/login_controller.dart';

class LoginView extends GetView<LoginController>{
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background, 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                child: Hero(
                  tag: 'logo',
                  child: Image.asset('assets/images/logo.png', height: 100),
                ),
              ),

              const SizedBox(height: 30),
              
              Text(
                "مرحباً بك مجدداً",
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: AppColors.primaryBlue,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "سجل دخولك للمتابعة في منصة جسور",
                style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
              const SizedBox(height: 45),
              
              Container(
                decoration: BoxDecoration(boxShadow: AppDecorations.softShadow),
                child: TextField(
                  controller: controller.emailController,
                  decoration: AppDecorations.fieldInput("البريد الإلكتروني", Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 20),
              
              Obx(() => Container(
                decoration: BoxDecoration(boxShadow: AppDecorations.softShadow),
                child: TextField(
                  controller: controller.passwordController,
                  obscureText: !controller.isPasswordVisible.value,
                  decoration: AppDecorations.fieldInput("كلمة المرور", Icons.lock_outline).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.primaryBlue.withOpacity(0.6),
                      ),
                      onPressed: () => controller.isPasswordVisible.toggle(),
                    ),
                  ),
                ),
              )),
              
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {}, 
                  child: const Text(
                    "نسيت كلمة المرور؟",
                    style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              
              const SizedBox(height: 35),
              
              Obx(() => Container(
                width: double.infinity,
                height: 58,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => controller.login(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: controller.isLoading.value 
                    ? const SizedBox(
                        height: 24, 
                        width: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text(
                        "تسجيل الدخول", 
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                ),
              )),
              
              const SizedBox(height: 40),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   TextButton(
                    onPressed: () {
                   Get.toNamed(Routes.role);
                    }, 
                    child: const Text(
                      "أنشئ حسابك الآن",
                      style: TextStyle(color: AppColors.actionYellow, fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                  const Text("ليس لديك حساب؟", style: TextStyle(color: AppColors.textGrey)),
                 
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}