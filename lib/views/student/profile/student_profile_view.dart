import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/profile/student_profile_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/jisr_primary_button.dart';

class StudentProfileView extends GetView<StudentProfileController> {
  const StudentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.primaryBlue),
          title: const Text(
            'ملفي الشخصي',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.actionYellow),
            );
          }

          final profile = controller.profile.value;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
                  child: Column(
                    children: [
                      _ProfileHeader(
                            name: profile?.user.name ?? 'طالب جسور',
                            email: profile?.user.email ?? '',
                            imageUrl: profile?.user.profilePictureUrl,
                            selectedImage: controller.selectedImage.value,
                            status:
                                profile?.user.verificationStatus ?? 'pending',
                            onPickImage: controller.pickProfileImage,
                          )
                          .animate()
                          .fadeIn(duration: 550.ms)
                          .slideY(begin: .22, end: 0, curve: Curves.easeOutBack)
                          .scale(
                            begin: const Offset(.96, .96),
                            end: const Offset(1, 1),
                          ),

                      const SizedBox(height: 24),

                      Align(
                        alignment: Alignment.centerRight,
                        child: const Text(
                          'معلومات الحساب',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ).animate().fadeIn(delay: 80.ms).slideX(begin: .2),

                      const SizedBox(height: 14),

                      _AnimatedField(
                        delay: 100.ms,
                        child: _ProfileTextField(
                          controller: controller.nameController,
                          label: 'الاسم',
                          icon: Icons.person_rounded,
                        ),
                      ),

                      _AnimatedField(
                        delay: 170.ms,
                        child: _ProfileTextField(
                          controller: controller.emailController,
                          label: 'البريد الإلكتروني',
                          icon: Icons.email_rounded,
                        ),
                      ),

                      _AnimatedField(
                        delay: 240.ms,
                        child: _ProfileTextField(
                          controller: controller.bioController,
                          label: 'نبذة عني',
                          icon: Icons.auto_awesome_rounded,
                          maxLines: 3,
                        ),
                      ),

                      _AnimatedField(
                        delay: 310.ms,
                        child: _ProfileTextField(
                          controller: controller.universityController,
                          label: 'الجامعة',
                          icon: Icons.school_rounded,
                        ),
                      ),

                      _AnimatedField(
                        delay: 380.ms,
                        child: _ProfileTextField(
                          controller: controller.majorController,
                          label: 'التخصص',
                          icon: Icons.code_rounded,
                        ),
                      ),

                      _AnimatedField(
                        delay: 450.ms,
                        child: _ProfileTextField(
                          controller: controller.graduationYearController,
                          label: 'سنة التخرج',
                          icon: Icons.calendar_month_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ),

                      _AnimatedField(
                        delay: 520.ms,
                        child: _ProfileTextField(
                          controller: controller.phoneController,
                          label: 'رقم الهاتف',
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Obx(
                            () => JisrPrimaryButton(
                              text: 'حفظ التعديلات',
                              icon: Icons.save_rounded,
                              isLoading: controller.isSaving.value,
                              onPressed: controller.isSaving.value
                                  ? null
                                  : controller.saveProfile,
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 620.ms)
                          .slideY(begin: .35, curve: Curves.easeOutCubic)
                          .shimmer(
                            duration: 2200.ms,
                            color: Colors.white.withOpacity(.25),
                          ),
                    ],
                  ),
                ),
              ),
              const _StudentBottomNav(),
            ],
          );
        }),
      ),
    );
  }
}

class _AnimatedField extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const _AnimatedField({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(delay: delay, duration: 520.ms)
        .slideX(begin: .25, end: 0, curve: Curves.easeOutCubic)
        .scale(begin: const Offset(.96, .96), end: const Offset(1, 1));
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? imageUrl;
  final File? selectedImage;
  final String status;
  final VoidCallback onPickImage;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.selectedImage,
    required this.status,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage = imageUrl != null && imageUrl!.isNotEmpty;
    final hasSelectedImage = selectedImage != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryBlue, Color(0xFF0077B6)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.20),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
                onTap: onPickImage,
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(.20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.actionYellow.withOpacity(.18),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: hasSelectedImage
                              ? Image.file(selectedImage!, fit: BoxFit.cover)
                              : hasNetworkImage
                              ? Image.network(
                                  imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const _DefaultProfileImage();
                                  },
                                )
                              : const _DefaultProfileImage(),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.actionYellow,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.actionYellow.withOpacity(.28),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.015, 1.015),
                duration: 2200.ms,
              )
              .shimmer(duration: 2200.ms, color: Colors.white.withOpacity(.22)),

          const SizedBox(height: 16),

          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            email,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.actionYellow.withOpacity(.14),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.actionYellow.withOpacity(.42),
              ),
            ),
            child: Text(
              status == 'pending' ? 'بانتظار التحقق' : status,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.actionYellow,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultProfileImage extends StatelessWidget {
  const _DefaultProfileImage();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.white,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          color: AppColors.primaryBlue,
          size: 56,
        ),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;

  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.07),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: 'Cairo'),
        decoration: InputDecoration(
          labelText: label,
          hintText: 'أضف معلوماتك',
          prefixIcon: Icon(icon, color: AppColors.primaryBlue),
          labelStyle: const TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w700,
          ),
          hintStyle: const TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.textGrey,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(
              color: AppColors.primaryBlue.withOpacity(.08),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(
              color: AppColors.primaryBlue.withOpacity(.08),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(
              color: AppColors.actionYellow,
              width: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentBottomNav extends StatelessWidget {
  const _StudentBottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 0, 22, 18),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomItem(
            icon: Icons.person_outline,
            title: 'ملف شخصي',
            isActive: true,
            onTap: () {},
          ),
          _BottomItem(
            icon: Icons.home_rounded,
            title: 'الرئيسية',
            onTap: () => Get.offNamed('/home'),
          ),
          _BottomItem(
            icon: Icons.upload_file_outlined,
            title: 'رفع CV',
            onTap: () => Get.offNamed('/cv-upload'),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms).slideY(begin: .25);
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback? onTap;

  const _BottomItem({
    required this.icon,
    required this.title,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.actionYellow : AppColors.textGrey;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.actionYellow.withOpacity(.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: isActive ? 28 : 24),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
