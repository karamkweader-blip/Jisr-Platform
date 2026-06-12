import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/company_home_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/company_home_model.dart';

class CompanyHomeView extends GetView<CompanyHomeController> {
  const CompanyHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const _HomeLoadingState();
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return _HomeErrorState(
              message: controller.errorMessage.value,
              onRetry: controller.fetchCompanyHome,
            );
          }

          final home = controller.homeData.value;

          if (home == null) {
            return const _HomeLoadingState();
          }

          return RefreshIndicator(
            onRefresh: controller.fetchCompanyHome,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                _HomeHeader(home: home),
                const SizedBox(height: 20),
                _StatsGrid(stats: home.stats),
                const SizedBox(height: 18),
                _CreateTaskCard(onPressed: controller.onCreateTaskPressed),
                if (home.requiredActions.isNotEmpty) ...[
                  const SizedBox(height: 26),
                  const _SectionHeader(
                    title: 'إجراءات مطلوبة',
                    subtitle: 'أشياء تحتاج مراجعتك الآن',
                  ),
                  const SizedBox(height: 12),
                  ...home.requiredActions.map(
                    (action) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RequiredActionCard(
                        action: action,
                        buttonLabel: controller.resolveActionButtonLabel(
                          targetType: action.targetType,
                          fallbackLabel: action.actionLabel,
                        ),
                        onPressed: () => controller.onRequiredActionPressed(action),
                      ),
                    ),
                  ),
                ],
                if (home.recentActivities.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const _SectionHeader(
                    title: 'آخر النشاطات',
                    subtitle: 'آخر ما حدث داخل حساب الشركة',
                  ),
                  const SizedBox(height: 12),
                  ...home.recentActivities.map(
                    (activity) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _RecentActivityCard(
                        activity: activity,
                        buttonLabel: controller.resolveActionButtonLabel(
                          targetType: activity.targetType,
                          fallbackLabel: activity.actionLabel,
                        ),
                        onPressed: () => controller.onRecentActivityPressed(activity),
                      ),
                    ),
                  ),
                ],
                if (!home.hasAnyActivity) ...[
                  const SizedBox(height: 24),
                  _EmptyHomeCard(onPressed: controller.onCreateTaskPressed),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final CompanyHomeModel home;

  const _HomeHeader({
    required this.home,
  });

  @override
  Widget build(BuildContext context) {
    final companyName = home.company.name.trim().isEmpty
        ? 'شركتك'
        : home.company.name.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مرحباً، $companyName',
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          home.hasAnyActivity
              ? 'إليك ملخص نشاط شركتك اليوم'
              : 'ابدأ بنشر أول مهمة لاستقبال الطلاب المناسبين',
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final CompanyHomeStats stats;

  const _StatsGrid({
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _StatCard(
          title: 'الفرص النشطة',
          value: stats.activeOpportunitiesCount,
          icon: Icons.work_outline_rounded,
        ),
        _StatCard(
          title: 'المتقدمون الجدد',
          value: stats.newApplicantsCount,
          icon: Icons.person_add_alt_1_rounded,
        ),
        _StatCard(
          title: 'بانتظار التقييم',
          value: stats.pendingReviewsCount,
          icon: Icons.rate_review_outlined,
        ),
        _StatCard(
          title: 'المهام الجارية',
          value: stats.activeAssignmentsCount,
          icon: Icons.play_circle_outline_rounded,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 19,
            ),
          ),
          const Spacer(),
          Text(
            value.toString(),
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateTaskCard extends StatelessWidget {
  final VoidCallback onPressed;

  const _CreateTaskCard({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ابدأ بمهمة جديدة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'انشر مهمة قصيرة ليستطيع الطلاب المناسبون التقديم عليها.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.primaryBlue,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RequiredActionCard extends StatelessWidget {
  final CompanyRequiredAction action;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _RequiredActionCard({
    required this.action,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.actionYellow.withOpacity(0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.actionYellow.withOpacity(0.08),
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
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: AppColors.actionYellow.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.priority_high_rounded,
                  color: AppColors.actionYellow,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  action.title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            action.description,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 42,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  final CompanyRecentActivity activity;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _RecentActivityCard({
    required this.activity,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryBlue.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.07),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primaryBlue,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    activity.description,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 12.8,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              buttonLabel,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHomeCard extends StatelessWidget {
  final VoidCallback onPressed;

  const _EmptyHomeCard({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.06),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.add_task_rounded,
              color: AppColors.primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'لا يوجد نشاط بعد',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ بنشر أول مهمة حتى يتمكن الطلاب المناسبون من التقديم عليها.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'إنشاء مهمة جديدة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeLoadingState extends StatelessWidget {
  const _HomeLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryBlue,
      ),
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HomeErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.primaryBlue,
                size: 36,
              ),
              const SizedBox(height: 12),
              const Text(
                'حدث خطأ',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}