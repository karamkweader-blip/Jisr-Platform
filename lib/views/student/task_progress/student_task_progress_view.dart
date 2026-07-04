import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/task_progress/student_task_progress_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/student/task_progress/student_task_progress_model.dart';

class StudentTaskProgressView extends GetView<StudentTaskProgressController> {
  const StudentTaskProgressView({super.key});

  void _openAddProgressSheet() {
    controller.clearProgressForm();

    Get.to(() => const _AddProgressSheet());
  }

  void _openFinalSubmissionSheet() {
    controller.clearFinalForm();

    Get.to(() => const _FinalSubmissionSheet());
  }

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
            'متابعة التقدم',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: controller.fetchProgress,
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppColors.actionYellow,
              ),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.actionYellow),
            );
          }

          final assignment = controller.assignment.value;

          if (assignment == null) {
            return const Center(
              child: Text(
                'لا توجد بيانات لهذا التاسك',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textGrey,
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.actionYellow,
            onRefresh: controller.fetchProgress,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
              child: Column(
                children: [
                  _ProgressHero(assignment: assignment)
                      .animate()
                      .fadeIn(duration: 520.ms)
                      .slideY(begin: .22, curve: Curves.easeOutBack),

                  const SizedBox(height: 18),

                  _ActionButtonsRow(
                    onAddProgress: _openAddProgressSheet,
                    onSubmitFinal: _openFinalSubmissionSheet,
                  ).animate().fadeIn(delay: 120.ms).slideY(begin: .18),

                  const SizedBox(height: 22),

                  _ProgressTimelineHeader(
                    count: controller.progressUpdates.length,
                  ),

                  const SizedBox(height: 14),

                  if (controller.progressUpdates.isEmpty)
                    const _EmptyProgress()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.progressUpdates.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final update = controller.progressUpdates[index];

                        return _ProgressUpdateCard(update: update)
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 70 * index),
                              duration: 430.ms,
                            )
                            .slideY(begin: .22, curve: Curves.easeOutCubic);
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
}

class _ProgressHero extends GetView<StudentTaskProgressController> {
  final TaskAssignmentInfo assignment;

  const _ProgressHero({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final percentage = controller.latestPercentage();
    final progressValue = (percentage / 100).clamp(0.0, 1.0);

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
            color: AppColors.primaryBlue.withOpacity(.22),
            blurRadius: 26,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
                Icons.trending_up_rounded,
                color: AppColors.actionYellow,
                size: 58,
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.06, 1.06),
                duration: 1800.ms,
              ),
          const SizedBox(height: 14),
          Text(
            assignment.task.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'الحالة: ${assignment.status} • الموعد: ${controller.dateOnly(assignment.task.deadline)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(.18),
              color: AppColors.actionYellow,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'آخر نسبة تقدم: $percentage%',
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtonsRow extends StatelessWidget {
  final VoidCallback onAddProgress;
  final VoidCallback onSubmitFinal;

  const _ActionButtonsRow({
    required this.onAddProgress,
    required this.onSubmitFinal,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            title: 'إضافة تحديث',
            icon: Icons.add_rounded,
            color: AppColors.primaryBlue,
            onTap: onAddProgress,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            title: 'تسليم نهائي',
            icon: Icons.cloud_upload_rounded,
            color: AppColors.actionYellow,
            onTap: onSubmitFinal,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 7),
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

class _ProgressTimelineHeader extends StatelessWidget {
  final int count;

  const _ProgressTimelineHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'تحديثات التقدم',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.actionYellow.withOpacity(.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$count تحديث',
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.actionYellow,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressUpdateCard extends GetView<StudentTaskProgressController> {
  final TaskProgressUpdateModel update;

  const _ProgressUpdateCard({required this.update});

  @override
  Widget build(BuildContext context) {
    final percentage = update.progress.percentage;
    final progressValue = (percentage / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.actionYellow.withOpacity(.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  color: AppColors.actionYellow,
                  size: 30,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      update.progress.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${controller.dateOnly(update.createdAt)} ${controller.timeOnly(update.createdAt)}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.actionYellow,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 8,
              backgroundColor: AppColors.primaryBlue.withOpacity(.08),
              color: AppColors.actionYellow,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            update.progress.description,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textDark,
              height: 1.6,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if ((update.links.githubUrl ?? '').isNotEmpty)
                _SmallLinkBadge(
                  icon: Icons.code_rounded,
                  text: 'GitHub',
                  value: update.links.githubUrl!,
                ),
              if ((update.links.demoUrl ?? '').isNotEmpty)
                _SmallLinkBadge(
                  icon: Icons.open_in_new_rounded,
                  text: 'Demo',
                  value: update.links.demoUrl!,
                ),
              if (update.attachments.isNotEmpty)
                _SmallInfoBadge(
                  icon: Icons.attach_file_rounded,
                  text: '${update.attachments.length} مرفق',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallLinkBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final String value;

  const _SmallLinkBadge({
    required this.icon,
    required this.text,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return _SmallInfoBadge(icon: icon, text: text);
  }
}

class _SmallInfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SmallInfoBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(.07),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 15),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyProgress extends StatelessWidget {
  const _EmptyProgress();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            color: AppColors.actionYellow,
            size: 66,
          ),
          SizedBox(height: 14),
          Text(
            'لا توجد تحديثات بعد',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ابدئ بإضافة أول تحديث للتقدم في التاسك.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}

class _AddProgressSheet extends GetView<StudentTaskProgressController> {
  const _AddProgressSheet();

  @override
  Widget build(BuildContext context) {
    return _ProgressFormPageWrapper(
      title: 'إضافة تحديث تقدم',
      child: Column(
        children: [
          _SheetField(
            controller: controller.progressTitleController,
            label: 'عنوان التحديث',
            hint: 'مثال: Authentication module completed',
            icon: Icons.title_rounded,
          ),
          _SheetField(
            controller: controller.progressDescriptionController,
            label: 'الوصف',
            hint: 'اكتب تفاصيل الإنجاز',
            icon: Icons.description_rounded,
            maxLines: 4,
          ),
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نسبة التقدم: ${controller.progressPercentage.value.round()}%',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Slider(
                  value: controller.progressPercentage.value,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  activeColor: AppColors.actionYellow,
                  inactiveColor: AppColors.primaryBlue.withOpacity(.12),
                  onChanged: (value) {
                    controller.progressPercentage.value = value;
                  },
                ),
              ],
            ),
          ),
          _SheetField(
            controller: controller.progressGithubController,
            label: 'GitHub اختياري',
            hint: 'https://github.com/...',
            icon: Icons.code_rounded,
            textDirection: TextDirection.ltr,
          ),
          _SheetField(
            controller: controller.progressDemoController,
            label: 'Demo اختياري',
            hint: 'https://demo-link.com',
            icon: Icons.open_in_new_rounded,
            textDirection: TextDirection.ltr,
          ),
          _AttachmentPicker(
            title: 'مرفقات التحديث',
            filesCount: controller.progressAttachments.length,
            onTap: controller.pickProgressAttachments,
          ),
          const SizedBox(height: 14),
          Obx(
            () => _SubmitSheetButton(
              text: controller.isAddingProgress.value
                  ? 'جار الإضافة...'
                  : 'إضافة التحديث',
              isLoading: controller.isAddingProgress.value,
              onTap: controller.addProgressUpdate,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinalSubmissionSheet extends GetView<StudentTaskProgressController> {
  const _FinalSubmissionSheet();

  @override
  Widget build(BuildContext context) {
    return _ProgressFormPageWrapper(
      title: 'التسليم النهائي',
      child: Column(
        children: [
          _SheetField(
            controller: controller.finalNotesController,
            label: 'ملاحظات التسليم',
            hint:
                'مثال: Final project submission with authentication, tasks, and documentation',
            icon: Icons.notes_rounded,
            maxLines: 4,
          ),
          _SheetField(
            controller: controller.finalGithubController,
            label: 'GitHub اختياري',
            hint: 'https://github.com/...',
            icon: Icons.code_rounded,
            textDirection: TextDirection.ltr,
          ),
          _SheetField(
            controller: controller.finalDemoController,
            label: 'Demo اختياري',
            hint: 'https://demo-link.com',
            icon: Icons.open_in_new_rounded,
            textDirection: TextDirection.ltr,
          ),
          _AttachmentPicker(
            title: 'ملف التسليم النهائي',
            filesCount: controller.finalAttachments.length,
            onTap: controller.pickFinalAttachments,
          ),
          const SizedBox(height: 14),
          Obx(
            () => _SubmitSheetButton(
              text: controller.isSubmittingFinal.value
                  ? 'جار التسليم...'
                  : 'إرسال التسليم النهائي',
              isLoading: controller.isSubmittingFinal.value,
              onTap: controller.submitFinalTask,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressFormPageWrapper extends StatelessWidget {
  final String title;
  final Widget child;

  const _ProgressFormPageWrapper({required this.title, required this.child});

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
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
          child: child.animate().fadeIn(duration: 350.ms).slideY(begin: .20),
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextDirection textDirection;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.textDirection = TextDirection.rtl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textDirection: textDirection,
        style: const TextStyle(fontFamily: 'Cairo'),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primaryBlue),
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
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

class _AttachmentPicker extends StatelessWidget {
  final String title;
  final int filesCount;
  final VoidCallback onTap;

  const _AttachmentPicker({
    required this.title,
    required this.filesCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(.08)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.attach_file_rounded,
              color: AppColors.actionYellow,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                filesCount == 0 ? title : '$title: $filesCount ملف',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.upload_file_rounded, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}

class _SubmitSheetButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onTap;

  const _SubmitSheetButton({
    required this.text,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.check_rounded),
      label: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
