import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/home/company_home_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

// استيراد المكونات الفرعية المحلية من المجلد المجاور مباشرة
import 'widgets/home_header.dart';
import 'widgets/stats_grid.dart';
import 'widgets/create_task_card.dart';
import 'widgets/empty_home_card.dart';
import 'widgets/company_action_cards.dart';

class CompanyHomeView extends GetView<CompanyHomeController> {
  const CompanyHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: RefreshIndicator(
                onRefresh: controller.fetchCompanyHome,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(controller.errorMessage.value, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.fetchCompanyHome,
                        child: const Text('إعادة المحاولة'),
                      )
                    ],
                  ),
                ),
              ),
            );
          }

          final home = controller.homeData.value;
          if (home == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

    
          return RefreshIndicator(
            onRefresh: controller.fetchCompanyHome,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                HomeHeader(home: home),
                const SizedBox(height: 20),
                StatsGrid(stats: home.stats),
                const SizedBox(height: 18),
                CreateTaskCard(onPressed: controller.onCreateTaskPressed),
                
                // عرض كروت الإجراءات المطلوبة إن وُجدت
                if (home.requiredActions.isNotEmpty) ...[
                  const SizedBox(height: 26),
                  const SectionHeader(
                    title: 'إجراءات مطلوبة',
                    subtitle: 'أشياء تحتاج مراجعتك الآن',
                  ),
                  const SizedBox(height: 12),
                  ...home.requiredActions.map(
                    (action) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RequiredActionCard(
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
                
                // عرض كروت آخر النشاطات التاريخية إن وُجدت
                if (home.recentActivities.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const SectionHeader(
                    title: 'آخر النشاطات',
                    subtitle: 'آخر ما حدث داخل حساب الشركة',
                  ),
                  const SizedBox(height: 12),
                  ...home.recentActivities.map(
                    (activity) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: RecentActivityCard(
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
                
                // حالة الحساب الجديد 
                if (!home.hasAnyActivity) ...[
                  const SizedBox(height: 24),
                  EmptyHomeCard(onPressed: controller.onCreateTaskPressed),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}