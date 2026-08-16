import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/assigned_tasks/student_assigned_task_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/models/student/assigned_tasks/student_assigned_task_model.dart';
import 'package:jisr_platform/models/student/complaints/complaint_model.dart';
import 'package:jisr_platform/views/student/complaints/complaint_dialog.dart';
import 'package:jisr_platform/views/student/assigned_tasks/student_evaluation_appeals_view.dart';

class StudentAssignedTasksView extends GetView<StudentAssignedTaskController> {
  const StudentAssignedTasksView({super.key});

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
            'مهامي المسندة',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'اعتراضاتي',
              onPressed: () {
                controller.fetchMyAppeals();
                Get.to(() => const StudentEvaluationAppealsView());
              },
              icon: const Icon(Icons.fact_check_outlined),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.actionYellow),
            );
          }

          if (controller.tasks.isEmpty) {
            return const _EmptyAssignedTasks();
          }

          final assignedCount = controller.totalTasks.value > 0
              ? controller.totalTasks.value
              : controller.tasks.length;

          return RefreshIndicator(
            color: AppColors.actionYellow,
            onRefresh: controller.fetchAssignedTasks,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
              child: Column(
                children: [
                  _AssignedTasksHero(count: assignedCount)
                      .animate()
                      .fadeIn(duration: 520.ms)
                      .slideY(begin: .22, curve: Curves.easeOutBack)
                      .scale(begin: const Offset(.96, .96)),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'قائمة المهام',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.primaryBlue,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: controller.fetchAssignedTasks,
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
                    itemCount: controller.tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final task = controller.tasks[index];

                      return _AssignedTaskCard(task: task)
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 90 * index),
                            duration: 450.ms,
                          )
                          .slideY(begin: .24, curve: Curves.easeOutCubic)
                          .scale(begin: const Offset(.97, .97));
                    },
                  ),
                  if (controller.hasMoreTasks) ...[
                    const SizedBox(height: 16),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: controller.isLoadingMore.value
                              ? null
                              : () => controller.fetchAssignedTasks(
                                  loadMore: true,
                                ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryBlue,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: controller.isLoadingMore.value
                              ? const SizedBox(
                                  width: 21,
                                  height: 21,
                                  child: CircularProgressIndicator(
                                    color: AppColors.actionYellow,
                                    strokeWidth: 2.2,
                                  ),
                                )
                              : const Text(
                                  'تحميل المزيد',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _AssignedTasksHero extends StatelessWidget {
  final int count;

  const _AssignedTasksHero({required this.count});

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
                Icons.assignment_ind_rounded,
                color: AppColors.actionYellow,
                size: 64,
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.06, 1.06),
                duration: 1800.ms,
              )
              .shimmer(duration: 2200.ms, color: Colors.white.withOpacity(.22)),
          const SizedBox(height: 16),
          const Text(
            'مهام مسندة من المشرف',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لديك $count مهمة حالياً، ابدأ العمل ثم قم بتسليمها عند الانتهاء.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white70,
              height: 1.6,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectAssignmentEvaluationCard
    extends GetView<StudentAssignedTaskController> {
  final StudentAssignedTaskModel project;

  const _ProjectAssignmentEvaluationCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final assignmentId = project.projectAssignmentId;
      final isLoading = controller.loadingEvaluationIds.contains(assignmentId);
      final error = controller.evaluationErrors[assignmentId];
      final response = controller.evaluations[assignmentId];
      final evaluatedAssignment = response?.evaluation?.assignment;
      final evaluatedTitle = evaluatedAssignment?.projectTitle ?? '';
      final assignmentTitle = project.assignment.projectTemplate.title;
      final title = evaluatedTitle.isNotEmpty
          ? evaluatedTitle
          : assignmentTitle.isNotEmpty
          ? assignmentTitle
          : project.title;
      final status = evaluatedAssignment?.status.isNotEmpty == true
          ? evaluatedAssignment!.status
          : project.assignment.status;
      final progress = evaluatedAssignment?.progressPercentage ??
          project.assignment.progressPercentage;
      final level = project.assignment.projectTemplate.level;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(.09),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_rounded,
                    color: AppColors.primaryBlue,
                    size: 29,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.primaryBlue,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SmallStatusBadge(
                            icon: Icons.flag_rounded,
                            text: controller.projectStatusText(status),
                            color: AppColors.actionYellow,
                          ),
                          if (level.isNotEmpty)
                            _SmallStatusBadge(
                              icon: Icons.signal_cellular_alt_rounded,
                              text: level,
                              color: AppColors.primaryBlue,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'نسبة التقدم',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '$progress%',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: (progress.clamp(0, 100)) / 100,
                backgroundColor: AppColors.primaryBlue.withOpacity(.08),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.actionYellow,
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (isLoading && response == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: CircularProgressIndicator(
                    color: AppColors.actionYellow,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            else if (error != null && response == null)
              _EvaluationLoadError(
                message: error,
                onRetry: () => controller.loadProjectEvaluation(assignmentId),
              )
            else if (response != null && !response.hasEvaluation)
              const _NoProjectEvaluation()
            else if (response?.evaluation != null)
              _ProjectEvaluationDetails(
                projectAssignmentId: assignmentId,
                response: response!,
              ),
          ],
        ),
      );
    });
  }
}

