import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/assigned_tasks/student_assigned_task_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/models/student/assigned_tasks/student_assigned_task_model.dart';

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
                  _AssignedTasksHero(count: controller.tasks.length)
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

class _AssignedTaskCard extends GetView<StudentAssignedTaskController> {
  final StudentAssignedTaskModel task;

  const _AssignedTaskCard({required this.task});

  bool get canStart => task.status == 'assigned';
  bool get canSubmit => task.status == 'in_progress';

  Color get statusColor {
    switch (task.status) {
      case 'assigned':
        return AppColors.textGrey;
      case 'in_progress':
        return AppColors.actionYellow;
      case 'submitted':
        return AppColors.primaryBlue;
      case 'completed':
        return Colors.green;
      default:
        return AppColors.textGrey;
    }
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
      case 'assigned':
        return 0;
      case 'in_progress':
        return 1;
      case 'submitted':
        return 2;
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
              'لا توجد مهام مسندة حالياً',
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
