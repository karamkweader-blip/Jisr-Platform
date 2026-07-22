import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/assessment/assessment_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/jisr_primary_button.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jisr_platform/models/student/assessment/assessment_models.dart';
import 'package:url_launcher/url_launcher.dart';

class AssessmentView extends GetView<AssessmentController> {
  const AssessmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,

      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.primaryBlue),
          title: const Text(
            'اختبار تحديد المستوى',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Obx(() {
          final question = controller.currentQuestion.value;

          if (question != null) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
              child: Column(
                children: [
                  _HeaderCard()
                      .animate()
                      .fadeIn(duration: 450.ms)
                      .slideY(begin: .18, curve: Curves.easeOutBack),
                  const SizedBox(height: 22),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 550),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value.clamp(0, 1),
                        child: Transform.translate(
                          offset: Offset(0, 35 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: _QuestionCard(questionText: question.questionText),
                  ),
                  const SizedBox(height: 18),
                  if (controller.lastResult.value != null) ...[
                    _FeedbackCard(
                      score: controller.lastResult.value!.normalizedScore,
                      feedback: controller.lastResult.value!.feedback,
                    ),
                    const SizedBox(height: 18),
                  ],
                  TextField(
                    controller: controller.answerController,
                    maxLines: 7,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    decoration: InputDecoration(
                      hintText: 'اكتب الإجابة هنا...',
                      hintStyle: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textGrey,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(26),
                        borderSide: BorderSide(
                          color: AppColors.primaryBlue.withOpacity(0.10),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(26),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  JisrPrimaryButton(
                    text: controller.lastResult.value != null
                        ? 'بانتظار السؤال التالي...'
                        : 'إرسال الإجابة',
                    icon: Icons.send_rounded,
                    isLoading: controller.isSubmitting.value,
                    onPressed:
                        controller.isSubmitting.value ||
                            controller.lastResult.value != null
                        ? null
                        : controller.submitAnswer,
                  ),
                ],
              ),
            );
          }

          if (controller.isStarting.value) {
            return const _LoadingCard(text: 'عم نجهز الاختبار...');
          }

          if (controller.isCompleting.value) {
            return const _LoadingCard(text: 'عم نجهز النتيجة النهائية...');
          }

          if (controller.isCompleted.value) {
            return const _CompletedCard();
          }

          if (controller.isLoadingQuestion.value) {
            return const _LoadingCard(text: 'عم نجيب السؤال...');
          }

          return const Center(
            child: Text(
              'لا يوجد سؤال حالياً',
              style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey),
            ),
          );
        }),
      ),
    );
  }
}

