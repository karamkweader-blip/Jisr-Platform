import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/auth_actions_controller.dart';
import 'package:jisr_platform/controllers/student/home/home_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/jisr_app_menu.dart';
import 'package:jisr_platform/core/widgets/company/jisr_animated_logo.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
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
                          subtitle: 'قريباً',
                          isEnabled: false,
                          onTap: () {},
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
