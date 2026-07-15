import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/auth_actions_controller.dart';
import 'package:jisr_platform/controllers/student/home/home_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/jisr_app_menu.dart';
import 'package:jisr_platform/core/widgets/company/jisr_animated_logo.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/models/student/assessment/assessment_models.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authActionsController = Get.find<AuthActionsController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: const StudentBottomNav(currentIndex: 1),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          centerTitle: true,
          title: const Text(
            'جسور',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: JisrAppMenu(
            onLogout: authActionsController.logout,
            onLogoutAllSessions: authActionsController.logoutAllSessions,
          ),
          actions: const [
            Padding(
              padding: EdgeInsetsDirectional.only(end: 12),
              child: Center(child: JisrAnimatedLogo(size: 38)),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
            child: Column(
              children: [
                _WelcomeCard(
                      title: controller.homeData.title,
                      subtitle: controller.homeData.subtitle,
                    )
                    .animate()
                    .fadeIn(duration: 520.ms)
                    .slideY(begin: .22, curve: Curves.easeOutBack)
                    .scale(
                      begin: const Offset(.96, .96),
                      end: const Offset(1, 1),
                    ),

                const SizedBox(height: 28),

                Align(
                  alignment: Alignment.centerRight,
                  child: const Text(
                    'خدمات الطالب',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.primaryBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ).animate().fadeIn(delay: 120.ms).slideX(begin: .20),

                const SizedBox(height: 16),

                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: .82,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _HomeFeatureCard(
                          icon: Icons.work_history_rounded,
                          title: 'البورتفوليو',
                          subtitle: 'مشاريعك وإنجازاتك',
                          isEnabled: true,
                          onTap: () => Get.toNamed(Routes.studentPortfolio),
                        )
                        .animate()
                        .fadeIn(delay: 160.ms, duration: 520.ms)
                        .slideY(begin: .25, curve: Curves.easeOutCubic)
                        .scale(begin: const Offset(.95, .95)),

                    _HomeFeatureCard(
                          icon: Icons.task_alt_rounded,
                          title: 'التاسكات',
                          subtitle: 'مهام حقيقية من الشركات',
                          isEnabled: true,
                          onTap: () => Get.toNamed(Routes.studentTasks),
                        )
                        .animate()
                        .fadeIn(delay: 240.ms, duration: 520.ms)
                        .slideY(begin: .25, curve: Curves.easeOutCubic)
                        .scale(begin: const Offset(.95, .95)),

                    _HomeFeatureCard(
                          icon: Icons.work_outline_rounded,
                          title: 'فرص العمل',
                          subtitle: 'وظائف وتدريبات مناسبة',
                          isEnabled: true,
                          onTap: () => Get.toNamed(Routes.studentOpportunities),
                        )
                        .animate()
                        .fadeIn(delay: 320.ms, duration: 520.ms)
                        .slideY(begin: .25, curve: Curves.easeOutCubic)
                        .scale(begin: const Offset(.95, .95)),
                    _HomeFeatureCard(
                          icon: Icons.route_rounded,
                          title: 'خريطة التطوير',
                          subtitle: 'Roadmap وخطة ذكية',
                          isEnabled: true,
                          onTap: () => _showRoadmapSheet(context, controller),
                        )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 520.ms)
                        .slideY(begin: .25, curve: Curves.easeOutCubic)
                        .scale(begin: const Offset(.95, .95)),
                    _HomeFeatureCard(
                          icon: Icons.assignment_ind_rounded,
                          title: 'مهامي المسندة',
                          subtitle: 'مهام من المشرف',
                          isEnabled: true,
                          onTap: () => Get.toNamed(Routes.studentAssignedTasks),
                        )
                        .animate()
                        .fadeIn(delay: 560.ms, duration: 520.ms)
                        .slideY(begin: .25, curve: Curves.easeOutCubic)
                        .scale(begin: const Offset(.95, .95)),
                    _HomeFeatureCard(
                          icon: Icons.fact_check_rounded,
                          title: 'تقديماتي',
                          subtitle: 'حالة طلبات التقديم',
                          isEnabled: true,
                          onTap: () =>
                              Get.toNamed(Routes.studentTaskApplications),
                        )
                        .animate()
                        .fadeIn(delay: 480.ms, duration: 520.ms)
                        .slideY(begin: .25, curve: Curves.easeOutCubic)
                        .scale(begin: const Offset(.95, .95)),
                    _HomeFeatureCard(
                          icon: Icons.forum_rounded,
                          title: 'محادثاتي',
                          subtitle: 'تواصل مع الشركات',
                          isEnabled: true,
                          onTap: () => Get.toNamed(Routes.studentConversations),
                        )
                        .animate()
                        .fadeIn(delay: 560.ms, duration: 520.ms)
                        .slideY(begin: .25, curve: Curves.easeOutCubic)
                        .scale(begin: const Offset(.95, .95)),
                   _HomeFeatureCard(
                          icon: Icons.groups_rounded,
                          title: 'المجتمع التقني',
                          subtitle: 'أسئلة ونقاشات ومساعدة',
                          isEnabled: true,
                          onTap: () =>
                              Get.toNamed(Routes.studentCommunityPosts),
                        )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 520.ms)
                        .slideY(begin: .25, curve: Curves.easeOutCubic)
                        .scale(begin: const Offset(.95, .95)),

                    _HomeFeatureCard(
                          icon: Icons.school_rounded,
                          title: 'مساري التدريبي',
                          subtitle: 'قريباً',
                          isEnabled: false,
                          onTap: () {},
                        )
                        .animate()
                        .fadeIn(delay: 480.ms, duration: 520.ms)
                        .slideY(begin: .25, curve: Curves.easeOutCubic)
                        .scale(begin: const Offset(.95, .95)),
                  ],
                ),

                const SizedBox(height: 28),

                Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.person_outline,
                            title: 'ملفي الشخصي',
                            onTap: () => Get.toNamed(Routes.studentProfile),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.upload_file_outlined,
                            title: 'رفع CV',
                            onTap: () => Get.toNamed(Routes.cvUpload),
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(delay: 560.ms)
                    .slideY(begin: .22, curve: Curves.easeOutCubic),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _WelcomeCard({required this.title, required this.subtitle});

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
          colors: [AppColors.primaryBlue, Color(0xFF0077B6)],
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

class _HomeFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isEnabled;
  final VoidCallback onTap;

  const _HomeFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(28),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isEnabled
                ? AppColors.actionYellow.withOpacity(.34)
                : AppColors.primaryBlue.withOpacity(.08),
          ),
          boxShadow: [
            BoxShadow(
              color: isEnabled
                  ? AppColors.actionYellow.withOpacity(.12)
                  : AppColors.primaryBlue.withOpacity(.06),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: isEnabled
                    ? AppColors.actionYellow.withOpacity(.14)
                    : AppColors.primaryBlue.withOpacity(.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: isEnabled ? AppColors.actionYellow : AppColors.textGrey,
                size: 31,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: isEnabled ? AppColors.primaryBlue : AppColors.textGrey,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showRoadmapSheet(BuildContext context, HomeController controller) {
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LatestLearningPlanSheet(
        plan: plan,
        sessionId: controller.latestLearningPlanCache.value!.assessmentSessionId,
        careerPath: controller.latestLearningPlanCache.value!.careerPath,
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
                          setState(() => selectedWeeks = value);
                        },
                      ),
                      const SizedBox(height: 14),
                      _HomePlanStepper(
                        title: 'ساعات أسبوعياً',
                        value: selectedHours,
                        min: 1,
                        max: 40,
                        onChanged: (value) {
                          setState(() => selectedHours = value);
                        },
                      ),
                      const SizedBox(height: 22),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context, {
                            'weeks': selectedWeeks,
                            'hours_per_week': selectedHours,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        icon: const Icon(Icons.auto_awesome_rounded),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                          onPlay: (animationController) =>
                              animationController.repeat(reverse: true),
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
                          isLoading: controller.isGeneratingAiPlan.value,
                          onTap: controller.isGeneratingAiPlan.value
                              ? null
                              : () => _showPlanOptions(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(
                        () => _CuteHomeRoadmapButton(
                          text: controller.isLoadingLatestAiPlan.value
                              ? 'جاري الجلب...'
                              : 'آخر خطة',
                          icon: Icons.history_rounded,
                          color: AppColors.primaryBlue,
                          isLoading: controller.isLoadingLatestAiPlan.value,
                          onTap: controller.isLoadingLatestAiPlan.value
                              ? null
                              : () => _showPlan(
                                    context,
                                    controller.getLatestAiLearningPlan,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (controller.isLoadingLatestLearningPlan.value)
                  const Padding(
                    padding: EdgeInsets.only(top: 40, bottom: 40),
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
                  ...List.generate(roadmap.length, (index) {
                    return _HomeRoadmapItem(
                      item: roadmap[index],
                      index: index,
                      isLast: index == roadmap.length - 1,
                    )
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 80 * index),
                          duration: 420.ms,
                        )
                        .slideY(begin: .16);
                  }),
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
                    colors: [AppColors.actionYellow, Color(0xFFFFC94A)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.actionYellow.withOpacity(.30),
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
                        color: AppColors.primaryBlue.withOpacity(.06),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            icon: Icons.priority_high_rounded,
                            text: _priorityText(item.priority),
                            color: AppColors.actionYellow,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'من ${item.currentLevel.toStringAsFixed(1)} إلى ${item.targetLevel.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (item.resources.isEmpty)
                        const Text(
                          'لا توجد مصادر مقترحة حالياً.',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.textGrey,
                          ),
                        )
                      else
                        ...item.resources.map(
                          (resource) => _HomeResourceTile(resource: resource),
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

  const _HomeResourceTile({required this.resource});

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
                  resource.title.isEmpty ? 'مصدر تعليمي' : resource.title,
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
          border: Border.all(color: color.withOpacity(.22)),
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
              Icon(icon, color: color, size: 19),
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
            onTap: value <= min ? null : () => onChanged(value - 1),
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
            onTap: value >= max ? null : () => onChanged(value + 1),
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
          color: enabled ? AppColors.actionYellow : AppColors.textGrey,
          size: 21,
        ),
      ),
    );
  }
}

String _priorityText(String priority) {
  switch (priority) {
    case 'high':
      return 'عالية';
    case 'medium':
      return 'متوسطة';
    case 'low':
      return 'منخفضة';
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
            border: Border.all(color: AppColors.actionYellow.withOpacity(.22)),
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
                    colors: [AppColors.actionYellow, Color(0xFFFFC94A)],
                  ),
                  borderRadius: BorderRadius.circular(21),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.actionYellow.withOpacity(.22),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: controller.isLoadingLatestLearningPlan.value
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
                    onPlay: (animationController) =>
                        animationController.repeat(reverse: true),
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
                            (plan?.plan.careerPath ?? '').isNotEmpty)) ...[
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                    : (plan!.plan.summaryAr.isNotEmpty
                          ? plan!.plan.summaryAr
                          : plan!.summaryText),
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
                ...List.generate(plan!.plan.weeks.length, (index) {
                  final week = plan!.plan.weeks[index];

                  return _LearningPlanWeekCard(week: week, index: index)
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 80 * index))
                      .slideY(begin: .16);
                }),
                if (plan!.plan.finalOutcomeAr.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(.08),
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
            text: careerPath.isEmpty ? 'مسار غير محدد' : careerPath,
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
            (goal) => _PlanLine(icon: Icons.flag_rounded, text: goal),
          ),
          ...week.tasks.map(
            (task) => _PlanLine(
              icon: Icons.task_alt_rounded,
              text:
                  '${task.title} · ${task.estimatedHours.toStringAsFixed(0)} ساعة · ${task.skill}',
            ),
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
          Icon(icon, color: AppColors.actionYellow, size: 18),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(15),
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
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.08)),
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
            Icon(icon, color: AppColors.primaryBlue, size: 36),
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