class _HeaderCard extends GetView<AssessmentController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryBlue, Color(0xFF0077B6)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
                Icons.psychology_alt_rounded,
                color: AppColors.actionYellow,
                size: 54,
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.06, 1.06),
                duration: 1700.ms,
              ),
          const SizedBox(height: 12),
          Text(
            controller.currentSkillName,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'المهارة ${controller.currentSkillIndex + 1} من ${controller.skillIds.length}',
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: controller.progress,
              minHeight: 9,
              backgroundColor: Colors.white.withOpacity(0.18),
              color: AppColors.actionYellow,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String questionText;

  const _QuestionCard({required this.questionText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.quiz_rounded, color: AppColors.primaryBlue),
              SizedBox(width: 8),
              Text(
                'السؤال',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.primaryBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            questionText,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textDark,
              fontSize: 16,
              height: 1.7,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final double score;
  final String feedback;

  const _FeedbackCard({required this.score, required this.feedback});

  @override
  Widget build(BuildContext context) {
    final percent = (score * 100).round();
    final isGood = percent >= 60;
    final color = isGood ? Colors.green : AppColors.actionYellow;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, 22 * (1 - value)),
            child: Transform.scale(scale: .96 + (value * .04), child: child),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(.12),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: color.withOpacity(.38)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(.07),
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
                Icon(
                  isGood ? Icons.check_circle_rounded : Icons.info_rounded,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'النتيجة: $percent%',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              feedback.isEmpty ? 'تم تقييم الإجابة.' : feedback,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textDark,
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'سيتم الانتقال للسؤال التالي بعد 1 ثانية.',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final String text;

  const _LoadingCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.10),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.actionYellow),
            const SizedBox(height: 18),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedCard extends GetView<AssessmentController> {
  const _CompletedCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingReport.value) {
        return const _LoadingCard(text: 'عم نجهز تقرير المستوى...');
      }

      final summary = controller.assessmentSummary.value;
      final gaps = controller.skillGaps;
      final path = controller.learningPath;
      final skills = summary?.skills ?? <AssessmentSummarySkill>[];

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ReportHero(summary: summary)
                .animate()
                .fadeIn(duration: 550.ms)
                .scale(
                  begin: const Offset(.92, .92),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutBack,
                ),

            const SizedBox(height: 22),

            _ReportTitle(
              icon: Icons.analytics_rounded,
              title: 'نتيجة المهارات',
            ).animate().fadeIn(delay: 120.ms).slideX(begin: .12),

            const SizedBox(height: 12),

            if (skills.isEmpty)
              const _EmptyReportBox(
                text: 'لا توجد نتائج مهارات متاحة حالياً.',
              ).animate().fadeIn(delay: 180.ms).slideY(begin: .18)
            else
              ...List.generate(skills.length, (index) {
                return _SkillResultTile(skill: skills[index], index: index);
              }),

            const SizedBox(height: 16),

            _ReportTitle(
              icon: Icons.trending_up_rounded,
              title: 'فجوة المهارات مع السوق',
            ).animate().fadeIn(delay: 240.ms).slideX(begin: .12),

            const SizedBox(height: 12),

            if (gaps.isEmpty)
              const _EmptyReportBox(
                text: 'لا توجد فجوات مهارية متاحة حالياً.',
              ).animate().fadeIn(delay: 300.ms).slideY(begin: .18)
            else
              ...List.generate(gaps.length, (index) {
                return _GapTile(gap: gaps[index], index: index);
              }),

            const SizedBox(height: 16),

            _RoadmapSection(path: path),
          ],
        ),
      );
    });
  }
}

class _ReportHero extends StatelessWidget {
  final AssessmentSummaryData? summary;

  const _ReportHero({required this.summary});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.scale(scale: .86 + (value * .14), child: child),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.primaryBlue, Color(0xFF0077B6)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(.24),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: .9, end: 1.08),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.actionYellow,
                size: 66,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'تقرير تحديد المستوى',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              summary?.careerPath == null || summary!.careerPath.isEmpty
                  ? 'نتيجة المهارات، الفجوات، وخطة تطوير واضحة للخطوة التالية.'
                  : 'المسار: ${summary!.careerPath}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedReportSection extends StatelessWidget {
  final int delay;
  final IconData icon;
  final String title;
  final String emptyText;
  final Widget child;

  const _AnimatedReportSection({
    required this.delay,
    required this.icon,
    required this.title,
    required this.emptyText,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 650 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, 28 * (1 - value)),
            child: Transform.scale(
              scale: .96 + (value * .04),
              child: animatedChild,
            ),
          ),
        );
      },
      child: _ReportSection(
        icon: icon,
        title: title,
        emptyText: emptyText,
        child: child,
      ),
    );
  }
}

class _ReportSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String emptyText;
  final Widget child;

  const _ReportSection({
    required this.icon,
    required this.title,
    required this.emptyText,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = child is Column && (child as Column).children.isEmpty;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.08),
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
              Icon(icon, color: AppColors.actionYellow),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isEmpty)
            Text(
              emptyText,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
              ),
            )
          else
            child,
        ],
      ),
    );
  }
}

class _SkillResultTile extends StatelessWidget {
  final AssessmentSummarySkill skill;
  final int index;

  const _SkillResultTile({required this.skill, required this.index});

