import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/opportunities/student_opportunity_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/models/student/opportunities/student_opportunity_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class StudentOpportunitiesView extends StatefulWidget {
  const StudentOpportunitiesView({super.key});

  @override
  State<StudentOpportunitiesView> createState() =>
      _StudentOpportunitiesViewState();
}

class _StudentOpportunitiesViewState extends State<StudentOpportunitiesView> {
  final StudentOpportunityController controller =
      Get.find<StudentOpportunityController>();

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        controller.fetchInitialOpportunities();
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
            'فرص العمل',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: RefreshIndicator(
          color: AppColors.actionYellow,
          onRefresh: controller.refreshOpportunities,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _OpportunitiesHero()
                    .animate()
                    .fadeIn(duration: 480.ms)
                    .slideY(begin: .18, curve: Curves.easeOutBack),

                const SizedBox(height: 18),

                _OpportunityTabs(controller: controller)
                    .animate()
                    .fadeIn(delay: 90.ms, duration: 420.ms)
                    .slideY(begin: .16),

                const SizedBox(height: 18),

                SizedBox(
                  height: MediaQuery.of(context).size.height * .62,
                  child: TabBarView(
                    controller: controller.tabController,
                    physics: const BouncingScrollPhysics(),
                    children: const [
                      _RecommendedOpportunitiesTab(),
                      _ExploreOpportunitiesTab(),
                    ],
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

class _OpportunitiesHero extends StatelessWidget {
  const _OpportunitiesHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryBlue, Color(0xFF0077B6)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.18),
            blurRadius: 22,
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
              color: Colors.white.withOpacity(.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(.16)),
            ),
            child: const Icon(
              Icons.work_outline_rounded,
              color: AppColors.actionYellow,
              size: 30,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.06, 1.06),
                duration: 1700.ms,
              ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'فرص مناسبة لمسارك',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'فرص موصى بها حسب المهارات، وفرص للاستكشاف والتطور.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white70,
                    fontSize: 12,
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

class _OpportunityTabs extends StatelessWidget {
  final StudentOpportunityController controller;

  const _OpportunityTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
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
      child: TabBar(
        controller: controller.tabController,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.primaryBlue,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(19),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(text: 'موصى بها'),
          Tab(text: 'استكشاف'),
        ],
      ),
    );
  }
}

class _RecommendedOpportunitiesTab
    extends GetView<StudentOpportunityController> {
  const _RecommendedOpportunitiesTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingRecommended.value) {
        return const _TabLoading();
      }

      if (controller.recommendedOpportunities.isEmpty) {
        return const _EmptyOpportunities(
          title: 'لا توجد فرص موصى بها حالياً',
          subtitle: 'ستظهر الفرص الأقرب للمهارات بعد توفرها.',
        );
      }

      return ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: controller.recommendedOpportunities.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final opportunity = controller.recommendedOpportunities[index];

          return _OpportunityCard(
                opportunity: opportunity,
                highlighted: true,
                onTap: () => Get.toNamed(
                  Routes.studentOpportunityDetails,
                  arguments: opportunity.id,
                ),
              )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 70 * index),
                duration: 430.ms,
              )
              .slideY(begin: .20, curve: Curves.easeOutCubic);
        },
      );
    });
  }
}

class _ExploreOpportunitiesTab extends GetView<StudentOpportunityController> {
  const _ExploreOpportunitiesTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingExplore.value) {
        return const _TabLoading();
      }

      if (controller.exploreOpportunities.isEmpty) {
        return const _EmptyOpportunities(
          title: 'لا توجد فرص للاستكشاف حالياً',
          subtitle: 'عند توفر فرص جديدة ستظهر في هذا القسم.',
        );
      }

      return ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: controller.exploreOpportunities.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final opportunity = controller.exploreOpportunities[index];

          return _OpportunityCard(
                opportunity: opportunity,
                highlighted: false,
                onTap: () => Get.toNamed(
                  Routes.studentOpportunityDetails,
                  arguments: opportunity.id,
                ),
              )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 70 * index),
                duration: 430.ms,
              )
              .slideY(begin: .20, curve: Curves.easeOutCubic);
        },
      );
    });
  }
}

class _OpportunityCard extends GetView<StudentOpportunityController> {
  final StudentOpportunityModel opportunity;
  final bool highlighted;
  final VoidCallback onTap;

  const _OpportunityCard({
    required this.opportunity,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = highlighted ? AppColors.actionYellow : AppColors.primaryBlue;

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: accent.withOpacity(.18)),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(.09),
              blurRadius: 20,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(.10),
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Icon(
                    opportunity.type == 'job'
                        ? Icons.work_rounded
                        : Icons.school_rounded,
                    color: accent,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opportunity.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.primaryBlue,
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        controller.companyName(opportunity.company),
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
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textGrey,
                  size: 17,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _OpportunityBadge(
                  icon: Icons.auto_awesome_rounded,
                  text: '${opportunity.matchScore}% تطابق',
                  color: AppColors.actionYellow,
                ),
                _OpportunityBadge(
                  icon: Icons.category_rounded,
                  text: controller.opportunityTypeLabel(opportunity.type),
                  color: AppColors.primaryBlue,
                ),
                _OpportunityBadge(
                  icon: Icons.place_rounded,
                  text: opportunity.location.isEmpty
                      ? 'غير محدد'
                      : opportunity.location,
                  color: AppColors.primaryBlue,
                ),
                _OpportunityBadge(
                  icon: Icons.event_rounded,
                  text: controller.deadlineText(opportunity.deadline),
                  color: AppColors.actionYellow,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (opportunity.alreadyApplied)
              const _AppliedStrip()
            else
              Text(
                opportunity.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textDark,
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OpportunityBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _OpportunityBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
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

class _AppliedStrip extends StatelessWidget {
  const _AppliedStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
          SizedBox(width: 7),
          Text(
            'تم التقديم على هذه الفرصة',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabLoading extends StatelessWidget {
  const _TabLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.actionYellow),
    );
  }
}

class _EmptyOpportunities extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyOpportunities({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.work_off_rounded,
              color: AppColors.actionYellow,
              size: 58,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.primaryBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
