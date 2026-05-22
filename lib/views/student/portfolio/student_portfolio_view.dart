import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/portfolio/student_portfolio_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class StudentPortfolioView extends GetView<StudentPortfolioController> {
  const StudentPortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: const StudentBottomNav(currentIndex: 1),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.primaryBlue),
          title: const Text(
            'البورتفوليو',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.actionYellow,
          onPressed: () {
            controller.prepareAdd();
            _openProjectSheet(context);
          },
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.actionYellow),
            );
          }

          if (controller.projects.isEmpty) {
            return _EmptyPortfolio(
              onAdd: () {
                controller.prepareAdd();
                _openProjectSheet(context);
              },
            );
          }

          return RefreshIndicator(
            color: AppColors.actionYellow,
            onRefresh: controller.fetchProjects,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
              child: Column(
                children: [
                  _HeaderCard(projectCount: controller.projects.length)
                      .animate()
                      .fadeIn(duration: 520.ms)
                      .slideY(begin: .22, curve: Curves.easeOutBack),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'مشاريعي',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.primaryBlue,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: controller.fetchProjects,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.actionYellow,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.projects.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final project = controller.projects[index];

                      return _ProjectCard(
                            title: project.title,
                            url: project.projectUrl,
                            grade: project.grade?.toString(),
                            date: _dateOnly(project.completionDate),
                            onTap: () {
                              Get.toNamed(
                                Routes.studentPortfolioDetails,
                                arguments: project.id,
                              );
                            },
                          )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 80 * index),
                            duration: 450.ms,
                          )
                          .slideY(begin: .25, curve: Curves.easeOutCubic)
                          .scale(begin: const Offset(.97, .97));
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  static String _dateOnly(String? value) {
    if (value == null || value.isEmpty) return 'غير محدد';
    return value.split('T').first;
  }

  void _openProjectSheet(BuildContext context) {
    Get.bottomSheet(
      const _ProjectFormSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final int projectCount;

  const _HeaderCard({required this.projectCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryBlue, Color(0xFF0077B6)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
                Icons.work_history_rounded,
                color: AppColors.actionYellow,
                size: 58,
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.06, 1.06),
                duration: 1800.ms,
              ),
          const SizedBox(height: 16),
          const Text(
            'بورتفوليو مشاريعك',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'عندك $projectCount مشروع محفوظ',
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final String title;
  final String url;
  final String? grade;
  final String date;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.title,
    required this.url,
    required this.grade,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(.08)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(.07),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.actionYellow.withOpacity(.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.folder_special_rounded,
                color: AppColors.actionYellow,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty ? 'مشروع بدون عنوان' : title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    url.isEmpty ? 'لا يوجد رابط' : url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _MiniBadge(
                        icon: Icons.calendar_month_rounded,
                        text: date,
                      ),
                      const SizedBox(width: 8),
                      _MiniBadge(
                        icon: Icons.star_rounded,
                        text: grade == null ? 'غير محدد' : '$grade',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textGrey,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.primaryBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPortfolio extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyPortfolio({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.actionYellow,
              size: 72,
            ),
            const SizedBox(height: 16),
            const Text(
              'البورتفوليو فارغ حالياً',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.primaryBlue,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'أضيفي أول مشروع حتى يظهر ضمن إنجازاتك.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.actionYellow,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'إضافة مشروع',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
      ).animate().fadeIn().scale(curve: Curves.easeOutBack),
    );
  }
}

class _ProjectFormSheet extends GetView<StudentPortfolioController> {
  const _ProjectFormSheet();

  @override
  Widget build(BuildContext context) {
    final isEditing = controller.selectedProject.value != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          right: 22,
          left: 22,
          top: 18,
          bottom: MediaQuery.of(context).viewInsets.bottom + 22,
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
        ),
        child: SingleChildScrollView(
          child:
              Column(
                    children: [
                      Container(
                        width: 46,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.textGrey.withOpacity(.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        isEditing ? 'تعديل مشروع' : 'إضافة مشروع جديد',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.primaryBlue,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _SheetField(
                        controller: controller.titleController,
                        label: 'عنوان المشروع',
                        icon: Icons.title_rounded,
                      ),
                      _SheetField(
                        controller: controller.descriptionController,
                        label: 'وصف المشروع',
                        icon: Icons.description_rounded,
                        maxLines: 3,
                      ),
                      _SheetField(
                        controller: controller.projectUrlController,
                        label: 'رابط المشروع',
                        icon: Icons.link_rounded,
                      ),
                      _DatePickerField(
                        controller: controller.completionDateController,
                        label: 'تاريخ الإكمال',
                        icon: Icons.calendar_month_rounded,
                      ),
                      _SheetField(
                        controller: controller.gradeController,
                        label: 'الدرجة',
                        icon: Icons.star_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => ElevatedButton.icon(
                          onPressed: controller.isSaving.value
                              ? null
                              : controller.saveProject,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          icon: controller.isSaving.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_rounded),
                          label: Text(
                            controller.isSaving.value
                                ? 'جار الحفظ...'
                                : 'حفظ المشروع',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: .20, curve: Curves.easeOutCubic),
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;

  const _SheetField({
    required this.controller,
    required this.label,
    this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: 'Cairo'),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primaryBlue),
          labelStyle: const TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w700,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(
              color: AppColors.primaryBlue.withOpacity(.08),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(
              color: AppColors.primaryBlue.withOpacity(.08),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(
              color: AppColors.actionYellow,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _DatePickerField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  DateTime? _parseDate(String value) {
    if (value.trim().isEmpty) return null;
    return DateTime.tryParse(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      child: TextField(
        controller: controller,
        readOnly: true,
        style: const TextStyle(fontFamily: 'Cairo'),
        onTap: () async {
          final now = DateTime.now();

          final picked = await showDatePicker(
            context: context,
            initialDate: _parseDate(controller.text) ?? now,
            firstDate: DateTime(1990),
            lastDate: DateTime(now.year + 5),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primaryBlue,
                    onPrimary: Colors.white,
                    onSurface: AppColors.textDark,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.actionYellow,
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );

          if (picked != null) {
            controller.text = _formatDate(picked);
          }
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: 'اختر التاريخ',
          prefixIcon: Icon(icon, color: AppColors.primaryBlue),
          suffixIcon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.actionYellow,
          ),
          labelStyle: const TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w700,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(
              color: AppColors.primaryBlue.withOpacity(.08),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(
              color: AppColors.primaryBlue.withOpacity(.08),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(
              color: AppColors.actionYellow,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
