import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/cv/student_cv_selection_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/models/student/cv/student_cv_history_models.dart';

class StudentCvSelectionView extends GetView<StudentCvSelectionController> {
  const StudentCvSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        bottomNavigationBar: const StudentBottomNav(currentIndex: 2),
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          iconTheme: const IconThemeData(color: AppColors.primaryBlue),
          title: const Text(
            'اختيار سي في',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.actionYellow),
            );
          }

          if (controller.errorMessage.value.isNotEmpty &&
              controller.cvs.isEmpty) {
            return _ErrorState(
              message: controller.errorMessage.value,
              onRetry: controller.loadCvs,
            );
          }

          return RefreshIndicator(
            color: AppColors.actionYellow,
            onRefresh: controller.loadCvs,
            child: controller.cvs.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                    itemCount: controller.cvs.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == 0) return const _HeaderCard();
                      final cv = controller.cvs[index - 1];
                      return _CvCard(
                        cv: cv,
                        onTap: () => controller.openCv(cv),
                      );
                    },
                  ),
          );
        }),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withOpacity(.11),
            AppColors.actionYellow.withOpacity(.10),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(.09)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.folder_copy_outlined,
            color: AppColors.primaryBlue,
            size: 34,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حدد السيرة الذاتية',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'يعرض كل عنصر بيانات آخر تحليل محفوظ له.',
                  style: TextStyle(
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
    );
  }
}

class _CvCard extends StatelessWidget {
  final StudentCvItem cv;
  final VoidCallback onTap;

  const _CvCard({required this.cv, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final latest = cv.latestAnalysis;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(.11),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(.09),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: AppColors.primaryBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cv.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _dateLabel(cv.uploadedAt),
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.textGrey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (cv.isPrimary) const _Badge(label: 'أساسية'),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _Badge(
                    label: cv.hasAnalysis ? 'التحليل جاهز' : 'لا يوجد تحليل',
                    color: cv.hasAnalysis
                        ? AppColors.successGreen
                        : AppColors.warningOrange,
                  ),
                  if (latest != null) ...[
                    const SizedBox(width: 8),
                    _Badge(
                      label: '${latest.skillsCount} مهارات',
                      color: AppColors.primaryBlue,
                    ),
                  ],
                  const Spacer(),
                  const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.actionYellow,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _dateLabel(DateTime? value) {
    if (value == null) return 'تاريخ الرفع غير متوفر';
    final date = value.toLocal();
    return 'رُفعت بتاريخ ${date.year}/${_two(date.month)}/${_two(date.day)}';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({
    required this.label,
    this.color = AppColors.actionYellow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(30),
      children: const [
        SizedBox(height: 150),
        Icon(Icons.folder_off_outlined, color: AppColors.textGrey, size: 58),
        SizedBox(height: 14),
        Text(
          'لا توجد سير ذاتية بعد',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: AppColors.textGrey, size: 54),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
