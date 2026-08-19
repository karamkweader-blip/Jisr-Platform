import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/auth_actions_controller.dart';
import 'package:jisr_platform/controllers/student/home/home_controller.dart';
import 'package:jisr_platform/controllers/student/opportunities/student_opportunity_controller.dart';
import 'package:jisr_platform/controllers/student/opportunity_applications/student_opportunity_application_controller.dart';
import 'package:jisr_platform/controllers/student/task_applications/student_task_application_controller.dart';
import 'package:jisr_platform/controllers/student/tasks/student_task_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/company/company_account_menu.dart';
import 'package:jisr_platform/core/widgets/company/jisr_animated_logo.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/core/widgets/student/student_drawer.dart';
import 'package:jisr_platform/core/widgets/student/student_shell_app_bar.dart';
import 'package:jisr_platform/models/student/assessment/assessment_models.dart';
import 'package:jisr_platform/models/student/opportunities/student_opportunity_model.dart'
    hide StudentOpportunityApplicationModel;
import 'package:jisr_platform/models/student/opportunity_applications/student_opportunity_application_model.dart';
import 'package:jisr_platform/models/student/task_applications/student_task_application_model.dart';
import 'package:jisr_platform/models/student/tasks/student_task_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/views/student/complaints/complaint_entry_sheet.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeController homeController;
  late final StudentOpportunityApplicationController applicationsController;
  late final StudentTaskApplicationController taskApplicationsController;
  late final StudentTaskController tasksController;
  late final StudentOpportunityController opportunitiesController;

  @override
  void initState() {
    super.initState();
    homeController = Get.find<HomeController>();
    applicationsController =
        Get.find<StudentOpportunityApplicationController>();
    taskApplicationsController = Get.find<StudentTaskApplicationController>();
    tasksController = Get.find<StudentTaskController>();
    opportunitiesController = Get.find<StudentOpportunityController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      tasksController.fetchInitialTasks();
      opportunitiesController.fetchInitialOpportunities();
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      applicationsController.refreshApplications(),
      taskApplicationsController.refreshCurrentData(),
      tasksController.refreshTasks(),
      opportunitiesController.refreshOpportunities(),
      homeController.loadLatestLearningPlan(silent: true),
    ]);
  }

  void _showApplicationsMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.textGrey.withOpacity(.22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'عرض تقديماتي',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _ApplicationMenuTile(
                  icon: Icons.work_outline_rounded,
                  title: 'تقديمات الفرص',
                  subtitle: 'الوظائف والتدريبات',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Get.toNamed(Routes.studentOpportunityApplications);
                  },
                ),
                const SizedBox(height: 9),
                _ApplicationMenuTile(
                  icon: Icons.task_alt_outlined,
                  title: 'تقديمات التاسكات',
                  subtitle: 'المهام المقبولة وقيد المراجعة',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Get.toNamed(Routes.studentTaskApplications);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        drawer: const StudentDrawer(),
        drawerScrimColor: Colors.black.withOpacity(.32),
        appBar: const StudentShellAppBar(),
        bottomNavigationBar: const StudentBottomNav(currentIndex: 2),
        body: RefreshIndicator(
          color: AppColors.actionYellow,
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StudentDashboardHero(
                  title: homeController.homeData.title,
                  subtitle: homeController.homeData.subtitle,
                ).animate().fadeIn(duration: 430.ms).slideY(
                      begin: .12,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: 24),
                _DashboardSectionHeader(
                  icon: Icons.fact_check_outlined,
                  title: 'تقديماتي',
                  subtitle: 'حالة طلبات الفرص والتاسكات',
                  actionLabel: 'عرض الكل',
                  onAction: _showApplicationsMenu,
                ),
                const SizedBox(height: 12),
                _ApplicationsDashboard(
                  opportunityController: applicationsController,
                  taskController: taskApplicationsController,
                ),
                const SizedBox(height: 26),
                _DashboardSectionHeader(
                  icon: Icons.task_alt_outlined,
                  title: 'تاسكات يمكنك التقديم عليها',
                  subtitle: 'مهام من شركات مناسبة لمهاراتك',
                  actionLabel: 'كل التاسكات',
                  onAction: () => Get.toNamed(Routes.studentTasks),
                ),
                const SizedBox(height: 12),
                _AvailableTasksSection(controller: tasksController),
                const SizedBox(height: 26),
                _DashboardSectionHeader(
                  icon: Icons.work_outline_rounded,
                  title: 'الفرص المناسبة',
                  subtitle: 'فرص وظيفية وتدريبية حسب تطابقك',
                  actionLabel: 'كل الفرص',
                  onAction: () => Get.toNamed(Routes.studentOpportunities),
                ),
                const SizedBox(height: 12),
                _AvailableOpportunitiesSection(
                  controller: opportunitiesController,
                ),
                const SizedBox(height: 24),
                _RoadmapStrip(
                  onTap: () async {
                    await homeController.loadLatestLearningPlan(silent: true);
                    if (context.mounted) {
                      _showRoadmapSheet(context, homeController);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplicationMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ApplicationMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      leading: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.primaryBlue),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textGrey, fontSize: 10),
      ),
      trailing: const Icon(
        Icons.arrow_back_ios_new_rounded,
        color: AppColors.actionYellow,
        size: 14,
      ),
    );
  }
}

