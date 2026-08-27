import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/supervisor_projects/student_supervisor_project_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/models/student/supervisor_projects/student_supervisor_project_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/views/student/supervisor_projects/student_supervisor_projects_view.dart';

class StudentSupervisorProjectDetailsView extends StatefulWidget {
  const StudentSupervisorProjectDetailsView({super.key});

  @override
  State<StudentSupervisorProjectDetailsView> createState() =>
      _StudentSupervisorProjectDetailsViewState();
}

class _StudentSupervisorProjectDetailsViewState
    extends State<StudentSupervisorProjectDetailsView> {
  late final StudentSupervisorProjectController controller;
  late final int projectId;

  @override
  void initState() {
    super.initState();
    controller = Get.find<StudentSupervisorProjectController>();
    projectId = int.tryParse(Get.arguments?.toString() ?? '') ?? 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.openProject(projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        bottomNavigationBar: const StudentBottomNav(currentIndex: 0),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          iconTheme: const IconThemeData(color: AppColors.primaryBlue),
          centerTitle: true,
          title: const Text(
            'تفاصيل المشروع',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'تقديماتي',
              onPressed: () => Get.toNamed(
                Routes.studentSupervisorProjectApplications,
              ),
              icon: const Icon(Icons.fact_check_outlined),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoadingDetails.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.actionYellow),
            );
          }

          final project = controller.selectedProject.value;
          if (project == null) {
            return _DetailsError(
              message: controller.detailError.value.isEmpty
                  ? 'تعذر فتح المشروع'
                  : controller.detailError.value,
              onRetry: () => controller.openProject(projectId),
            );
          }

          return RefreshIndicator(
            color: AppColors.actionYellow,
            onRefresh: () => controller.openProject(project.id),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _ProjectHeader(project: project, controller: controller),
                  const SizedBox(height: 14),
                  if (project.description?.isNotEmpty ?? false)
                    _DetailSection(
                      icon: Icons.description_outlined,
                      title: 'وصف المشروع',
                      child: Text(
                        project.description!,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 12,
                          height: 1.75,
                        ),
                      ),
                    ),
                  if (project.description?.isNotEmpty ?? false)
                    const SizedBox(height: 12),
                  if (project.expectedOutcome?.isNotEmpty ?? false)
                    _DetailSection(
                      icon: Icons.flag_outlined,
                      title: 'النتيجة المتوقعة',
                      child: Text(
                        project.expectedOutcome!,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 12,
                          height: 1.75,
                        ),
                      ),
                    ),
                  if (project.expectedOutcome?.isNotEmpty ?? false)
                    const SizedBox(height: 12),
                  _SupervisorSection(project: project),
                  const SizedBox(height: 12),
                  _CapacitySection(project: project),
                  const SizedBox(height: 12),
                  _TasksPlan(project: project),
                  const SizedBox(height: 16),
                  _ProjectAction(project: project, controller: controller),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ProjectHeader extends StatelessWidget {
  final StudentSupervisorProjectModel project;
  final StudentSupervisorProjectController controller;

  const _ProjectHeader({required this.project, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.13),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.account_tree_outlined,
                  color: AppColors.actionYellow,
                  size: 29,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  project.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _HeaderBadge(
                icon: Icons.signal_cellular_alt_rounded,
                text: controller.levelText(project.level),
              ),
              _HeaderBadge(
                icon: Icons.task_alt_outlined,
                text: '${project.tasksSummary.count} مهام',
              ),
              _HeaderBadge(
                icon: Icons.schedule_rounded,
                text: '${project.tasksSummary.estimatedTotalHours} ساعة',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeaderBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _DetailSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: AppColors.primaryBlue, size: 21),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SupervisorSection extends StatelessWidget {
  final StudentSupervisorProjectModel project;

  const _SupervisorSection({required this.project});

  @override
  Widget build(BuildContext context) {
    final supervisor = project.supervisor;
    return _DetailSection(
      icon: Icons.supervisor_account_outlined,
      title: 'المشرف',
      child: Row(
        children: <Widget>[
          const CircleAvatar(
            radius: 23,
            backgroundColor: Color(0xFFF0F5FA),
            child: Icon(Icons.person_rounded, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  supervisor.name.isEmpty ? 'غير محدد' : supervisor.name,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (supervisor.specialization?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 3),
                  Text(
                    supervisor.specialization!,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (supervisor.isVolunteer)
            const ProjectMetaBadge(
              icon: Icons.volunteer_activism_outlined,
              text: 'متطوع',
            ),
        ],
      ),
    );
  }
}

class _CapacitySection extends StatelessWidget {
  final StudentSupervisorProjectModel project;

  const _CapacitySection({required this.project});

  @override
  Widget build(BuildContext context) {
    final capacity = project.capacity;
    final maxText = capacity.maxStudents == null
        ? 'غير محدود'
        : capacity.maxStudents.toString();
    final remainingText = capacity.remainingSlots == null
        ? 'غير محدود'
        : capacity.remainingSlots.toString();
    return _DetailSection(
      icon: Icons.groups_outlined,
      title: 'سعة المشروع',
      child: Row(
        children: <Widget>[
          Expanded(
            child: _CapacityItem(
              label: 'الحد الأقصى',
              value: maxText,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _CapacityItem(
              label: 'طلبات فعالة',
              value: capacity.activeApplicationsCount.toString(),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _CapacityItem(
              label: 'الأماكن المتبقية',
              value: remainingText,
              danger: capacity.isFull,
            ),
          ),
        ],
      ),
    );
  }
}

class _CapacityItem extends StatelessWidget {
  final String label;
  final String value;
  final bool danger;

  const _CapacityItem({
    required this.label,
    required this.value,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFD65353) : AppColors.primaryBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 11),
      decoration: BoxDecoration(
        color: color.withOpacity(.055),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 8.5),
          ),
        ],
      ),
    );
  }
}

class _TasksPlan extends StatelessWidget {
  final StudentSupervisorProjectModel project;

  const _TasksPlan({required this.project});

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      icon: Icons.format_list_numbered_rounded,
      title: 'خطة مهام المشروع',
      child: project.tasks.isEmpty
          ? const Text(
              'لا توجد مهام مفصلة لهذا المشروع حالياً.',
              style: TextStyle(color: AppColors.textGrey, fontSize: 11),
            )
          : Column(
              children: project.tasks
                  .map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ProjectTaskRow(task: task),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _ProjectTaskRow extends StatelessWidget {
  final StudentSupervisorProjectTask task;

  const _ProjectTaskRow({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(.035),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryBlue,
            child: Text(
              task.orderIndex.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '${task.estimatedHours} س',
                      style: const TextStyle(
                        color: AppColors.actionYellow,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                if (task.description?.isNotEmpty ?? false) ...<Widget>[
                  const SizedBox(height: 5),
                  Text(
                    task.description!,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 10,
                      height: 1.55,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectAction extends StatelessWidget {
  final StudentSupervisorProjectModel project;
  final StudentSupervisorProjectController controller;

  const _ProjectAction({required this.project, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (project.actions.canOpenAssignment) {
      return SizedBox(
        height: 54,
        child: ElevatedButton.icon(
          onPressed: () => controller.openAcceptedAssignment(
            projectAssignmentId: project.application?.projectAssignmentId,
            projectTitle: project.title,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E9D65),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: const Icon(Icons.playlist_add_check_circle_outlined),
          label: const Text(
            'فتح المشروع والمهام',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      );
    }

    if (project.actions.canApply) {
      return SizedBox(
        height: 54,
        child: ElevatedButton.icon(
          onPressed: () => _showApplySheet(context, controller),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.actionYellow,
            foregroundColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: const Icon(Icons.send_outlined),
          label: const Text(
            'التقديم على المشروع',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      );
    }

    final application = project.application;
    final isRejected = application?.status == 'rejected';
    final text = application != null
        ? controller.applicationStatusText(application.status)
        : project.actions.applyBlockReason == 'capacity_reached'
            ? 'اكتمل العدد ولا يمكن التقديم حالياً'
            : 'التقديم غير متاح';
    final color = isRejected ? const Color(0xFFD65353) : AppColors.primaryBlue;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(.12)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            isRejected ? Icons.cancel_outlined : Icons.info_outline_rounded,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showApplySheet(
    BuildContext context,
    StudentSupervisorProjectController controller,
  ) async {
    controller.prepareApplyForm();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
            decoration: BoxDecoration(
              color: Theme.of(sheetContext).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.textGrey.withOpacity(.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'رسالة التقديم',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'الرسالة اختيارية، والباك يحدد حالة الطلب بعد الإرسال.',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 10.5),
                ),
                const SizedBox(height: 14),
                Obx(
                  () => TextField(
                    controller: controller.applyMessageController,
                    onChanged: controller.onApplyMessageChanged,
                    minLines: 4,
                    maxLines: 6,
                    maxLength: 1000,
                    decoration: InputDecoration(
                      hintText: 'اكتب سبب اهتمامك بالمشروع (اختياري)',
                      errorText: controller.messageError.value.isEmpty
                          ? null
                          : controller.messageError.value,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: controller.isApplying.value
                          ? null
                          : () async {
                              final success =
                                  await controller.applyToSelectedProject();
                              if (success && sheetContext.mounted) {
                                Navigator.pop(sheetContext);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.actionYellow,
                        foregroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      child: controller.isApplying.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: AppColors.primaryBlue,
                                strokeWidth: 2.3,
                              ),
                            )
                          : const Text(
                              'تأكيد التقديم',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DetailsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.primaryBlue,
              size: 54,
            ),
            const SizedBox(height: 13),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
