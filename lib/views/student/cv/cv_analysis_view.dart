import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/cv/cv/cv_analysis_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/jisr_bottom_nav.dart';

class CvAnalysisView extends GetView<CvAnalysisController> {
  const CvAnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: const JisrBottomNav(
          activeTab: JisrBottomNavTab.cv,
        ),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          centerTitle: true,
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
            return const _AnalysisLoading();
          }

          final analysis = controller.analysis.value;

          if (analysis == null) {
            return const Center(
              child: Text(
                'لم يتم العثور على نتيجة التحليل',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textGrey,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 26),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34),
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [AppColors.primaryBlue, Color(0xFF0077B6)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.6, end: 1),
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(scale: value, child: child);
                        },
                        child: Container(
                          height: 92,
                          width: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.auto_graph_rounded,
                            color: AppColors.actionYellow,
                            size: 50,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'تحليل ذكي لمهاراتك',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        'رقم التحليل: ${analysis.analysisId}  •  رقم الملف: ${analysis.cvId}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.actionYellow.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${analysis.skills.length} مهارات',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.actionYellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: analysis.skills.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final skill = analysis.skills[index];

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 450 + (index * 120)),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value.clamp(0, 1),
                          child: Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: _SkillCard(skill: skill),
                    );
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _AnalysisLoading extends StatelessWidget {
  const _AnalysisLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.12),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        onEnd: () {},
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.10),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.actionYellow),
              SizedBox(height: 18),
              Text(
                'عم نحلل الـ CV...',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'استني لحظات',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final dynamic skill;

  const _SkillCard({required this.skill});

  @override
  Widget build(BuildContext context) {
    final levelPercent = (skill.initialLevel / 5).clamp(0.0, 1.0);
    final confidencePercent = skill.confidence.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.primaryBlue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  skill.skillName,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.actionYellow.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '${(skill.confidence * 100).round()}%',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.actionYellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            skill.evidence,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textGrey,
              fontSize: 13,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 16),

          _AnimatedBar(
            title: 'المستوى الأولي',
            value: levelPercent,
            label: '${skill.initialLevel}/5',
            color: AppColors.primaryBlue,
          ),

          const SizedBox(height: 12),

          _AnimatedBar(
            title: 'الثقة بالتحليل',
            value: confidencePercent,
            label: '${(skill.confidence * 100).round()}%',
            color: AppColors.actionYellow,
          ),
        ],
      ),
    );
  }
}

class _AnimatedBar extends StatelessWidget {
  final String title;
  final double value;
  final String label;
  final Color color;

  const _AnimatedBar({
    required this.title,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 9,
            color: color.withOpacity(0.12),
            alignment: Alignment.centerRight,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, _) {
                return FractionallySizedBox(
                  widthFactor: animatedValue,
                  alignment: Alignment.centerRight,
                  child: Container(color: color),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