class _StudentDashboardHero extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StudentDashboardHero({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 21, 20, 21),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.21),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.13),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(.14)),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.actionYellow,
              size: 31,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
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

class _DashboardSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _DashboardSectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 23),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionLabel,
            style: const TextStyle(
              color: AppColors.actionYellow,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ApplicationsDashboard extends StatelessWidget {
  final StudentOpportunityApplicationController opportunityController;
  final StudentTaskApplicationController taskController;

  const _ApplicationsDashboard({
    required this.opportunityController,
    required this.taskController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = opportunityController.isLoading.value ||
          taskController.isLoading.value;
      final opportunities = opportunityController.applications.take(3).toList();
      final tasks = taskController.allTasks.take(3).toList();

      if (loading && opportunities.isEmpty && tasks.isEmpty) {
        return const _HomeLoadingCard();
      }

      if (opportunities.isEmpty && tasks.isEmpty) {
        return const _HomeEmptyCard(
          icon: Icons.inbox_outlined,
          title: 'لا توجد تقديمات حتى الآن',
          subtitle: 'عند التقديم على فرصة أو تاسك ستظهر حالته هنا.',
        );
      }

      return Column(
        children: [
          ...opportunities.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _ApplicationSummaryCard.opportunity(
                item: item,
                statusText: opportunityController.statusText(item.status),
                company: opportunityController.companyName(
                  item.opportunity.company,
                ),
              ),
            ),
          ),
          ...tasks.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _ApplicationSummaryCard.task(
                item: item,
                statusText: taskController.statusText(item.status),
                company: taskController.companyName(item),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _ApplicationSummaryCard extends StatelessWidget {
  final String title;
  final String company;
  final String status;
  final Color statusColor;
  final IconData icon;
  final VoidCallback onTap;

  const _ApplicationSummaryCard._({
    required this.title,
    required this.company,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.onTap,
  });

  factory _ApplicationSummaryCard.opportunity({
    required StudentOpportunityApplicationModel item,
    required String statusText,
    required String company,
  }) {
    return _ApplicationSummaryCard._(
      title: item.opportunity.title,
      company: company,
      status: statusText,
      statusColor: _statusColor(item.status),
      icon: Icons.work_outline_rounded,
      onTap: () => Get.toNamed(
        Routes.studentOpportunityApplicationDetails,
        arguments: item.id,
      ),
    );
  }

  factory _ApplicationSummaryCard.task({
    required StudentTaskApplicationModel item,
    required String statusText,
    required String company,
  }) {
    return _ApplicationSummaryCard._(
      title: item.task.title,
      company: company,
      status: statusText,
      statusColor: _statusColor(item.status),
      icon: Icons.task_alt_outlined,
      onTap: () {
        if (item.assignmentId != null &&
            const {'accepted', 'working', 'submitted'}.contains(item.status)) {
          Get.toNamed(
            Routes.studentTaskProgress,
            arguments: item.assignmentId,
          );
        } else {
          Get.toNamed(Routes.studentTaskApplications);
        }
      },
    );
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
      case 'working':
      case 'submitted':
        return const Color(0xFF2E9D65);
      case 'rejected':
      case 'withdrawn':
        return const Color(0xFFD65353);
      case 'pending':
      case 'pending_review':
        return AppColors.actionYellow;
      default:
        return AppColors.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(.13)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(.045),
                blurRadius: 13,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: statusColor, size: 22),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailableTasksSection extends StatelessWidget {
  final StudentTaskController controller;

  const _AvailableTasksSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.recommendedTasks.isNotEmpty
          ? controller.recommendedTasks
          : controller.exploreTasks;

      if ((controller.isLoadingRecommended.value ||
              controller.isLoadingExplore.value) &&
          items.isEmpty) {
        return const _HomeLoadingCard();
      }
      if (items.isEmpty) {
        return const _HomeEmptyCard(
          icon: Icons.task_alt_outlined,
          title: 'لا توجد تاسكات متاحة حالياً',
          subtitle: 'ستظهر هنا فور نشرها من الشركات.',
        );
      }

      return SizedBox(
        height: 164,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: items.length > 5 ? 5 : items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 11),
          itemBuilder: (_, index) => _DashboardTaskCard(task: items[index]),
        ),
      );
    });
  }
}

class _DashboardTaskCard extends StatelessWidget {
  final StudentTaskModel task;

  const _DashboardTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(Routes.studentTaskDetails, arguments: task.id),
      borderRadius: BorderRadius.circular(23),
      child: Container(
        width: 226,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(.08)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(.055),
              blurRadius: 15,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.task_alt_rounded, color: AppColors.actionYellow, size: 21),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    task.company.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textGrey, fontSize: 10.5),
                  ),
                ),
                if (task.matchScore != null)
                  Text(
                    '${task.matchScore}%',
                    style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w900, fontSize: 11),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w900, height: 1.4),
            ),
            const Spacer(),
            Row(
              children: [
                _MiniMeta(icon: Icons.schedule_rounded, text: '${task.durationDays} يوم'),
                const SizedBox(width: 7),
                _MiniMeta(icon: Icons.bar_chart_rounded, text: task.difficultyLevel),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailableOpportunitiesSection extends StatelessWidget {
  final StudentOpportunityController controller;

  const _AvailableOpportunitiesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.recommendedOpportunities.isNotEmpty
          ? controller.recommendedOpportunities
          : controller.exploreOpportunities;

      if ((controller.isLoadingRecommended.value ||
              controller.isLoadingExplore.value) &&
          items.isEmpty) {
        return const _HomeLoadingCard();
      }
      if (items.isEmpty) {
        return const _HomeEmptyCard(
          icon: Icons.work_outline_rounded,
          title: 'لا توجد فرص متاحة حالياً',
          subtitle: 'سنعرض الفرص الأقرب لمهاراتك هنا.',
        );
      }

      return Column(
        children: items
            .take(4)
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DashboardOpportunityCard(
                    opportunity: item,
                    controller: controller,
                  ),
                ))
            .toList(),
      );
    });
  }
}