  @override
  Widget build(BuildContext context) {
    final level = skill.finalLevel ?? skill.currentLevel;
    final progressValue = (level / 5).clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 520 + (index * 90)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(26 * (1 - value), 0),
            child: Transform.scale(scale: .94 + (value * .06), child: child),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    skill.skillName,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _MiniBadge(text: skill.status),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progressValue),
                duration: Duration(milliseconds: 900 + (index * 120)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: AppColors.primaryBlue.withOpacity(.10),
                    color: AppColors.actionYellow,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'المستوى النهائي: ${level.toStringAsFixed(1)} / 5 · الأسئلة: ${skill.questionCount}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'المستوى الأولي: ${skill.initialLevel.toStringAsFixed(1)}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GapTile extends StatelessWidget {
  final AssessmentSkillGap gap;
  final int index;

  const _GapTile({required this.gap, required this.index});

  @override
  Widget build(BuildContext context) {
    final isOk = gap.gap <= 0;
    final color = isOk ? Colors.green : AppColors.actionYellow;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + (index * 90)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(-28 * (1 - value), 0),
            child: Transform.scale(scale: .94 + (value * .06), child: child),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(.10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isOk ? Icons.check_circle_rounded : Icons.priority_high_rounded,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOk
                        ? '${gap.skillName}: المستوى كافٍ للسوق'
                        : '${gap.skillName}: الفجوة ${gap.gap.toStringAsFixed(1)} مستوى',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'المطلوب: ${gap.requiredLevel.toStringAsFixed(1)} · الحالي: ${gap.actualLevel.toStringAsFixed(1)} · الاعتمادية: ${gap.reliability}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textGrey,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningPathTile extends StatelessWidget {
  final AssessmentLearningPathItem item;
  final int index;
  final bool isLast;

  const _LearningPathTile({
    required this.item,
    required this.index,
    required this.isLast,
  });

  Future<void> _openResource(AssessmentLearningResource resource) async {
    final rawUrl = resource.url.trim();

    final hasScheme =
        rawUrl.startsWith('http://') || rawUrl.startsWith('https://');

    final isRealUrl = hasScheme && !rawUrl.contains('...');

    late final Uri uri;

    if (isRealUrl) {
      uri = Uri.parse(rawUrl);
    } else {
      final provider = resource.provider.toLowerCase();
      final query = Uri.encodeComponent(
        '${resource.title} ${resource.provider}',
      );

      if (provider.contains('youtube')) {
        uri = Uri.parse('https://www.youtube.com/results?search_query=$query');
      } else if (provider.contains('coursera')) {
        uri = Uri.parse('https://www.coursera.org/search?query=$query');
      } else {
        uri = Uri.parse('https://www.google.com/search?q=$query');
      }
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 700 + (index * 130)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, 42 * (1 - value)),
            child: Transform.scale(scale: .86 + (value * .14), child: child),
          ),
        );
      },
      child: Stack(
        children: [
          PositionedDirectional(
            start: 23,
            top: 54,
            bottom: isLast ? 24 : 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.actionYellow.withOpacity(.80),
                    AppColors.primaryBlue.withOpacity(.18),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RoadMapNode(index: index),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Colors.white, Color(0xFFF6FAFF)],
                      ),
                      border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(.07),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(.08),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _PriorityBadge(priority: item.priority),
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
                        const SizedBox(height: 14),
                        if (item.resources.isEmpty)
                          const _EmptyRoadmapResource()
                        else
                          ...item.resources.map((resource) {
                            return _ResourceButton(
                              resource: resource,
                              onTap: () => _openResource(resource),
                            );
                          }),
                      ],
                    ),
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

class _RoadMapNode extends StatelessWidget {
  final int index;

  const _RoadMapNode({required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .82, end: 1.08),
      duration: const Duration(milliseconds: 950),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.actionYellow, Color(0xFFFFC94A)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.actionYellow.withOpacity(.38),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final text = priority == 'high'
        ? 'أولوية عالية'
        : priority == 'medium'
        ? 'أولوية متوسطة'
        : priority == 'low'
        ? 'أولوية منخفضة'
        : 'تطوير';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.actionYellow.withOpacity(.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.actionYellow,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ResourceButton extends StatelessWidget {
  final AssessmentLearningResource resource;
  final VoidCallback onTap;

  const _ResourceButton({required this.resource, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .96, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.actionYellow.withOpacity(.20)),
            boxShadow: [
              BoxShadow(
                color: AppColors.actionYellow.withOpacity(.07),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.actionYellow.withOpacity(.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.actionYellow,
                  size: 26,
                ),
              ),
              const SizedBox(width: 11),
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
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${resource.provider.isEmpty ? 'مصدر' : resource.provider} · ${resource.estimatedHours.isEmpty ? 'غير محدد' : resource.estimatedHours} ساعة',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.open_in_new_rounded,
                color: AppColors.primaryBlue,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRoadmapResource extends StatelessWidget {
  const _EmptyRoadmapResource();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        'لا توجد مصادر مقترحة حالياً.',
        style: TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.textGrey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String text;

  const _MiniBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    final shownText = text.isEmpty ? 'غير محدد' : text;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.actionYellow.withOpacity(.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        shownText,
        style: const TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.actionYellow,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ReportTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ReportTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.actionYellow),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyReportBox extends StatelessWidget {
  final String text;

  const _EmptyReportBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey),
      ),
    );
  }
}

class _RoadmapSection extends GetView<AssessmentController> {
  final List<AssessmentLearningPathItem> path;

  const _RoadmapSection({required this.path});

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
      builder: (_) => _AiPlanSheet(plan: plan),
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
              return Container(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                      'جهز خطة التعلم الذكية',
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
                    _PlanStepper(
                      title: 'عدد الأسابيع',
                      value: selectedWeeks,
                      min: 1,
                      max: 12,
                      onChanged: (value) {
                        setState(() => selectedWeeks = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    _PlanStepper(
                      title: 'ساعات أسبوعياً',
                      value: selectedHours,
                      min: 1,
                      max: 40,
                      onChanged: (value) {
                        setState(() => selectedHours = value);
                      },
                    ),
                    const SizedBox(height: 22),
                    JisrPrimaryButton(
                      text: 'إنشاء الخطة',
                      icon: Icons.auto_awesome_rounded,
                      onPressed: () {
                        Navigator.pop(context, {
                          'weeks': selectedWeeks,
                          'hours_per_week': selectedHours,
                        });
                      },
                    ),
                  ],
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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.07),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.route_rounded, color: AppColors.actionYellow),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'خريطة التطوير ومصادر التعلم',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _CuteRoadmapButton(
                    text: controller.isGeneratingAiPlan.value
                        ? 'جاري التجهيز...'
                        : 'خطتي الذكية',
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
                  () => _CuteRoadmapButton(
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
          if (path.isEmpty)
            const _EmptyReportBox(text: 'لا توجد مصادر مقترحة حالياً.')
          else
            ...List.generate(path.length, (index) {
              return _LearningPathTile(
                item: path[index],
                index: index,
                isLast: index == path.length - 1,
              );
            }),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms).slideY(begin: .18);
  }
}

class _PlanStepper extends StatelessWidget {
  final String title;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _PlanStepper({
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
          _SmallRoundButton(
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
          _SmallRoundButton(
            icon: Icons.add_rounded,
            onTap: value >= max ? null : () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _SmallRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _SmallRoundButton({required this.icon, required this.onTap});

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

class _CuteRoadmapButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback? onTap;

  const _CuteRoadmapButton({
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
        duration: const Duration(milliseconds: 250),
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
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            else
              Icon(icon, color: color, size: 19),
            const SizedBox(width: 7),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiPlanSheet extends StatelessWidget {
  final AssessmentAiLearningPlan plan;

  const _AiPlanSheet({required this.plan});

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
                'خطة التعلم الذكية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.primaryBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                plan.plan.summaryAr.isEmpty
                    ? plan.summaryText
                    : plan.plan.summaryAr,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textDark,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),

              ...List.generate(plan.plan.weeks.length, (index) {
                final week = plan.plan.weeks[index];

                return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 14),
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
                            'الأسبوع ${week.weekNumber}',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              color: AppColors.actionYellow,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          if (week.focusSkills.isNotEmpty)
                            Text(
                              'المهارات: ${week.focusSkills.join('، ')}',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          const SizedBox(height: 10),

                          ...week.goals.map(
                            (goal) => _AiPlanLine(
                              icon: Icons.flag_rounded,
                              text: goal,
                            ),
                          ),

                          ...week.tasks.map(
                            (task) => _AiPlanLine(
                              icon: Icons.task_alt_rounded,
                              text:
                                  '${task.title} · ${task.estimatedHours.toStringAsFixed(0)} ساعة · ${task.skill}',
                            ),
                          ),

                          if (week.expectedOutcome.isNotEmpty)
                            _AiPlanLine(
                              icon: Icons.workspace_premium_rounded,
                              text: week.expectedOutcome,
                            ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 100 * index))
                    .slideY(begin: .18);
              }),

              if (plan.plan.finalOutcomeAr.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(.08),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    plan.plan.finalOutcomeAr,
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
          ),
        ),
      ),
    );
  }
}

class _AiPlanLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AiPlanLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
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