class _EvaluationLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _EvaluationLoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.red,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text(
              'إعادة المحاولة',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoProjectEvaluation extends StatelessWidget {
  const _NoProjectEvaluation();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'لم يصدر تقييم للمشروع بعد.',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textDark,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectEvaluationDetails extends GetView<StudentAssignedTaskController> {
  final int projectAssignmentId;
  final StudentProjectEvaluationResponse response;

  const _ProjectEvaluationDetails({
    required this.projectAssignmentId,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    final evaluation = response.evaluation!;
    final comment = evaluation.generalComment;
    final deadline = response.appealWindow?.deadlineAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColors.primaryBlue, Color(0xFF0077B6)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'التقييم النهائي',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${evaluation.finalGrade} / 100',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.13),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  controller.evaluationStatusText(evaluation.status),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (evaluation.supervisor?.name.isNotEmpty == true) ...[
          const SizedBox(height: 14),
          _EvaluationInfoRow(
            icon: Icons.supervisor_account_rounded,
            label: 'المشرف',
            value: evaluation.supervisor!.name,
          ),
        ],
        if (evaluation.evaluatedAt != null) ...[
          const SizedBox(height: 9),
          _EvaluationInfoRow(
            icon: Icons.event_available_rounded,
            label: 'تاريخ التقييم',
            value: controller.dateTimeText(evaluation.evaluatedAt),
          ),
        ],
        if (comment != null) ...[
          const SizedBox(height: 16),
          const Text(
            'تعليق المشرف',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            comment,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textDark,
              height: 1.6,
              fontSize: 12,
            ),
          ),
        ],
        if (evaluation.items.isNotEmpty) ...[
          const SizedBox(height: 17),
          const Text(
            'تفاصيل معايير التقييم',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 9),
          ...evaluation.items.map((item) => _EvaluationItemTile(item)),
        ],
        if (deadline != null) ...[
          const SizedBox(height: 14),
          _EvaluationInfoRow(
            icon: Icons.timer_outlined,
            label: 'انتهاء مهلة الاعتراض',
            value: controller.dateTimeText(deadline),
          ),
        ],
        const SizedBox(height: 16),
        if (response.canAppeal)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                controller.prepareAppeal();
                Get.dialog<void>(
                  _AppealSubmissionDialog(
                    projectAssignmentId: projectAssignmentId,
                  ),
                  barrierDismissible: false,
                );
              },
              icon: const Icon(Icons.rate_review_rounded),
              label: const Text(
                'تقديم اعتراض',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.actionYellow,
                foregroundColor: AppColors.primaryBlue,
                elevation: 0,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.textGrey.withOpacity(.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'انتهت مهلة الاعتراض أو أن حالة التقييم لا تسمح بتقديم اعتراض.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
                fontSize: 11,
              ),
            ),
          ),
        if (response.appeals.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Text(
            'الاعتراضات السابقة',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 9),
          ...response.appeals.map((appeal) => _AppealTile(appeal)),
        ],
      ],
    );
  }
}

class _EvaluationInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _EvaluationInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.actionYellow, size: 19),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.textGrey,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textDark,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _EvaluationItemTile extends StatelessWidget {
  final ProjectEvaluationItemModel item;