class _DashboardOpportunityCard extends StatelessWidget {
  final StudentOpportunityModel opportunity;
  final StudentOpportunityController controller;

  const _DashboardOpportunityCard({
    required this.opportunity,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(
        Routes.studentOpportunityDetails,
        arguments: opportunity.id,
      ),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(.08)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue.withOpacity(.14),
                    AppColors.primaryBlue.withOpacity(.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.work_outline_rounded, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opportunity.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textDark, fontSize: 13.5, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.companyName(opportunity.company),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textGrey, fontSize: 10.5),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 7,
                    runSpacing: 5,
                    children: [
                      _MiniMeta(icon: Icons.location_on_outlined, text: opportunity.location),
                      _MiniMeta(icon: Icons.category_outlined, text: controller.opportunityTypeLabel(opportunity.type)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 49,
              height: 49,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.actionYellow.withOpacity(.11),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${opportunity.matchScore}%',
                style: const TextStyle(color: AppColors.actionYellow, fontSize: 11.5, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMeta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniMeta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(.055),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 12),
          const SizedBox(width: 4),
          Text(
            text.trim().isEmpty ? 'غير محدد' : text,
            style: const TextStyle(color: AppColors.primaryBlue, fontSize: 8.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _HomeLoadingCard extends StatelessWidget {
  const _HomeLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.actionYellow,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}

class _HomeEmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HomeEmptyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(.07)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue.withOpacity(.55), size: 32),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textDark, fontSize: 12.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 9.5, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadmapStrip extends StatelessWidget {
  final VoidCallback onTap;

  const _RoadmapStrip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(23),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryBlue.withOpacity(.10),
              AppColors.actionYellow.withOpacity(.10),
            ],
          ),
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(.08)),
        ),
        child: const Row(
          children: [
            Icon(Icons.route_rounded, color: AppColors.primaryBlue, size: 27),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('خريطة التطوير', style: TextStyle(color: AppColors.textDark, fontSize: 13.5, fontWeight: FontWeight.w900)),
                  Text('أكمل خطتك وتابع تقدمك المهني', style: TextStyle(color: AppColors.textGrey, fontSize: 10)),
                ],
              ),
            ),
            Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.actionYellow, size: 15),
          ],
        ),
      ),
    );
  }
}

class _LegacyHomeView extends GetView<HomeController> {
  const _LegacyHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authActionsController = Get.find<AuthActionsController>();

