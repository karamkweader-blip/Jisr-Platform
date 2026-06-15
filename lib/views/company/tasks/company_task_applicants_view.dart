import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/tasks/company_task_applicants_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/views/company/tasks/widgets/task_applicant_card.dart';

class CompanyTaskApplicantsView extends GetView<CompanyTaskApplicantsController> {
  const CompanyTaskApplicantsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Obx(
            () => RefreshIndicator(
              color: AppColors.primaryBlue,
              onRefresh: controller.refreshApplications,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                      child: _ApplicantsTopBar(
                        title: controller.taskTitle,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                      child: _ApplicantsHeader(
                        count: controller.applications.length,
                      ),
                    ),
                  ),
                  if (controller.isLoading.value)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _ApplicantsLoading(),
                    )
                  else if (controller.errorMessage.value.isNotEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _ApplicantsError(
                        message: controller.errorMessage.value,
                        onRetry: controller.fetchApplications,
                      ),
                    )
                  else if (controller.applications.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _ApplicantsEmpty(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final application =
                                controller.applications[index];

                            return TaskApplicantCard(
                              application: application,
                              statusLabel:
                                  controller.applicationStatusLabel(
                                application.status,
                              ),
                              appliedAt: controller.formatAppliedAt(
                                application.appliedAt,
                              ),
                              onDetailsPressed: () =>
                                  controller.goToApplicantDetails(
                                application,
                              ),
                            );
                          },
                          childCount: controller.applications.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplicantsTopBar extends StatelessWidget {
  final String title;

  const _ApplicantsTopBar({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: Get.back,
            borderRadius: BorderRadius.circular(16),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'المتقدمون',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ApplicantsHeader extends StatelessWidget {
  final int count;

  const _ApplicantsHeader({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.cardWhite.withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.groups_2_outlined,
              color: AppColors.cardWhite,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'راجع الطلاب المتقدمين',
                  style: TextStyle(
                    color: AppColors.cardWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  count == 0
                      ? 'سيتم عرض المتقدمين حسب نسبة التطابق.'
                      : 'عدد المتقدمين الحالي: $count',
                  style: TextStyle(
                    color: AppColors.cardWhite.withOpacity(0.86),
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
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

class _ApplicantsLoading extends StatelessWidget {
  const _ApplicantsLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryBlue,
      ),
    );
  }
}

class _ApplicantsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ApplicantsError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.actionYellow,
                size: 42,
              ),
              const SizedBox(height: 12),
              const Text(
                'تعذر تحميل المتقدمين',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplicantsEmpty extends StatelessWidget {
  const _ApplicantsEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_search_outlined,
                color: AppColors.primaryBlue,
                size: 46,
              ),
              SizedBox(height: 12),
              Text(
                'لا يوجد متقدمون بعد',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'عند تقديم الطلاب على هذه المهمة سيظهرون هنا للمراجعة.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}