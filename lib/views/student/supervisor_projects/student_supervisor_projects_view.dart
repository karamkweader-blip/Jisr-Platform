import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/supervisor_projects/student_supervisor_project_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/models/student/supervisor_projects/student_supervisor_project_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class StudentSupervisorProjectsView extends StatefulWidget {
  const StudentSupervisorProjectsView({super.key});

  @override
  State<StudentSupervisorProjectsView> createState() =>
      _StudentSupervisorProjectsViewState();
}

class _StudentSupervisorProjectsViewState
    extends State<StudentSupervisorProjectsView> {
  late final StudentSupervisorProjectController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<StudentSupervisorProjectController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.projects.isEmpty &&
          !controller.isLoadingProjects.value) {
        controller.fetchProjects();
      }
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
          title: const Text(
            'مشاريع المشرفين',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
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
        body: RefreshIndicator(
          color: AppColors.actionYellow,
          onRefresh: controller.refreshProjects,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
                sliver: SliverToBoxAdapter(child: _ProjectsHero()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                sliver: SliverToBoxAdapter(
                  child: _SearchAndFilters(controller: controller),
                ),
              ),
              Obx(() => _buildBody()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
                sliver: SliverToBoxAdapter(
                  child: Obx(
                    () => controller.hasMoreProjects
                        ? SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: controller.isLoadingMore.value
                                  ? null
                                  : () => controller.fetchProjects(
                                        loadMore: true,
                                      ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryBlue,
                                side: BorderSide(
                                  color:
                                      AppColors.primaryBlue.withOpacity(.18),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17),
                                ),
                              ),
                              child: controller.isLoadingMore.value
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.3,
                                        color: AppColors.actionYellow,
                                      ),
                                    )
                                  : const Text(
                                      'تحميل المزيد',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoadingProjects.value && controller.projects.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.actionYellow),
        ),
      );
    }

    if (controller.listError.value.isNotEmpty && controller.projects.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _ProjectsState(
          icon: Icons.cloud_off_rounded,
          title: 'تعذر جلب المشاريع',
          subtitle: controller.listError.value,
          actionLabel: 'إعادة المحاولة',
          onAction: controller.fetchProjects,
        ),
      );
    }

    if (controller.projects.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: _ProjectsState(
          icon: Icons.folder_open_rounded,
          title: 'لا توجد مشاريع حالياً',
          subtitle: 'ستظهر مشاريع المشرفين هنا فور توفرها.',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, index) {
            if (index.isOdd) return const SizedBox(height: 12);
            final projectIndex = index ~/ 2;
            return StudentSupervisorProjectCard(
              project: controller.projects[projectIndex],
              controller: controller,
            );
          },
          childCount: controller.projects.length * 2 - 1,
        ),
      ),
    );
  }
}

class _ProjectsHero extends StatelessWidget {
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
      child: const Row(
        children: <Widget>[
          CircleAvatar(
            radius: 29,
            backgroundColor: Colors.white12,
            child: Icon(
              Icons.rocket_launch_outlined,
              color: AppColors.actionYellow,
              size: 30,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'مشروعك القادم مع مشرف',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'اختر مشروعاً، قدّم عليه، وبعد القبول تابع مهامه وتسليماته.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.55,
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

class _SearchAndFilters extends StatelessWidget {
  final StudentSupervisorProjectController controller;

  const _SearchAndFilters({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: controller.searchController,
          onChanged: controller.onSearchChanged,
          maxLength: 100,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            counterText: '',
            hintText: 'ابحث بالعنوان أو الوصف أو النتيجة المتوقعة',
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.primaryBlue,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: AppColors.primaryBlue.withOpacity(.08),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: <MapEntry<String, String>>[
                const MapEntry<String, String>('', 'الكل'),
                const MapEntry<String, String>('Beginner', 'مبتدئ'),
                const MapEntry<String, String>('Intermediate', 'متوسط'),
                const MapEntry<String, String>('Advanced', 'متقدم'),
              ].map((entry) {
                final selected = controller.selectedLevel.value == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(entry.value),
                    selected: selected,
                    onSelected: (_) => controller.selectLevel(entry.key),
                    selectedColor: AppColors.primaryBlue,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                    side: BorderSide(
                      color: AppColors.primaryBlue.withOpacity(.10),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class StudentSupervisorProjectCard extends StatelessWidget {
  final StudentSupervisorProjectModel project;
  final StudentSupervisorProjectController controller;
  final bool compact;

  const StudentSupervisorProjectCard({
    super.key,
    required this.project,
    required this.controller,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final stateColor = project.actions.canOpenAssignment
        ? const Color(0xFF2E9D65)
        : project.application?.status == 'rejected'
            ? const Color(0xFFD65353)
            : project.actions.canApply
                ? AppColors.actionYellow
                : AppColors.primaryBlue;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        onTap: () => Get.toNamed(
          Routes.studentSupervisorProjectDetails,
          arguments: project.id,
        ),
        borderRadius: BorderRadius.circular(23),
        child: Container(
          padding: EdgeInsets.all(compact ? 14 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: AppColors.primaryBlue.withOpacity(.08)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(.05),
                blurRadius: 15,
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
                      color: AppColors.primaryBlue.withOpacity(.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.account_tree_outlined,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          project.title,
                          maxLines: compact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project.supervisor.name.isEmpty
                              ? 'مشرف غير محدد'
                              : 'المشرف: ${project.supervisor.name}',
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: stateColor.withOpacity(.10),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      controller.applyStateText(project),
                      style: TextStyle(
                        color: stateColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              if (!compact && (project.description?.isNotEmpty ?? false)) ...[
                const SizedBox(height: 12),
                Text(
                  project.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11,
                    height: 1.55,
                  ),
                ),
              ],
              const SizedBox(height: 13),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: <Widget>[
                  ProjectMetaBadge(
                    icon: Icons.signal_cellular_alt_rounded,
                    text: controller.levelText(project.level),
                  ),
                  ProjectMetaBadge(
                    icon: Icons.task_alt_outlined,
                    text: '${project.tasksSummary.count} مهام',
                  ),
                  ProjectMetaBadge(
                    icon: Icons.schedule_rounded,
                    text: '${project.tasksSummary.estimatedTotalHours} ساعة',
                  ),
                  ProjectMetaBadge(
                    icon: Icons.group_outlined,
                    text: project.capacity.maxStudents == null
                        ? 'عدد غير محدود'
                        : project.capacity.isFull
                            ? 'مكتمل'
                            : '${project.capacity.remainingSlots ?? 0} أماكن',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectMetaBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const ProjectMetaBadge({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(.055),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: AppColors.primaryBlue, size: 13),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectsState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _ProjectsState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 55, color: AppColors.primaryBlue.withOpacity(.45)),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 11,
                height: 1.55,
              ),
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 15),
              TextButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
