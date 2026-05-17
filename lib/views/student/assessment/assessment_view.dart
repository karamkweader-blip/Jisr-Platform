import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/assessment/assessment_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/jisr_primary_button.dart';

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
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
              child: Column(
                children: [
                  _HeaderCard(),
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
                  TextField(
                    controller: controller.answerController,
                    maxLines: 7,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    decoration: InputDecoration(
                      hintText: 'اكتبي إجابتك هون...',
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
                  const SizedBox(height: 16),
                  if (controller.lastResult.value != null)
                    _FeedbackCard(
                      score: controller.lastResult.value!.normalizedScore,
                      feedback: controller.lastResult.value!.feedback,
                    ),
                  const SizedBox(height: 22),
                  JisrPrimaryButton(
                    text: 'إرسال الإجابة',
                    icon: Icons.send_rounded,
                    isLoading: controller.isSubmitting.value,
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.submitAnswer,
                  ),
                ],
              ),
            );
          }

          if (controller.isStarting.value) {
            return const _LoadingCard(text: 'عم نجهز اختبارك...');
          }

          if (controller.isCompleting.value) {
            return const _LoadingCard(text: 'عم نجهز نتيجتك النهائية...');
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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: 0.95 + (value * 0.05), child: child),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.actionYellow.withOpacity(0.13),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.actionYellow.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'النتيجة: ${(score * 100).round()}%',
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.actionYellow,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              feedback,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textDark,
                height: 1.5,
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
        width: 230,
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

  String _valueOrDash(String? value) {
    if (value == null || value.trim().isEmpty || value == 'null') {
      return 'غير محدد';
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final result = controller.completedAssessment.value;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0, 1),
                child: Transform.scale(
                  scale: 0.88 + (value * 0.12),
                  child: child,
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
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
              child: const Column(
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.actionYellow,
                    size: 78,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'مبروك 🎉',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'أنهيت اختبار تحديد المستوى بنجاح',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          if (result == null)
            const Text(
              'تم إنهاء الجلسة بنجاح.',
              style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey),
            )
          else
            ...result.finalResults.map((skill) {
              final skillName =
                  controller.skillNames[skill.skillId] ??
                  'مهارة ${skill.skillId}';

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 450),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 22 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.actionYellow.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: AppColors.actionYellow,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              skillName,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                color: AppColors.primaryBlue,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'المستوى الأولي: ${_valueOrDash(skill.initialLevel)}',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                color: AppColors.textGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'المستوى النهائي: ${_valueOrDash(skill.finalLevel)}',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'نسبة الثقة: ${_valueOrDash(skill.confidenceScore)}',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
