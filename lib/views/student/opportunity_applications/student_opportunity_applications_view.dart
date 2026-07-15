import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/opportunity_applications/student_opportunity_application_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/models/student/opportunity_applications/student_opportunity_application_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class StudentOpportunityApplicationsView
    extends GetView<StudentOpportunityApplicationController> {
  const StudentOpportunityApplicationsView({super.key});

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
            'تقديمات فرص العمل',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Obx(
              () => IconButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.fetchApplications,
                icon: controller.isLoading.value
                    ? const SizedBox(
                        width: 21,
                        height: 21,
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
          onRefresh: controller.refreshApplications,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _OpportunityApplicationsHero()
                    .animate()
                    .fadeIn(duration: 480.ms)
                    .slideY(begin: .18, curve: Curves.easeOutBack),
                const SizedBox(height: 20),
                Obx(
                  () => Text(
                    controller.currentFilterTitle,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 70),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.actionYellow,
                        ),
                      ),
                    );
                  }

                  final applications = controller.filteredApplications;

                  if (applications.isEmpty) {
                    return const _EmptyOpportunityApplications();
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: applications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return _OpportunityApplicationCard(
                        item: applications[index],
                      )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 70 * index),
                            duration: 420.ms,
                          )
                          .slideY(begin: .18, curve: Curves.easeOutCubic);
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

class _OpportunityApplicationsHero
    extends GetView<StudentOpportunityApplicationController> {
  const _OpportunityApplicationsHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(31),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryBlue, Color(0xFF0077B6)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.20),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.work_history_rounded,
            color: AppColors.actionYellow,
            size: 52,
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.06, 1.06),
                duration: 1700.ms,
              ),
          const SizedBox(height: 12),
          const Text(
            'طلبات فرص العمل',
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
            'تابع حالة كل فرصة تم التقديم عليها، واسحب الطلب عند الحاجة.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Obx(
            () => GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.25,
              mainAxisSpacing: 9,
              crossAxisSpacing: 9,
              children: [
                _FilterStatCard(
                  title: 'الكل',
                  count: controller.applications.length,
                  filter: OpportunityApplicationFilter.all,
                  active: controller.selectedFilter.value ==
                      OpportunityApplicationFilter.all,
                ),
                _FilterStatCard(
                  title: 'مراجعة',
                  count: controller.pendingCount,
                  filter: OpportunityApplicationFilter.pending,
                  active: controller.selectedFilter.value ==
                      OpportunityApplicationFilter.pending,
                ),
                _FilterStatCard(
                  title: 'مسحوبة',
                  count: controller.withdrawnCount,
                  filter: OpportunityApplicationFilter.withdrawn,
                  active: controller.selectedFilter.value ==
                      OpportunityApplicationFilter.withdrawn,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterStatCard extends GetView<StudentOpportunityApplicationController> {
  final String title;
  final int count;
  final OpportunityApplicationFilter filter;
  final bool active;

  const _FilterStatCard({
    required this.title,
    required this.count,
    required this.filter,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(19),
      onTap: () => controller.selectFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              active ? AppColors.actionYellow : Colors.white.withOpacity(.12),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: active
                ? AppColors.actionYellow
                : Colors.white.withOpacity(.22),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: active ? Colors.black87 : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: active ? Colors.black87 : Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpportunityApplicationCard
    extends GetView<StudentOpportunityApplicationController> {
  final StudentOpportunityApplicationModel item;

  const _OpportunityApplicationCard({required this.item});

  Color get statusColor {
    switch (item.status) {
      case 'pending':
        return AppColors.actionYellow;
      case 'withdrawn':
        return Colors.redAccent;
      case 'accepted':
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
      case 'withdrawn':
        return Icons.undo_rounded;
      case 'accepted':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final opportunity = item.opportunity;

    return InkWell(
      borderRadius: BorderRadius.circular(29),
      onTap: () => Get.toNamed(
        Routes.studentOpportunityApplicationDetails,
        arguments: item.id,
      ),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(29),
          border: Border.all(color: statusColor.withOpacity(.14)),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(.07),
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
                const SizedBox(width: 13),
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.companyName(opportunity.company),
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
            const SizedBox(height: 13),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ApplicationChip(
                  icon: Icons.flag_rounded,
                  text: controller.statusText(item.status),
                  color: statusColor,
                ),
                _ApplicationChip(
                  icon: Icons.category_rounded,
                  text: controller.opportunityTypeLabel(opportunity.type),
                  color: AppColors.primaryBlue,
                ),
                _ApplicationChip(
                  icon: Icons.star_rounded,
                  text: 'تطابق ${item.matchScore.isEmpty ? 'غير محدد' : item.matchScore}',
                  color: AppColors.actionYellow,
                ),
                _ApplicationChip(
                  icon: Icons.event_rounded,
                  text: controller.dateOnly(opportunity.deadline),
                  color: AppColors.textGrey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _ApplicationChip({
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
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(13),
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

class _EmptyOpportunityApplications extends StatelessWidget {
  const _EmptyOpportunityApplications();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 38),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.work_off_rounded,
            color: AppColors.actionYellow,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'لا توجد طلبات في هذا القسم حالياً',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
