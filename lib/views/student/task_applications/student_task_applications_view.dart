import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/task_applications/student_task_application_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/models/student/task_applications/student_task_application_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class StudentTaskApplicationsView
    extends GetView<StudentTaskApplicationController> {
  const StudentTaskApplicationsView({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('BUILD STUDENT TASK APPLICATIONS VIEW');

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
            'تقديماتي',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'تقديمات فرص العمل',
              onPressed: () {
                Get.toNamed(Routes.studentOpportunityApplications);
              },
              icon: const Icon(
                Icons.work_history_rounded,
                color: AppColors.primaryBlue,
              ),
            ),
            Obx(
              () => IconButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.fetchAllMyTasks,
                icon: controller.isLoading.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: AppColors.actionYellow,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.actionYellow,
                      ),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          color: AppColors.actionYellow,
          onRefresh: controller.refreshCurrentData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ApplicationsHeroInteractive(),

                const SizedBox(height: 16),

                const _OpportunityApplicationsEntryCard(),

                const SizedBox(height: 24),

                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      controller.currentTabTitle,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Obx(() {
                  if (controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.actionYellow,
                        ),
                      ),
                    );
                  }

                  final tasks = controller.currentTasks;

                  if (tasks.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          'لا يوجد تاسكات في هذا القسم حالياً',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.textGrey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return _ApplicationTaskCard(item: tasks[index]);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplicationsHeroInteractive
    extends GetView<StudentTaskApplicationController> {
  const _ApplicationsHeroInteractive();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryBlue, Color(0xFF0077B6)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.dashboard_customize_rounded,
            color: AppColors.actionYellow,
            size: 54,
          ),
          const SizedBox(height: 12),
          const Text(
            'لوحة التحكم بتقديماتي',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'اضغط على أي إحصائية بالأسفل لفلترة القائمة فوراً وبسهولة.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _InteractiveStatCard(
                  title: 'كل الطلبات',
                  count: controller.allTasks.length,
                  tab: TaskApplicationTab.all,
                  active:
                      controller.selectedTab.value == TaskApplicationTab.all,
                ),
                _InteractiveStatCard(
                  title: 'قيد المراجعة',
                  count: controller.appliedTasks.length,
                  tab: TaskApplicationTab.applied,
                  active:
                      controller.selectedTab.value ==
                      TaskApplicationTab.applied,
                ),
                _InteractiveStatCard(
                  title: 'طلبات مقبولة',
                  count: controller.acceptedTasks.length,
                  tab: TaskApplicationTab.accepted,
                  active:
                      controller.selectedTab.value ==
                      TaskApplicationTab.accepted,
                ),
                _InteractiveStatCard(
                  title: 'طلبات مرفوضة',
                  count: controller.rejectedTasks.length,
                  tab: TaskApplicationTab.rejected,
                  active:
                      controller.selectedTab.value ==
                      TaskApplicationTab.rejected,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OpportunityApplicationsEntryCard extends StatelessWidget {
  const _OpportunityApplicationsEntryCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed(Routes.studentOpportunityApplications);
      },
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: AppColors.actionYellow.withOpacity(.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.actionYellow.withOpacity(.12),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [AppColors.actionYellow, Color(0xFFFFD66B)],
                ),
              ),
              child: const Icon(
                Icons.work_history_rounded,
                color: AppColors.primaryBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تقديمات فرص العمل',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'اعرض طلبات الوظائف والتدريبات، تابع حالتها، أو اسحب الطلب.',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textGrey,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveStatCard extends GetView<StudentTaskApplicationController> {
  final String title;
  final int count;
  final TaskApplicationTab tab;
  final bool active;

  const _InteractiveStatCard({
    required this.title,
    required this.count,
    required this.tab,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.selectFilter(tab),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: active
              ? AppColors.actionYellow
              : Colors.white.withOpacity(.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active
                ? AppColors.actionYellow
                : Colors.white.withOpacity(.2),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: active ? Colors.black87 : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: active
                    ? Colors.black.withOpacity(.12)
                    : Colors.white.withOpacity(.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: active ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationTaskCard extends GetView<StudentTaskApplicationController> {
  final StudentTaskApplicationModel item;

  const _ApplicationTaskCard({required this.item});

  Color get statusColor {
    switch (item.status) {
      case 'pending':
        return AppColors.actionYellow;
      case 'accepted':
      case 'working':
      case 'submitted':
        return Colors.green;
      case 'rejected':
        return Colors.redAccent;
      default:
        return AppColors.primaryBlue;
    }
  }

  IconData get statusIcon {
    switch (item.status) {
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'accepted':
      case 'working':
      case 'submitted':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  bool get canTrackProgress {
    return item.status == 'accepted' ||
        item.status == 'working' ||
        item.status == 'submitted';
  }

  @override
  Widget build(BuildContext context) {
    final task = item.task;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: statusColor.withOpacity(.15)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(statusIcon, color: statusColor, size: 26),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.companyName(item),
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

          const SizedBox(height: 12),

          Text(
            task.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textDark,
              height: 1.5,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ApplicationBadge(
                icon: Icons.flag_rounded,
                text: controller.statusText(item.status),
                color: statusColor,
              ),
              _ApplicationBadge(
                icon: Icons.speed_rounded,
                text: task.difficultyLevel,
                color: AppColors.primaryBlue,
              ),
              _ApplicationBadge(
                icon: Icons.star_rounded,
                text: 'تطابق ${item.matchScore ?? 'غير محدد'}',
                color: AppColors.actionYellow,
              ),
              _ApplicationBadge(
                icon: Icons.event_rounded,
                text: controller.dateOnly(task.deadline),
                color: AppColors.textGrey,
              ),
            ],
          ),

          if (task.skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: task.skills
                  .map(
                    (skill) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        skill.name,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.primaryBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],

          if ((item.companyNotes ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(.07),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_rounded, color: statusColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.companyNotes!,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: statusColor,
                        height: 1.5,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (canTrackProgress && item.assignmentId != null) ...[
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                Get.toNamed(
                  Routes.studentTaskProgress,
                  arguments: item.assignmentId,
                );
              },
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(.16),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'متابعة التقدم والتسليم',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ApplicationBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _ApplicationBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final shownText = text.trim().isEmpty ? 'غير محدد' : text;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            shownText,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
