import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/portfolio/student_portfolio_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class StudentPortfolioDetailsView extends GetView<StudentPortfolioController> {
  const StudentPortfolioDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final projectId = Get.arguments as int;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchProjectDetails(projectId);
    });

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
            'تفاصيل المشروع',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoadingDetails.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.actionYellow),
            );
          }

          final project = controller.selectedProject.value;

          if (project == null) {
            return const Center(
              child: Text(
                'لم يتم العثور على المشروع',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textGrey,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
            child: Column(
              children: [
                _DetailsHero(
                      title: project.title,
                      grade: project.grade?.toString(),
                    )
                    .animate()
                    .fadeIn(duration: 520.ms)
                    .slideY(begin: .22, curve: Curves.easeOutBack),

                const SizedBox(height: 20),

                _InfoCard(
                  icon: Icons.description_rounded,
                  title: 'وصف المشروع',
                  value: project.description,
                ).animate().fadeIn(delay: 100.ms).slideX(begin: .22),

                _InfoCard(
                  icon: Icons.link_rounded,
                  title: 'رابط المشروع',
                  value: project.projectUrl,
                ).animate().fadeIn(delay: 180.ms).slideX(begin: .22),

                _InfoCard(
                  icon: Icons.source_rounded,
                  title: 'المصدر',
                  value: project.source,
                ).animate().fadeIn(delay: 260.ms).slideX(begin: .22),

                _InfoCard(
                  icon: Icons.calendar_month_rounded,
                  title: 'تاريخ الإكمال',
                  value: _dateOnly(project.completionDate),
                ).animate().fadeIn(delay: 340.ms).slideX(begin: .22),

                const SizedBox(height: 18),

                Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            title: 'تعديل',
                            icon: Icons.edit_rounded,
                            color: AppColors.primaryBlue,
                            onTap: () {
                              controller.prepareEdit(project);
                              _openEditSheet(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => _ActionButton(
                              title: controller.isDeleting.value
                                  ? 'جار الحذف...'
                                  : 'حذف',
                              icon: Icons.delete_rounded,
                              color: Colors.redAccent,
                              onTap: controller.isDeleting.value
                                  ? null
                                  : () => _confirmDelete(context),
                            ),
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(delay: 430.ms)
                    .slideY(begin: .25, curve: Curves.easeOutCubic),
              ],
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

  void _openEditSheet(BuildContext context) {
    Get.to(() => const _EditProjectSheet());
  }

  void _confirmDelete(BuildContext context) {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Text(
            'حذف المشروع؟',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'هل أنت متأكد من حذف هذا المشروع من البورتفوليو؟',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            Obx(
              () => ElevatedButton.icon(
                onPressed: controller.isDeleting.value
                    ? null
                    : controller.deleteSelectedProject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: controller.isDeleting.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.delete_rounded),
                label: Text(
                  controller.isDeleting.value ? 'جار الحذف...' : 'حذف',
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 250.ms).scale(curve: Curves.easeOutBack),
      ),
    );
  }
}

class _DetailsHero extends StatelessWidget {
  final String title;
  final String? grade;

  const _DetailsHero({required this.title, required this.grade});

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
                Icons.folder_special_rounded,
                color: AppColors.actionYellow,
                size: 64,
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.06, 1.06),
                duration: 1800.ms,
              ),
          const SizedBox(height: 16),
          Text(
            title.isEmpty ? 'مشروع بدون عنوان' : title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.actionYellow.withOpacity(.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'الدرجة: ${grade ?? 'غير محددة'}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.actionYellow,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final shownValue = value.trim().isEmpty ? 'غير محدد' : value;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.07),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.actionYellow),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  shownValue,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textDark,
                    height: 1.5,
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

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(.20),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProjectSheet extends GetView<StudentPortfolioController> {
  const _EditProjectSheet();

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
            'تعديل المشروع',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
          child: Column(
            children: [
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
              const SizedBox(height: 18),
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
                    controller.isSaving.value ? 'جار الحفظ...' : 'حفظ التعديل',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 350.ms).slideY(begin: .20),
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