  const _EvaluationItemTile(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(.045),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.criteria.name,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${item.score} / ${item.criteria.maxScore}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.actionYellow,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (item.comment != null) ...[
            const SizedBox(height: 6),
            Text(
              item.comment!,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textDark,
                height: 1.45,
                fontSize: 11,
              ),
            ),
          ],
          if (item.evidence != null) ...[
            const SizedBox(height: 6),
            Text(
              'الدليل: ${item.evidence}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
                height: 1.45,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AppealTile extends GetView<StudentAssignedTaskController> {
  final ProjectEvaluationAppealModel appeal;

  const _AppealTile(this.appeal);

  Color get statusColor {
    switch (appeal.status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return AppColors.textGrey;
      default:
        return AppColors.actionYellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(.07),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: statusColor.withOpacity(.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SmallStatusBadge(
            icon: Icons.fact_check_outlined,
            text: controller.appealStatusText(appeal.status),
            color: statusColor,
          ),
          const SizedBox(height: 9),
          Text(
            appeal.reason,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textDark,
              height: 1.55,
              fontSize: 11,
            ),
          ),
          if (appeal.createdAt != null) ...[
            const SizedBox(height: 7),
            Text(
              'تاريخ الإرسال: ${controller.dateTimeText(appeal.createdAt)}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
                fontSize: 10,
              ),
            ),
          ],
          if (appeal.reviewNotes != null) ...[
            const SizedBox(height: 7),
            Text(
              'ملاحظات المراجعة: ${appeal.reviewNotes}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textDark,
                height: 1.45,
                fontSize: 10,
              ),
            ),
          ],
          if (appeal.reviewedAt != null) ...[
            const SizedBox(height: 5),
            Text(
              'تاريخ المراجعة: ${controller.dateTimeText(appeal.reviewedAt)}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AppealSubmissionDialog extends GetView<StudentAssignedTaskController> {
  final int projectAssignmentId;

  const _AppealSubmissionDialog({required this.projectAssignmentId});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(
            () => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تقديم اعتراض على التقييم',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.primaryBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'وضح سبب اعتراضك بشكل واضح. سيتم حفظ نسخة من التقييم الحالي مع الاعتراض.',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textGrey,
                      height: 1.55,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.appealReasonController,
                    enabled: !controller.isSubmittingAppeal.value,
                    minLines: 5,
                    maxLines: 8,
                    maxLength: 3000,
                    onChanged: controller.onAppealReasonChanged,
                    decoration: InputDecoration(
                      labelText: 'سبب الاعتراض',
                      labelStyle: const TextStyle(fontFamily: 'Cairo'),
                      hintText: 'اكتب سبباً واضحاً من 10 إلى 3000 حرف',
                      hintStyle: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                      ),
                      errorText: controller.appealReasonError.value.isEmpty
                          ? null
                          : controller.appealReasonError.value,
                      errorStyle: const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.isSubmittingAppeal.value
                              ? null
                              : () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textGrey,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: controller.isSubmittingAppeal.value
                              ? null
                              : () => controller.submitAppeal(
                                  projectAssignmentId,
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.actionYellow,
                            foregroundColor: AppColors.primaryBlue,
                            elevation: 0,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: controller.isSubmittingAppeal.value
                              ? const SizedBox(
                                  width: 21,
                                  height: 21,
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryBlue,
                                    strokeWidth: 2.2,
                                  ),
                                )
                              : const Text(
                                  'إرسال الاعتراض',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AssignedTaskCard extends GetView<StudentAssignedTaskController> {
  final StudentAssignedTaskModel task;

  const _AssignedTaskCard({required this.task});

  bool get canStart => task.status == 'todo' || task.status == 'assigned';
  bool get canSubmit => task.status == 'in_progress';

  Color get statusColor {
    switch (task.status) {
      case 'todo':
      case 'assigned':
        return AppColors.textGrey;
      case 'in_progress':
        return AppColors.actionYellow;
      case 'submitted':
      case 'under_review':
        return AppColors.primaryBlue;
      case 'revision_requested':
        return Colors.deepOrange;
      case 'done':
      case 'completed':
        return Colors.green;
      default:
        return AppColors.textGrey;
    }
  }

  void _openProjectEvaluation(BuildContext context) {
    final projectAssignmentId = task.projectAssignmentId;
    if (projectAssignmentId <= 0) {
      JisrSnackbar.show(
        title: 'تعذر فتح التقييم',
        message: 'لم يرسل الخادم project_assignment_id لهذه المهمة',
        type: JisrSnackbarType.error,
      );
      return;
    }

    controller.loadProjectEvaluation(
      projectAssignmentId,
      showErrorSnackbar: false,
    );

    Get.dialog<void>(
      Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 28,
          ),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * .88,
            ),
            child: SingleChildScrollView(
              child: _ProjectAssignmentEvaluationCard(project: task),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  Icons.task_alt_rounded,
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
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.primaryBlue,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    if (task.assignment.projectTemplate.title.isNotEmpty) ...[
                      Text(
                        'المشروع: ${task.assignment.projectTemplate.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      'الفرع: ${task.githubBranchOrLink ?? 'غير محدد'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            task.description,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textDark,
              height: 1.6,
              fontSize: 13,
            ),
          ),

          if (task.supervisorFeedback != null &&
              task.supervisorFeedback!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.actionYellow.withOpacity(.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'ملاحظات المشرف: ${task.supervisorFeedback}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textDark,
                  height: 1.5,
                  fontSize: 11,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SmallStatusBadge(
                icon: Icons.timer_rounded,
                text: '${task.estimatedHours} ساعات',
                color: AppColors.primaryBlue,
              ),
              _SmallStatusBadge(
                icon: Icons.flag_rounded,
                text: controller.statusText(task.status),
                color: statusColor,
              ),
              _SmallStatusBadge(
                icon: Icons.donut_large_rounded,
                text:
                    'تقدم المشروع: ${task.assignment.progressPercentage}%',
                color: AppColors.primaryBlue,
              ),
              _SmallStatusBadge(
                icon: Icons.play_circle_rounded,
                text: 'بدأ: ${controller.dateOnly(task.startedAt)}',
                color: AppColors.textGrey,
              ),
              _SmallStatusBadge(
                icon: Icons.upload_rounded,
                text: 'رفع: ${controller.dateOnly(task.submittedAt)}',
                color: AppColors.textGrey,
              ),
            ],
          ),

          const SizedBox(height: 18),

          _TaskTimeline(status: task.status),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openProjectEvaluation(context),
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text(
                'عرض تقييم المشروع والاعتراض',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                minimumSize: const Size.fromHeight(50),
                side: BorderSide(
                  color: AppColors.primaryBlue.withOpacity(.22),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),

          if (task.assignment.supervisor.name.isNotEmpty) ...[
            const SizedBox(height: 10),
            _EvaluationInfoRow(
              icon: Icons.supervisor_account_outlined,
              label: 'المشرف',
              value: task.assignment.supervisor.name,
            ),
          ],

          const SizedBox(height: 14),

          ComplaintActionButton(
            contextType: ComplaintContextTypes.projectAssignment,
            contextId: task.projectAssignmentId,
            subjectLabel: task.assignment.supervisor.name.isEmpty
                ? 'المشرف المسند للمشروع'
                : 'المشرف ${task.assignment.supervisor.name}',
            label: 'الإبلاغ عن المشرف',
            onContextNotFound: () => controller.fetchAssignedTasks(),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _ActionButton(
                    title: controller.isStarting.value
                        ? 'جار البدء...'
                        : 'بدء العمل',
                    icon: Icons.play_arrow_rounded,
                    color: AppColors.primaryBlue,
                    isEnabled: canStart && !controller.isStarting.value,
                    onTap: () => controller.startTask(task),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => _ActionButton(
                    title: controller.isSubmitting.value
                        ? 'جار الرفع...'
                        : 'رفع المهمة',
                    icon: Icons.cloud_upload_rounded,
                    color: AppColors.actionYellow,
                    isEnabled: canSubmit && !controller.isSubmitting.value,
                    onTap: () => controller.submitTask(task),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallStatusBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _SmallStatusBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskTimeline extends StatelessWidget {
  final String status;

  const _TaskTimeline({required this.status});

  int get step {
    switch (status) {
      case 'todo':
      case 'assigned':
        return 0;
      case 'in_progress':
        return 1;
      case 'submitted':
      case 'under_review':
      case 'revision_requested':
        return 2;
      case 'done':
      case 'completed':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['إسناد', 'عمل', 'رفع', 'إنهاء'];

    return Column(
      children: [
        Row(
          children: List.generate(labels.length, (index) {
            final active = index <= step;

            return Expanded(
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.actionYellow
                          : AppColors.primaryBlue.withOpacity(.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      active ? Icons.check_rounded : Icons.circle_outlined,
                      size: 16,
                      color: active ? Colors.white : AppColors.textGrey,
                    ),
                  ),
                  if (index != labels.length - 1)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        height: 3,
                        color: index < step
                            ? AppColors.actionYellow
                            : AppColors.primaryBlue.withOpacity(.10),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          children: labels
              .map(
                (label) => Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textGrey,
                      fontSize: 11,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isEnabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = isEnabled ? color : AppColors.textGrey.withOpacity(.45);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        height: 54,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: buttonColor.withOpacity(.20),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
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

class _EmptyAssignedTasks extends StatelessWidget {
  const _EmptyAssignedTasks();

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
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_late_outlined,
              color: AppColors.actionYellow,
              size: 72,
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد مهام مشروع مسندة حالياً',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.primaryBlue,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'عند قيام المشرف بإسناد مهمة جديدة، ستظهر هنا.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
                height: 1.6,
              ),
            ),
          ],
        ),
      ).animate().fadeIn().scale(curve: Curves.easeOutBack),
    );
  }
}
