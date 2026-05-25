import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/tasks/student_task_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/models/student/tasks/student_task_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class StudentTasksView extends StatefulWidget {
  const StudentTasksView({super.key});

  @override
  State<StudentTasksView> createState() => _StudentTasksViewState();
}

class _StudentTasksViewState extends State<StudentTasksView> {
  final StudentTaskController controller = Get.find<StudentTaskController>();

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        controller.fetchInitialTasks();
      }
    });
  }

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
            'التاسكات',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: RefreshIndicator(
          color: AppColors.actionYellow,
          onRefresh: controller.refreshTasks,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TasksHero()
                    .animate()
                    .fadeIn(duration: 520.ms)
                    .slideY(begin: .22, curve: Curves.easeOutBack),

                const SizedBox(height: 22),

                const _SearchBox()
                    .animate()
                    .fadeIn(delay: 120.ms)
                    .slideY(begin: .18),

                const SizedBox(height: 26),

                Obx(() {
                  if (controller.isLoadingRecommended.value) {
                    return const _SectionLoading(title: 'مقترحة لك');
                  }

                  if (controller.recommendedTasks.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                        title: 'مقترحة لك',
                        badge: '${controller.recommendedTasks.length}',
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 178,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.recommendedTasks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final task = controller.recommendedTasks[index];

                            return _RecommendedTaskCard(
                                  task: task,
                                  onTap: () => Get.toNamed(
                                    Routes.studentTaskDetails,
                                    arguments: task.id,
                                  ),
                                )
                                .animate()
                                .fadeIn(
                                  delay: Duration(milliseconds: 100 * index),
                                )
                                .slideX(begin: .25)
                                .scale(begin: const Offset(.96, .96));
                          },
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  );
                }),

                Obx(
                  () => _SectionTitle(
                    title: 'تاسكات الشركات',
                    badge: '${controller.exploreTasks.length}',
                  ),
                ),

                const SizedBox(height: 14),

                Obx(() {
                  if (controller.isLoadingExplore.value ||
                      controller.isSearching.value) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.actionYellow,
                        ),
                      ),
                    );
                  }

                  if (controller.exploreTasks.isEmpty) {
                    return const _EmptyTasks();
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.exploreTasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final task = controller.exploreTasks[index];

                      return _ExploreTaskCard(
                            task: task,
                            onTap: () => Get.toNamed(
                              Routes.studentTaskDetails,
                              arguments: task.id,
                            ),
                          )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 80 * index),
                            duration: 450.ms,
                          )
                          .slideY(begin: .24, curve: Curves.easeOutCubic);
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

class _SectionLoading extends StatelessWidget {
  final String title;

  const _SectionLoading({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title, badge: '...'),
        const SizedBox(height: 14),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(.06),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.actionYellow),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _TasksHero extends StatelessWidget {
  const _TasksHero();

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
                Icons.task_alt_rounded,
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
          const Text(
            'تاسكات تدريبية حقيقية',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'استكشف مهام من الشركات، أو ابدأ بالمهام المقترحة حسب مهاراتك.',
            textAlign: TextAlign.center,
            style: TextStyle(
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

class _SearchBox extends GetView<StudentTaskController> {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.searchController,
      onChanged: controller.onSearchChanged,
      style: const TextStyle(fontFamily: 'Cairo'),
      decoration: InputDecoration(
        hintText: 'ابحث عن تاسك حسب العنوان...',
        hintStyle: const TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.textGrey,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.primaryBlue,
        ),
        suffixIcon: IconButton(
          onPressed: controller.refreshTasks,
          icon: const Icon(Icons.close_rounded, color: AppColors.actionYellow),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(
            color: AppColors.actionYellow,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String badge;

  const _SectionTitle({required this.title, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.actionYellow.withOpacity(.14),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            badge,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.actionYellow,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecommendedTaskCard extends GetView<StudentTaskController> {
  final StudentTaskModel task;
  final VoidCallback onTap;

  const _RecommendedTaskCard({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.actionYellow.withOpacity(.30)),
            boxShadow: [
              BoxShadow(
                color: AppColors.actionYellow.withOpacity(.14),
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
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.actionYellow,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${task.matchScore ?? 0}% تطابق',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.actionYellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textGrey,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
              const Spacer(),
              Text(
                task.company.industry.isEmpty
                    ? task.company.name
                    : task.company.industry,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textGrey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _TaskBadge(text: task.difficultyLevel),
                  const SizedBox(width: 8),
                  _TaskBadge(text: controller.deadlineText(task.deadline)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExploreTaskCard extends GetView<StudentTaskController> {
  final StudentTaskModel task;
  final VoidCallback onTap;

  const _ExploreTaskCard({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(.08)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(.07),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.assignment_rounded,
                color: AppColors.primaryBlue,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task.company.industry.isEmpty
                        ? task.company.name
                        : task.company.industry,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      _TaskBadge(text: task.difficultyLevel),
                      const SizedBox(width: 8),
                      _TaskBadge(text: controller.deadlineText(task.deadline)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textGrey,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskBadge extends StatelessWidget {
  final String text;

  const _TaskBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.actionYellow.withOpacity(.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text.isEmpty ? 'غير محدد' : text,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.actionYellow,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            color: AppColors.actionYellow,
            size: 64,
          ),
          SizedBox(height: 14),
          Text(
            'لا توجد تاسكات حالياً',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'جرّب البحث بعنوان مختلف أو اسحب لتحديث الصفحة.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey),
          ),
        ],
      ),
    ).animate().fadeIn().scale(curve: Curves.easeOutBack);
  }
}
