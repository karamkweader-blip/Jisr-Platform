import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/tasks/student_task_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/student/tasks/student_task_model.dart';

class StudentTaskDetailsView extends StatefulWidget {
  const StudentTaskDetailsView({super.key});

  @override
  State<StudentTaskDetailsView> createState() => _StudentTaskDetailsViewState();
}

class _StudentTaskDetailsViewState extends State<StudentTaskDetailsView> {
  final StudentTaskController controller = Get.find<StudentTaskController>();

  @override
  void initState() {
    super.initState();

    final taskId = Get.arguments as int;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTaskDetails(taskId);
    });
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
            'تفاصيل التاسك',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoadingDetails.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.actionYellow),
            );
          }

          final task = controller.selectedTask.value;

          if (task == null) {
            return const Center(
              child: Text(
                'لم يتم العثور على التاسك',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textGrey,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
            child: Column(
              children: [
                _TaskHero(task: task)
                    .animate()
                    .fadeIn(duration: 520.ms)
                    .slideY(begin: .22, curve: Curves.easeOutBack),

                const SizedBox(height: 20),

                _InfoCard(
                  icon: Icons.description_rounded,
                  title: 'الوصف',
                  value: task.description,
                ).animate().fadeIn(delay: 100.ms).slideX(begin: .22),

                _InfoCard(
                  icon: Icons.business_rounded,
                  title: 'الشركة',
                  value: task.company.name == 'شركة غير محددة'
                      ? task.company.industry
                      : task.company.name,
                ).animate().fadeIn(delay: 170.ms).slideX(begin: .22),

                _InfoGrid(
                  task: task,
                ).animate().fadeIn(delay: 240.ms).slideY(begin: .18),

                const SizedBox(height: 16),

                _ListSection(
                  icon: Icons.inventory_rounded,
                  title: 'المخرجات المطلوبة',
                  items: task.deliverables,
                ).animate().fadeIn(delay: 320.ms).slideX(begin: .22),

                _ListSection(
                  icon: Icons.rule_rounded,
                  title: 'معايير القبول',
                  items: task.acceptanceCriteria,
                ).animate().fadeIn(delay: 400.ms).slideX(begin: .22),

                _SkillsSection(
                  skills: task.skills,
                ).animate().fadeIn(delay: 480.ms).slideY(begin: .20),

                const SizedBox(height: 22),

                _ApplyButton()
                    .animate()
                    .fadeIn(delay: 560.ms)
                    .slideY(begin: .25)
                    .scale(begin: const Offset(.96, .96)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _TaskHero extends GetView<StudentTaskController> {
  final StudentTaskDetailsModel task;

  const _TaskHero({required this.task});

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
                Icons.assignment_turned_in_rounded,
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
          Text(
            task.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroBadge(icon: Icons.speed_rounded, text: task.difficultyLevel),
              _HeroBadge(
                icon: Icons.timer_rounded,
                text: '${task.durationDays} أيام',
              ),
              _HeroBadge(
                icon: Icons.event_rounded,
                text: controller.deadlineText(task.deadline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeroBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.actionYellow, size: 16),
          const SizedBox(width: 5),
          Text(
            text.isEmpty ? 'غير محدد' : text,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final shownValue = value.trim().isEmpty ? 'غير محدد' : value;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.07),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.actionYellow),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  shownValue,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textDark,
                    height: 1.6,
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

class _InfoGrid extends GetView<StudentTaskController> {
  final StudentTaskDetailsModel task;

  const _InfoGrid({required this.task});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _MiniInfoCard(
          icon: Icons.speed_rounded,
          title: 'الصعوبة',
          value: task.difficultyLevel,
        ),
        _MiniInfoCard(
          icon: Icons.hourglass_bottom_rounded,
          title: 'المدة',
          value: '${task.durationDays} أيام',
        ),
        _MiniInfoCard(
          icon: Icons.event_busy_rounded,
          title: 'الموعد النهائي',
          value: controller.dateOnly(task.deadline),
        ),
        _MiniInfoCard(
          icon: Icons.upload_file_rounded,
          title: 'نوع التسليم',
          value: task.submissionType,
        ),
      ],
    );
  }
}

class _MiniInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MiniInfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final shownValue = value.trim().isEmpty ? 'غير محدد' : value;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(.07)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.06),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.actionYellow, size: 27),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textGrey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            shownValue,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;

  const _ListSection({
    required this.icon,
    required this.title,
    required this.items,
  });

  List<String> _normalizeItems(List<String> rawItems) {
    return rawItems
        .expand((item) => item.split(','))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final normalized = _normalizeItems(items);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.07),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.actionYellow),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (normalized.isEmpty)
            const Text(
              'غير محدد',
              style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey),
            )
          else
            ...normalized.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.actionYellow,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textDark,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SkillsSection extends StatelessWidget {
  final List<TaskSkillModel> skills;

  const _SkillsSection({required this.skills});

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.07),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology_rounded, color: AppColors.actionYellow),
              SizedBox(width: 10),
              Text(
                'المهارات المطلوبة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...skills.map((skill) => _SkillRequirement(skill: skill)),
        ],
      ),
    );
  }
}

class _SkillRequirement extends StatelessWidget {
  final TaskSkillModel skill;

  const _SkillRequirement({required this.skill});

  @override
  Widget build(BuildContext context) {
    final level = (skill.requiredLevel / 5).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(.06)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  skill.name,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: skill.mandatory
                      ? AppColors.actionYellow.withOpacity(.14)
                      : AppColors.primaryBlue.withOpacity(.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  skill.mandatory ? 'إجباري' : 'اختياري',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: skill.mandatory
                        ? AppColors.actionYellow
                        : AppColors.primaryBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  skill.category,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                'الوزن ${skill.weight}%',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 8,
              color: AppColors.primaryBlue.withOpacity(.10),
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: level,
                alignment: Alignment.centerRight,
                child: Container(color: AppColors.actionYellow),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'المستوى المطلوب: ${skill.requiredLevel}/5',
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Get.snackbar(
          'قريباً',
          'سيتم ربط التقديم على التاسك لاحقاً',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(.20),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'التقديم على التاسك',
              style: TextStyle(
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
