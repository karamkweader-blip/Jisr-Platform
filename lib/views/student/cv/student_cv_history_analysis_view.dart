import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/cv/student_cv_history_analysis_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/jisr_primary_button.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/models/student/cv/student_cv_history_models.dart';

class StudentCvHistoryAnalysisView
    extends GetView<StudentCvHistoryAnalysisController> {
  const StudentCvHistoryAnalysisView({super.key});

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
            'تحليل السيرة الذاتية',
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

          final details = controller.details.value;
          if (details == null) {
            return _AnalysisError(
              message: controller.errorMessage.value.isEmpty
                  ? 'لم يتم العثور على نتيجة التحليل'
                  : controller.errorMessage.value,
              onRetry: controller.loadAnalysis,
            );
          }

          final analysis = details.analysis;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AnalysisHeader(details: details),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'المهارات المستخرجة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.primaryBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _CountBadge(count: analysis.skills.length),
                  ],
                ),
                const SizedBox(height: 14),
                if (analysis.skills.isEmpty)
                  const _NoSkills()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: analysis.skills.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) => _SkillCard(
                      skill: analysis.skills[index],
                    ),
                  ),
                const SizedBox(height: 24),
                JisrPrimaryButton(
                  text: 'بدء اختبار تحديد المستوى',
                  icon: Icons.play_arrow_rounded,
                  onPressed: controller.startAssessment,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _AnalysisHeader extends StatelessWidget {
  final StudentCvAnalysisDetailsResponse details;

  const _AnalysisHeader({required this.details});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, Color(0xFF0077B6)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.auto_graph_rounded,
            color: AppColors.actionYellow,
            size: 54,
          ),
          const SizedBox(height: 12),
          Text(
            details.cv.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'رقم التحليل: ${details.analysis.analysisId}  •  رقم الملف: ${details.analysis.cvId}',
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.actionYellow.withOpacity(.13),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '$count مهارات',
        style: const TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.actionYellow,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final StudentCvAnalysisSkill skill;

  const _SkillCard({required this.skill});

  @override
  Widget build(BuildContext context) {
    final level = skill.initialLevel;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(.09)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: AppColors.primaryBlue, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  skill.displayName,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryBlue,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (skill.evidence != null) ...[
            const SizedBox(height: 12),
            Text(
              skill.evidence!,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
          if (level != null) ...[
            const SizedBox(height: 14),
            Text(
              'المستوى الأولي: ${_levelText(level)} / 5',
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _levelText(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}

class _NoSkills extends StatelessWidget {
  const _NoSkills();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 34),
      child: Text(
        'لا توجد مهارات ضمن هذا التحليل.',
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey),
      ),
    );
  }
}

class _AnalysisError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _AnalysisError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.textGrey, size: 54),
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
