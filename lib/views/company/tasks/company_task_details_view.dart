import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/tasks/company_task_details_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/tasks/company_task_details_model.dart';
import 'package:jisr_platform/views/company/tasks/widgets/task_details/task_details_header_card.dart';
import 'package:jisr_platform/views/company/tasks/widgets/task_details/task_info_tile.dart';
import 'package:jisr_platform/views/company/tasks/widgets/task_details/task_section_card.dart';
import 'package:jisr_platform/views/company/tasks/widgets/task_details/task_skill_card.dart';
import 'package:jisr_platform/views/company/tasks/widgets/task_details/task_workflow_timeline.dart';

class CompanyTaskDetailsView extends GetView<CompanyTaskDetailsController> {
  const CompanyTaskDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: WillPopScope(
        onWillPop: () async {
          controller.closePage();
          return false;
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryBlue),
    );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return _TaskDetailsError(
                  message: controller.errorMessage.value,
                  onRetry: controller.fetchTaskDetails,
                  onBack: controller.closePage,
                );
              }

              final task = controller.task.value;

              if (task == null) {
                return _TaskDetailsError(
                  message: 'لا توجد بيانات لعرضها',
                  onRetry: controller.fetchTaskDetails,
                  onBack: controller.closePage,
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshTaskDetails,
                color: AppColors.primaryBlue,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TopBar(
  onBack: controller.closePage,
  onSelected: controller.handleMenuAction,
  canEdit: task.canEdit,
  canCancel: task.canCancel,
  isCancelling: controller.isDeleting.value,
),
                            const SizedBox(height: 18),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.94, end: 1),
                              duration: const Duration(milliseconds: 360),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  alignment: Alignment.topCenter,
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: TaskDetailsHeaderCard(
                                title: task.title,
                                statusLabel:
                                    controller.statusLabel(task.status),
                                difficultyLabel: controller
                                    .difficultyLabel(task.difficultyLevel),
                                deadline: controller.formatDate(task.deadline),
                                deadlineHint:
                                    controller.deadlineHint(task.deadline),
                                durationDays: task.durationDays,
                                maxApplicants: task.maxApplicants,
                                maxAcceptedStudents:
                                    task.maxAcceptedStudents,
                                isDraft: task.isDraft,
                                isPublishing: controller.isPublishing.value,
                                onPublishPressed:
                                    controller.confirmPublishTask,
                                onApplicantsPressed:
                                    controller.goToApplicants,
                              ),
                            ),
                            const SizedBox(height: 18),
                            TaskWorkflowTimeline(
                              currentIndex:
                                  controller.workflowIndex(task.status),
                            ),
                            const SizedBox(height: 18),
                            _SmartActionCard(
                              task: task,
                              onPublish: controller.confirmPublishTask,
                              onApplicants:
                                  controller.goToApplicants,
                            ),
                           
                            const SizedBox(height: 18),
                            _TaskOverviewSection(
                              task: task,
                              submissionTypeLabel: controller
                                  .submissionTypeLabel(task.submissionType),
                              deadline:
                                  controller.formatDate(task.deadline),
                            ),
                            const SizedBox(height: 18),
                            _TaskSkillsSection(task: task),
                            const SizedBox(height: 18),
                            _TaskDeliverablesSection(task: task),
                            const SizedBox(height: 18),
                            _TaskAcceptanceSection(task: task),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final ValueChanged<String> onSelected;
  final bool canEdit;
  final bool canCancel;
  final bool isCancelling;

  const _TopBar({
    required this.onBack,
    required this.onSelected,
    required this.canEdit,
    required this.canCancel,
    required this.isCancelling,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: onBack,
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تفاصيل المهمة',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'إدارة ونظرة كاملة على التاسك',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          onSelected: onSelected,
          color: AppColors.cardWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('تحديث'),
                ],
              ),
            ),
            if (canEdit)
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('تعديل المهمة'),
                  ],
                ),
              ),
            if (canCancel)
              PopupMenuItem(
                value: 'cancel',
                enabled: !isCancelling,
                child: Row(
                  children: [
                    const Icon(
                      Icons.cancel_outlined,
                      size: 18,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCancelling ? 'جارٍ الإلغاء...' : 'إلغاء المهمة',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
          ],
          child: const _CircleIconButton(
            icon: Icons.more_horiz_rounded,
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleIconButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _SmartActionCard extends StatelessWidget {
  final CompanyTaskDetailsModel task;
  final VoidCallback onPublish;
  final VoidCallback onApplicants;

  const _SmartActionCard({
    required this.task,
    required this.onPublish,
    required this.onApplicants,
  });

  @override
  Widget build(BuildContext context) {
    final isDraft = task.isDraft;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.actionYellow.withOpacity(0.30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.actionYellow.withOpacity(0.08),
            blurRadius: 18,
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
              color: AppColors.actionYellow.withOpacity(0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isDraft
                  ? Icons.rocket_launch_outlined
                  : Icons.groups_2_outlined,
              color: AppColors.actionYellow,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isDraft
                  ? 'هذه المهمة ما زالت مسودة. عند النشر سيبدأ الطلاب المناسبون بالتقديم.'
                  : 'المهمة منشورة. الخطوة التالية هي مراجعة الطلاب المتقدمين.',
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: isDraft ? onPublish : onApplicants,
            child: Text(isDraft ? 'نشر' : 'المتقدمون'),
          ),
        ],
      ),
    );
  }
}

class _TaskOverviewSection extends StatelessWidget {
  final CompanyTaskDetailsModel task;
  final String submissionTypeLabel;
  final String deadline;

  const _TaskOverviewSection({
    required this.task,
    required this.submissionTypeLabel,
    required this.deadline,
  });

  @override
  Widget build(BuildContext context) {
    return TaskSectionCard(
      title: 'نظرة عامة',
      icon: Icons.assignment_outlined,
      children: [
        Text(
          task.description,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
            height: 1.6,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            TaskInfoTile(
              icon: Icons.calendar_month_outlined,
              title: 'الموعد النهائي',
              value: deadline,
            ),
            TaskInfoTile(
              icon: Icons.timelapse_outlined,
              title: 'المدة',
              value: '${task.durationDays} أيام',
            ),
            TaskInfoTile(
              icon: Icons.upload_file_outlined,
              title: 'نوع التسليم',
              value: submissionTypeLabel,
            ),
            TaskInfoTile(
              icon: Icons.groups_2_outlined,
              title: 'عدد المقبولين',
              value: '${task.maxAcceptedStudents}',
            ),
          ],
        ),
      ],
    );
  }
}

class _TaskSkillsSection extends StatelessWidget {
  final CompanyTaskDetailsModel task;

  const _TaskSkillsSection({required this.task});

  @override
  Widget build(BuildContext context) {
    return TaskSectionCard(
      title: 'المهارات المطلوبة',
      icon: Icons.psychology_alt_outlined,
      children: task.skills.isEmpty
          ? const [
              _EmptyText('لا توجد مهارات محددة لهذه المهمة'),
            ]
          : task.skills
              .map(
                (skill) => TaskSkillCard(skill: skill),
              )
              .toList(),
    );
  }
}

class _TaskDeliverablesSection extends StatelessWidget {
  final CompanyTaskDetailsModel task;

  const _TaskDeliverablesSection({required this.task});

  @override
  Widget build(BuildContext context) {
    return TaskSectionCard(
      title: 'المخرجات المطلوبة',
      icon: Icons.checklist_rtl_outlined,
      children: task.deliverables.isEmpty
          ? const [
              _EmptyText('لا توجد مخرجات محددة'),
            ]
          : task.deliverables
              .map(
                (item) => _BulletItem(text: item),
              )
              .toList(),
    );
  }
}

class _TaskAcceptanceSection extends StatelessWidget {
  final CompanyTaskDetailsModel task;

  const _TaskAcceptanceSection({required this.task});

  @override
  Widget build(BuildContext context) {
    return TaskSectionCard(
      title: 'معايير القبول',
      icon: Icons.verified_outlined,
      children: task.acceptanceCriteria.isEmpty
          ? const [
              _EmptyText('لا توجد معايير قبول محددة'),
            ]
          : task.acceptanceCriteria
              .map(
                (item) => _BulletItem(text: item),
              )
              .toList(),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;

  const _BulletItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.primaryBlue,
              size: 15,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  final String text;

  const _EmptyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textGrey,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _TaskDetailsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const _TaskDetailsError({
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: _CircleIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBack,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.actionYellow,
                  size: 44,
                ),
                const SizedBox(height: 12),
                const Text(
                  'تعذر تحميل التفاصيل',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

