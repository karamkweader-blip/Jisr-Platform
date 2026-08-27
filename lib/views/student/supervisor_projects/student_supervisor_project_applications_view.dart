import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/supervisor_projects/student_supervisor_project_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/models/student/supervisor_projects/student_supervisor_project_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class StudentSupervisorProjectApplicationsView extends StatefulWidget {
  const StudentSupervisorProjectApplicationsView({super.key});

  @override
  State<StudentSupervisorProjectApplicationsView> createState() =>
      _StudentSupervisorProjectApplicationsViewState();
}

class _StudentSupervisorProjectApplicationsViewState
    extends State<StudentSupervisorProjectApplicationsView>
    with SingleTickerProviderStateMixin {
  late final StudentSupervisorProjectController controller;
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<StudentSupervisorProjectController>();
    tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchApplications();
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
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
            'تقديمات المشاريع',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'المشاريع المتاحة',
              onPressed: () => Get.toNamed(Routes.studentSupervisorProjects),
              icon: const Icon(Icons.explore_outlined),
            ),
          ],
          bottom: TabBar(
            controller: tabController,
            indicatorColor: AppColors.actionYellow,
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: AppColors.textGrey,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900),
            tabs: const <Tab>[
              Tab(text: 'قيد المراجعة'),
              Tab(text: 'المقبولة'),
              Tab(text: 'المرفوضة'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoadingApplications.value &&
              controller.allApplications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.actionYellow),
            );
          }

          if (controller.applicationsError.value.isNotEmpty &&
              controller.allApplications.isEmpty) {
            return _ApplicationsState(
              icon: Icons.cloud_off_rounded,
              title: 'تعذر جلب التقديمات',
              subtitle: controller.applicationsError.value,
              onRetry: controller.fetchApplications,
            );
          }

          return TabBarView(
            controller: tabController,
            children: <Widget>[
              _ApplicationList(
                items: controller.pendingApplications,
                controller: controller,
                emptyTitle: 'لا توجد طلبات قيد المراجعة',
              ),
              _ApplicationList(
                items: controller.acceptedApplications,
                controller: controller,
                emptyTitle: 'لا توجد مشاريع مقبولة بعد',
              ),
              _ApplicationList(
                items: controller.rejectedApplications,
                controller: controller,
                emptyTitle: 'لا توجد طلبات مرفوضة',
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ApplicationList extends StatelessWidget {
  final List<StudentSupervisorProjectApplicationItem> items;
  final StudentSupervisorProjectController controller;
  final String emptyTitle;

  const _ApplicationList({
    required this.items,
    required this.controller,
    required this.emptyTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        color: AppColors.actionYellow,
        onRefresh: controller.fetchApplications,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * .22),
            _ApplicationsState(
              icon: Icons.inbox_outlined,
              title: emptyTitle,
              subtitle: 'اسحب للأسفل لتحديث الحالة من الباك.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.actionYellow,
      onRefresh: controller.fetchApplications,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) => _ApplicationCard(
          application: items[index],
          controller: controller,
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final StudentSupervisorProjectApplicationItem application;
  final StudentSupervisorProjectController controller;

  const _ApplicationCard({
    required this.application,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final accepted = application.status == 'accepted';
    final rejected = application.status == 'rejected';
    final color = accepted
        ? const Color(0xFF2E9D65)
        : rejected
            ? const Color(0xFFD65353)
            : AppColors.actionYellow;
    final assignmentId = application.projectAssignmentId;
    final canOpen = accepted && assignmentId != null && assignmentId > 0;
    final assignment = application.projectAssignment;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: canOpen
            ? () => controller.openAcceptedAssignment(
                  projectAssignmentId: assignmentId,
                  projectTitle: application.projectTemplate.title,
                )
            : () => Get.toNamed(
                  Routes.studentSupervisorProjectDetails,
                  arguments: application.projectTemplateId,
                ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: color.withOpacity(.12)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(.045),
                blurRadius: 14,
                offset: const Offset(0, 7),
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(.09),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      accepted
                          ? Icons.check_circle_outline_rounded
                          : rejected
                              ? Icons.cancel_outlined
                              : Icons.hourglass_top_rounded,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          application.projectTemplate.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          controller.levelText(
                            application.projectTemplate.level,
                          ),
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(.10),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      controller.applicationStatusText(application.status),
                      style: TextStyle(
                        color: color,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              if (application.message?.isNotEmpty ?? false) ...<Widget>[
                const SizedBox(height: 13),
                _InfoBox(label: 'رسالتك', value: application.message!),
              ],
              if (application.supervisorNotes?.isNotEmpty ?? false) ...<Widget>[
                const SizedBox(height: 8),
                _InfoBox(
                  label: 'ملاحظات المشرف',
                  value: application.supervisorNotes!,
                  color: color,
                ),
              ],
              if (accepted && assignment != null) ...<Widget>[
                const SizedBox(height: 13),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'تقدم المشروع: ${assignment.progressPercentage}%',
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      assignment.status,
                      style: const TextStyle(
                        color: Color(0xFF2E9D65),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    minHeight: 7,
                    value: assignment.progressPercentage.clamp(0, 100) / 100,
                    backgroundColor: color.withOpacity(.08),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
              if (accepted) ...<Widget>[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: canOpen
                        ? () => controller.openAcceptedAssignment(
                              projectAssignmentId: assignmentId,
                              projectTitle: application.projectTemplate.title,
                            )
                        : () => controller.fetchApplications(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canOpen
                          ? const Color(0xFF2E9D65)
                          : AppColors.primaryBlue.withOpacity(.08),
                      foregroundColor:
                          canOpen ? Colors.white : AppColors.primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: Icon(
                      canOpen
                          ? Icons.playlist_add_check_circle_outlined
                          : Icons.refresh_rounded,
                    ),
                    label: Text(
                      canOpen
                          ? 'فتح المهام والتسليمات'
                          : 'بانتظار ربط المشروع من الباك',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoBox({
    required this.label,
    required this.value,
    this.color = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(.045),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 10.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationsState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  const _ApplicationsState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 54, color: AppColors.primaryBlue.withOpacity(.45)),
            const SizedBox(height: 13),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 11,
                height: 1.5,
              ),
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