    final features = <_StudentHomeFeature>[
      _StudentHomeFeature(
        icon: Icons.work_history_rounded,
        title: 'البورتفوليو',
        subtitle: 'مشاريعك وإنجازاتك',
        onTap: () => Get.toNamed(Routes.studentPortfolio),
      ),
      _StudentHomeFeature(
        icon: Icons.task_alt_rounded,
        title: 'التاسكات',
        subtitle: 'مهام حقيقية من الشركات',
        onTap: () => Get.toNamed(Routes.studentTasks),
      ),
      _StudentHomeFeature(
        icon: Icons.work_outline_rounded,
        title: 'فرص العمل',
        subtitle: 'وظائف وتدريبات مناسبة',
        onTap: () => Get.toNamed(Routes.studentOpportunities),
      ),
      _StudentHomeFeature(
        icon: Icons.event_available_rounded,
        title: 'مقابلاتي',
        subtitle: 'مواعيد المقابلات وتفاصيلها',
        onTap: () => Get.toNamed(Routes.studentInterviews),
      ),
      _StudentHomeFeature(
        icon: Icons.route_rounded,
        title: 'خريطة التطوير',
        subtitle: 'خطتك للوصول إلى هدفك',
        onTap: () async {
          await controller.loadLatestLearningPlan(silent: true);
          if (context.mounted) _showRoadmapSheet(context, controller);
        },
      ),
      _StudentHomeFeature(
        icon: Icons.analytics_rounded,
        title: 'تحليل سوق العمل',
        subtitle: 'اعرف المهارات المطلوبة فعلياً',
        onTap: () => Get.toNamed(Routes.studentMarketAnalysis),
      ),
      _StudentHomeFeature(
        icon: Icons.assignment_ind_rounded,
        title: 'مهامي المسندة',
        subtitle: 'المهام المرسلة من المشرف',
        onTap: () => Get.toNamed(Routes.studentAssignedTasks),
      ),
      _StudentHomeFeature(
        icon: Icons.school_rounded,
        title: 'مساري التدريبي',
        subtitle: 'التقديم كمرشد واكتشاف المرشدين',
        onTap: () => Get.toNamed(Routes.studentMentors),
      ),
      _StudentHomeFeature(
        icon: Icons.report_problem_outlined,
        title: 'الشكاوى',
        subtitle: 'إرسال شكوى من السياق الصحيح',
        onTap: () => ComplaintEntrySheet.show(context),
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: const StudentBottomNav(currentIndex: 0),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            'جسور',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          leading: CompanyAccountMenu(
            controller: authActionsController,
          ),
          actions: [
            IconButton(
              tooltip: 'المحادثات',
              onPressed: () {
                Get.toNamed(Routes.studentConversations);
              },
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.primaryBlue,
              ),
            ),
            IconButton(
              tooltip: 'مساعد جسر الذكي',
              onPressed: () {
                Get.toNamed(Routes.studentChatbot);
              },
              icon: const Icon(
                Icons.smart_toy_outlined,
                color: AppColors.primaryBlue,
              ),
            ),
            const Padding(
              padding: EdgeInsetsDirectional.only(end: 12),
              child: Center(
                child: JisrAnimatedLogo(size: 38),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WelcomeCard(
                  title: controller.homeData.title,
                  subtitle: controller.homeData.subtitle,
                )
                    .animate()
                    .fadeIn(duration: 450.ms)
                    .slideY(
                      begin: .16,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: 22),
                ...List.generate(features.length, (index) {
                  final feature = features[index];

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == features.length - 1 ? 0 : 12,
                    ),
                    child: _HomeFeatureTile(
                      icon: feature.icon,
                      title: feature.title,
                      subtitle: feature.subtitle,
                      isEnabled: feature.isEnabled,
                      onTap: feature.onTap ?? () {},
                    )
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 85 * index),
                          duration: 420.ms,
                        )
                        .slideX(
                          begin: .10,
                          curve: Curves.easeOutCubic,
                        ),
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

class _StudentHomeFeature {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isEnabled;

  const _StudentHomeFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isEnabled = true,
  });
}

class _WelcomeCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _WelcomeCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primaryBlue,
            Color(0xFF0077B6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.22),
            blurRadius: 26,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white70,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
class _HomeFeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isEnabled;
  final VoidCallback onTap;

  const _HomeFeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const softOrange = Color(0xFFF4A261);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          height: 94,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isEnabled
                  ? AppColors.primaryBlue.withOpacity(.08)
                  : AppColors.textGrey.withOpacity(.07),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(.05),
                blurRadius: 15,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: isEnabled
                      ? LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            AppColors.primaryBlue.withOpacity(.16),
                            AppColors.primaryBlue.withOpacity(.05),
                          ],
                        )
                      : null,
                  color: isEnabled
                      ? null
                      : AppColors.textGrey.withOpacity(.07),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isEnabled
                        ? AppColors.primaryBlue.withOpacity(.10)
                        : AppColors.textGrey.withOpacity(.05),
                  ),
                ),
                child: Icon(
                  icon,
                  color: isEnabled
                      ? AppColors.primaryBlue
                      : AppColors.textGrey,
                  size: 29,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: isEnabled
                            ? AppColors.primaryBlue
                            : AppColors.textGrey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textGrey.withOpacity(
                          isEnabled ? .90 : .65,
                        ),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isEnabled
                      ? softOrange.withOpacity(.10)
                      : AppColors.textGrey.withOpacity(.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isEnabled
                      ? softOrange
                      : AppColors.textGrey.withOpacity(.55),
                  size: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
void _showRoadmapSheet(
  BuildContext context,
  HomeController controller,
) {
  if (!controller.hasLatestLearningPlan) {
    controller.showNoLearningPlanMessage();
    return;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _HomeRoadmapSheet(),
  );
}

class _HomeRoadmapSheet extends GetView<HomeController> {
  const _HomeRoadmapSheet();

  Future<void> _showPlan(
    BuildContext context,
    Future<AssessmentAiLearningPlan?> Function() loader,
  ) async {
    final plan = await loader();

    if (plan == null || !context.mounted) return;

    final cache = controller.latestLearningPlanCache.value;

    if (cache == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LatestLearningPlanSheet(
        plan: plan,
        sessionId: cache.assessmentSessionId,
        careerPath: cache.careerPath,
      ),
    );
  }

  Future<void> _showPlanOptions(BuildContext context) async {
    int selectedWeeks = 2;
    int selectedHours = 3;

    final result = await showModalBottomSheet<Map<String, int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.textGrey.withOpacity(.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'جهز خطة التطوير',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.primaryBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'حدد مدة الخطة وعدد ساعات التعلم أسبوعياً.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _HomePlanStepper(
                        title: 'عدد الأسابيع',
                        value: selectedWeeks,
                        min: 1,
                        max: 12,
                        onChanged: (value) {
                          setState(() {
                            selectedWeeks = value;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      _HomePlanStepper(
                        title: 'ساعات أسبوعياً',
                        value: selectedHours,
                        min: 1,
                        max: 40,
                        onChanged: (value) {
                          setState(() {
                            selectedHours = value;
                          });
                        },
                      ),
                      const SizedBox(height: 22),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            {
                              'weeks': selectedWeeks,
                              'hours_per_week': selectedHours,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(
                            double.infinity,
                            54,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        icon: const Icon(
                          Icons.auto_awesome_rounded,
                        ),
                        label: const Text(
                          'إنشاء الخطة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (result == null || !context.mounted) return;

    await _showPlan(
      context,
      () => controller.generateAiLearningPlan(
        weeks: result['weeks'] ?? 2,
        hoursPerWeek: result['hours_per_week'] ?? 3,
      ),
    );
  }

  Future<void> _showRetestSkillsPicker(BuildContext context) async {
    await controller.loadLatestLearningPlan(silent: true);
    final cache = controller.latestLearningPlanCache.value;
    final roadmap = controller.latestRoadmap;

    if (cache == null || roadmap.isEmpty) {
      controller.showNoLearningPlanMessage();
      return;
    }

    final selectedSkillIds = <int>{};

    final result = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                height: MediaQuery.of(context).size.height * .82,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.textGrey.withOpacity(.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'اختر المهارات لإعادة الاختبار',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.primaryBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'حدد مهارة أو أكثر من خريطة التطوير، وبعدها سنبدأ اختبار تحديد مستوى جديد لهذه المهارات فقط.',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textGrey,
                        height: 1.55,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: roadmap.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = roadmap[index];
                          final isSelected = selectedSkillIds.contains(item.skillId);

                          return InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedSkillIds.remove(item.skillId);
                                } else {
                                  selectedSkillIds.add(item.skillId);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF16A34A)
                                      : AppColors.primaryBlue.withOpacity(.07),
                                  width: isSelected ? 1.4 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withOpacity(.05),
                                    blurRadius: 14,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF16A34A)
                                          : AppColors.primaryBlue.withOpacity(.09),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isSelected
                                          ? Icons.check_rounded
                                          : Icons.school_rounded,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.skillName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            color: AppColors.primaryBlue,
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _levelLineText(item),
                                          style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            color: AppColors.textGrey,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _PlanMiniChip(
                                    icon: _roadmapStatusIcon(item),
                                    text: _roadmapStatusText(item),
                                    color: _roadmapStatusColor(item),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: selectedSkillIds.isEmpty
                          ? null
                          : () {
                              Navigator.pop(
                                context,
                                selectedSkillIds.toList(),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.textGrey.withOpacity(.25),
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        selectedSkillIds.isEmpty
                            ? 'اختر مهارة للبدء'
                            : 'ابدأ الاختبار (${selectedSkillIds.length})',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (result == null || result.isEmpty) return;

    final selectedItems = roadmap
        .where((item) => result.contains(item.skillId))
        .toList(growable: false);

    final skillNames = <int, String>{
      for (final item in selectedItems) item.skillId: item.skillName,
    };

    if (context.mounted) {
      Navigator.of(context).pop();
    }

    await Future.delayed(const Duration(milliseconds: 160));

    Get.toNamed(
      Routes.assessment,
      arguments: {
        'careerPathId': cache.careerPathId,
        'cvId': cache.cvId,
        'skillIds': result,
        'skillNames': skillNames,
        'isRetest': true,
        'forceNewSession': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * .88,
        ),
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Obx(() {
          final cache = controller.latestLearningPlanCache.value;
          final roadmap = controller.latestRoadmap;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.textGrey.withOpacity(.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.actionYellow.withOpacity(.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.route_rounded,
                        color: AppColors.actionYellow,
                        size: 28,
                      ),
                    )
                        .animate(
                          onPlay: (animationController) {
                            animationController.repeat(
                              reverse: true,
                            );
                          },
                        )
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.06, 1.06),
                          duration: 1600.ms,
                        ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'خريطة التطوير',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: AppColors.primaryBlue,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cache == null
                                ? 'لا توجد جلسة محفوظة بعد'
                                : 'جلسة #${cache.assessmentSessionId}',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => _CuteHomeRoadmapButton(
                          text: controller.isGeneratingAiPlan.value
                              ? 'جاري التجهيز...'
                              : 'اصنع خطة ذكية',
                          icon: Icons.auto_awesome_rounded,
                          color: AppColors.actionYellow,
                          isLoading:
                              controller.isGeneratingAiPlan.value,
                          onTap:
                              controller.isGeneratingAiPlan.value
                                  ? null
                                  : () {
                                      _showPlanOptions(context);
                                    },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(
                        () => _CuteHomeRoadmapButton(
                          text:
                              controller.isLoadingLatestAiPlan.value
                                  ? 'جاري الجلب...'
                                  : 'آخر خطة',
                          icon: Icons.history_rounded,
                          color: AppColors.primaryBlue,
                          isLoading:
                              controller.isLoadingLatestAiPlan.value,
                          onTap:
                              controller.isLoadingLatestAiPlan.value
                                  ? null
                                  : () {
                                      _showPlan(
                                        context,
                                        controller
                                            .getLatestAiLearningPlan,
                                      );
                                    },
                        ),
                      ),
                    ),
                  ],
                ),
                if (roadmap.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _CuteHomeRoadmapButton(
                    text: 'إعادة تحديد المستوى',
                    icon: Icons.psychology_alt_rounded,
                    color: const Color(0xFF16A34A),
                    isLoading: false,
                    onTap: () {
                      _showRetestSkillsPicker(context);
                    },
                  ),
                ],
                const SizedBox(height: 18),
                if (controller.isLoadingLatestLearningPlan.value)
                  const Padding(
                    padding: EdgeInsets.only(
                      top: 40,
                      bottom: 40,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.actionYellow,
                      ),
                    ),
                  )
                else if (roadmap.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Text(
                      'لا توجد خريطة تطوير محفوظة حالياً. أنه الاختبار أولاً ليتم حفظ الرودماب هنا.',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textGrey,
                        height: 1.5,
                      ),
                    ),
                  )
                else
                  ...List.generate(
                    roadmap.length,
                    (index) {
                      return _HomeRoadmapItem(
                        item: roadmap[index],
                        index: index,
                        isLast: index == roadmap.length - 1,
                      )
                          .animate()
                          .fadeIn(
                            delay: Duration(
                              milliseconds: 80 * index,
                            ),
                            duration: 420.ms,
                          )
                          .slideY(begin: .16);
                    },
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _HomeRoadmapItem extends StatelessWidget {
  final AssessmentLearningPathItem item;
  final int index;
  final bool isLast;

  const _HomeRoadmapItem({
    required this.item,
    required this.index,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isReady = item.targetLevel > 0 && item.currentLevel >= item.targetLevel;
    final statusColor = _roadmapStatusColor(item);
    final statusIcon = _roadmapStatusIcon(item);

    return Stack(
      children: [
        PositionedDirectional(
          start: 22,
          top: 54,
          bottom: isLast ? 22 : 0,
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.actionYellow.withOpacity(.85),
                  AppColors.primaryBlue.withOpacity(.16),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppColors.actionYellow,
                      Color(0xFFFFC94A),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          AppColors.actionYellow.withOpacity(.30),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColors.primaryBlue.withOpacity(.06),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.skillName,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                color: AppColors.primaryBlue,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _PlanMiniChip(
                            icon: statusIcon,
                            text: _roadmapStatusText(item),
                            color: statusColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _levelLineText(item),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (item.resources.isEmpty)
                        Text(
                          isReady
                              ? 'مناسبة لسوق العمل حالياً. يمكنك إعادة اختبارها لاحقاً إذا طورت نفسك أكثر.'
                              : item.currentLevel <= 0
                                  ? 'لم يتم حفظ نتيجة دقيقة لهذه المهارة بعد. أعد الاختبار ليتم تحديث مستواك.'
                                  : 'لا توجد مصادر مقترحة حالياً.',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: isReady ? const Color(0xFF16A34A) : AppColors.textGrey,
                            height: 1.45,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      else
                        ...item.resources.map(
                          (resource) {
                            return _HomeResourceTile(
                              resource: resource,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeResourceTile extends StatelessWidget {
  final AssessmentLearningResource resource;

  const _HomeResourceTile({
    required this.resource,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.actionYellow.withOpacity(.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: AppColors.actionYellow,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title.isEmpty
                      ? 'مصدر تعليمي'
                      : resource.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    height: 1.35,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${resource.provider.isEmpty ? 'مصدر' : resource.provider} · ${resource.estimatedHours.isEmpty ? 'غير محدد' : resource.estimatedHours} ساعة',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textGrey,
                    fontSize: 11,
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

class _CuteHomeRoadmapButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback? onTap;

  const _CuteHomeRoadmapButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 46,
        decoration: BoxDecoration(
          color: color.withOpacity(.11),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withOpacity(.22),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            else
              Icon(
                icon,
                color: color,
                size: 19,
              ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomePlanStepper extends StatelessWidget {
  final String title;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _HomePlanStepper({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _HomeSmallRoundButton(
            icon: Icons.remove_rounded,
            onTap: value <= min
                ? null
                : () {
                    onChanged(value - 1);
                  },
          ),
          SizedBox(
            width: 54,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _HomeSmallRoundButton(
            icon: Icons.add_rounded,
            onTap: value >= max
                ? null
                : () {
                    onChanged(value + 1);
                  },
          ),
        ],
      ),
    );
  }
}

class _HomeSmallRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _HomeSmallRoundButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.actionYellow.withOpacity(.16)
              : AppColors.textGrey.withOpacity(.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: enabled
              ? AppColors.actionYellow
              : AppColors.textGrey,
          size: 21,
        ),
      ),
    );
  }
}


bool _isMarketReadyItem(AssessmentLearningPathItem item) {
  return item.currentLevel > 0 &&
      item.targetLevel > 0 &&
      item.currentLevel >= item.targetLevel;
}

bool _isUnknownLevelItem(AssessmentLearningPathItem item) {
  return item.currentLevel <= 0;
}

String _levelLineText(AssessmentLearningPathItem item) {
  if (_isUnknownLevelItem(item)) {
    if (item.targetLevel > 0) {
      return 'المستوى الحالي غير محفوظ · الهدف ${item.targetLevel.toStringAsFixed(1)}';
    }
    return 'المستوى الحالي غير محفوظ';
  }

  if (item.targetLevel <= 0) {
    return 'حاليًا ${item.currentLevel.toStringAsFixed(1)}';
  }

  return 'حاليًا ${item.currentLevel.toStringAsFixed(1)} · الهدف ${item.targetLevel.toStringAsFixed(1)}';
}

String _roadmapStatusText(AssessmentLearningPathItem item) {
  if (_isMarketReadyItem(item)) return 'مناسبة';
  if (_isUnknownLevelItem(item)) return 'غير محفوظة';
  return _priorityText(item.priority);
}

Color _roadmapStatusColor(AssessmentLearningPathItem item) {
  if (_isMarketReadyItem(item)) return const Color(0xFF16A34A);
  if (_isUnknownLevelItem(item)) return AppColors.textGrey;
  return AppColors.actionYellow;
}

IconData _roadmapStatusIcon(AssessmentLearningPathItem item) {
  if (_isMarketReadyItem(item)) return Icons.check_circle_rounded;
  if (_isUnknownLevelItem(item)) return Icons.help_outline_rounded;
  return Icons.priority_high_rounded;
}

String _priorityText(String priority) {
  switch (priority.toLowerCase().trim()) {
    case 'market_ready':
    case 'ready':
    case 'suitable':
      return 'مناسبة';
    case 'high':
      return 'عالية';
    case 'medium':
      return 'متوسطة';
    case 'low':
      return 'منخفضة';
    case 'unknown':
    case 'not_saved':
      return 'غير محفوظة';
    default:
      return 'تطوير';
  }
}

class _LatestLearningPlanCard extends GetView<HomeController> {
  const _LatestLearningPlanCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cache = controller.latestLearningPlanCache.value;
      final plan = controller.latestAiLearningPlan.value;
      final hasPlan = cache != null;

      return InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          if (!hasPlan) {
            controller.showNoLearningPlanMessage();
            return;
          }

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => _LatestLearningPlanSheet(
              plan: plan,
              sessionId: cache.assessmentSessionId,
              careerPath: cache.careerPath,
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.actionYellow.withOpacity(.22),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.actionYellow.withOpacity(.10),
                blurRadius: 20,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppColors.actionYellow,
                      Color(0xFFFFC94A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(21),
                  boxShadow: [
                    BoxShadow(
                      color:
                          AppColors.actionYellow.withOpacity(.22),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child:
                    controller.isLoadingLatestLearningPlan.value
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
              )
                  .animate(
                    onPlay: (animationController) {
                      animationController.repeat(reverse: true);
                    },
                  )
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.05, 1.05),
                    duration: 1600.ms,
                  ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'خطة التطوير الذكية',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.primaryBlue,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      hasPlan
                          ? plan == null
                              ? 'آخر جلسة محفوظة #${cache.assessmentSessionId}'
                              : '${plan.weeks} أسابيع · ${plan.hoursPerWeek} ساعات أسبوعياً'
                          : 'أنه الاختبار وأنشئ Roadmap لتظهر الخطة هنا.',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textGrey,
                        fontSize: 12,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (hasPlan &&
                        (cache.careerPath.isNotEmpty ||
                            (plan?.plan.careerPath ?? '')
                                .isNotEmpty)) ...[
                      const SizedBox(height: 5),
                      Text(
                        cache.careerPath.isNotEmpty
                            ? cache.careerPath
                            : plan!.plan.careerPath,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.actionYellow,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primaryBlue,
                size: 18,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _LatestLearningPlanSheet extends StatelessWidget {
  final AssessmentAiLearningPlan? plan;
  final int sessionId;
  final String careerPath;

  const _LatestLearningPlanSheet({
    required this.plan,
    required this.sessionId,
    required this.careerPath,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * .86,
        ),
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.textGrey.withOpacity(.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'خطة التطوير الذكية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.primaryBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                plan == null
                    ? 'تم حفظ جلسة التقييم رقم #$sessionId. أنشئ خطة ذكية من صفحة التقرير لتظهر التفاصيل هنا.'
                    : plan!.plan.summaryAr.isNotEmpty
                        ? plan!.plan.summaryAr
                        : plan!.summaryText,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textDark,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              _LearningPlanMetaCard(
                sessionId: sessionId,
                careerPath: careerPath.isNotEmpty
                    ? careerPath
                    : plan?.plan.careerPath ?? '',
                weeks: plan?.weeks,
                hoursPerWeek: plan?.hoursPerWeek,
              ),
              if (plan != null) ...[
                const SizedBox(height: 16),
                ...List.generate(
                  plan!.plan.weeks.length,
                  (index) {
                    final week = plan!.plan.weeks[index];

                    return _LearningPlanWeekCard(
                      week: week,
                      index: index,
                    )
                        .animate()
                        .fadeIn(
                          delay: Duration(
                            milliseconds: 80 * index,
                          ),
                        )
                        .slideY(begin: .16);
                  },
                ),
                if (plan!.plan.finalOutcomeAr.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          AppColors.primaryBlue.withOpacity(.08),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      plan!.plan.finalOutcomeAr,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.primaryBlue,
                        height: 1.6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningPlanMetaCard extends StatelessWidget {
  final int sessionId;
  final String careerPath;
  final int? weeks;
  final int? hoursPerWeek;

  const _LearningPlanMetaCard({
    required this.sessionId,
    required this.careerPath,
    required this.weeks,
    required this.hoursPerWeek,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _PlanMiniChip(
            icon: Icons.badge_rounded,
            text: 'جلسة #$sessionId',
            color: AppColors.primaryBlue,
          ),
          _PlanMiniChip(
            icon: Icons.route_rounded,
            text: careerPath.isEmpty
                ? 'مسار غير محدد'
                : careerPath,
            color: AppColors.actionYellow,
          ),
          if (weeks != null && weeks! > 0)
            _PlanMiniChip(
              icon: Icons.calendar_month_rounded,
              text: '$weeks أسابيع',
              color: Colors.green,
            ),
          if (hoursPerWeek != null && hoursPerWeek! > 0)
            _PlanMiniChip(
              icon: Icons.schedule_rounded,
              text: '$hoursPerWeek ساعات أسبوعياً',
              color: AppColors.primaryBlue,
            ),
        ],
      ),
    );
  }
}

class _LearningPlanWeekCard extends StatelessWidget {
  final AssessmentAiPlanWeek week;
  final int index;

  const _LearningPlanWeekCard({
    required this.week,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأسبوع ${week.weekNumber == 0 ? index + 1 : week.weekNumber}',
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.actionYellow,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (week.focusSkills.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'المهارات: ${week.focusSkills.join('، ')}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 10),
          ...week.goals.map(
            (goal) {
              return _PlanLine(
                icon: Icons.flag_rounded,
                text: goal,
              );
            },
          ),
          ...week.tasks.map(
            (task) {
              return _PlanLine(
                icon: Icons.task_alt_rounded,
                text:
                    '${task.title} · ${task.estimatedHours.toStringAsFixed(0)} ساعة · ${task.skill}',
              );
            },
          ),
          if (week.expectedOutcome.isNotEmpty)
            _PlanLine(
              icon: Icons.workspace_premium_rounded,
              text: week.expectedOutcome,
            ),
        ],
      ),
    );
  }
}

class _PlanLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PlanLine({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.actionYellow,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanMiniChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _PlanMiniChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Container(
        height: 128,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: AppColors.primaryBlue.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.07),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.primaryBlue,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
