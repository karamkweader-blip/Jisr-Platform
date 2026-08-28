import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/profile/student_profile_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/jisr_primary_button.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/core/widgets/student/student_drawer.dart';
import 'package:jisr_platform/core/widgets/student/student_shell_app_bar.dart';
import 'package:jisr_platform/models/student/assessment/assessment_models.dart';

class StudentProfileView extends GetView<StudentProfileController> {
  const StudentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: const StudentDrawer(),
        drawerScrimColor: Colors.black.withOpacity(.32),
        bottomNavigationBar: const StudentBottomNav(currentIndex: 4),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const StudentShellAppBar(),
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

                      const SizedBox(height: 30),

                      Obx(
                        () => _StudentSkillsSection(
                          isLoading: controller.isLoadingSkills.value,
                          skills: controller.skills.toList(growable: false),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _StudentSkillsSection extends StatelessWidget {
  final bool isLoading;
  final List<AssessmentLearningPathItem> skills;

  const _StudentSkillsSection({
    required this.isLoading,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مهاراتي',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'تُعرض تلقائيًا حسب آخر نتيجة محفوظة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.actionYellow.withOpacity(.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 15,
                    color: AppColors.actionYellow,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'للقراءة فقط',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.actionYellow,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.actionYellow,
              ),
            ),
          )
        else if (skills.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(.08),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.textGrey,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'لا توجد مهارات محفوظة بعد. ستظهر هنا بعد إتمام التقييم.',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textGrey,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...List.generate(
            skills.length,
            (index) => _ReadOnlySkillCard(
              skill: skills[index],
              index: index,
            )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: 80 * index),
                  duration: 420.ms,
                )
                .slideY(begin: .12, end: 0),
          ),
      ],
    ).animate().fadeIn(delay: 680.ms).slideY(begin: .10, end: 0);
  }
}

class _ReadOnlySkillCard extends StatelessWidget {
  final AssessmentLearningPathItem skill;
  final int index;

  const _ReadOnlySkillCard({
    required this.skill,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final hasSavedLevel = skill.currentLevel > 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.055),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.primaryBlue,
                  AppColors.primaryBlueLight,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              skill.skillName.isEmpty ? 'مهارة' : skill.skillName,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textDark,
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: hasSavedLevel
                  ? AppColors.primaryBlue.withOpacity(.09)
                  : AppColors.textGrey.withOpacity(.09),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Text(
                  'المستوى',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: hasSavedLevel
                        ? AppColors.primaryBlue
                        : AppColors.textGrey,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasSavedLevel
                      ? skill.currentLevel.toStringAsFixed(1)
                      : 'غير محفوظ',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: hasSavedLevel
                        ? AppColors.primaryBlue
                        : AppColors.textGrey,
                    fontSize: hasSavedLevel ? 15 : 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
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
  final VoidCallback onPickImage;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.selectedImage,
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

        ],
      ),
    );
  }
}

class _DefaultProfileImage extends StatelessWidget {
  const _DefaultProfileImage();

  @override
  Widget build(BuildContext context) {
    return  ColoredBox(
      color: Theme.of(context).colorScheme.surface,
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
          hintStyle:  TextStyle(
            fontFamily: 'Cairo',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
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
