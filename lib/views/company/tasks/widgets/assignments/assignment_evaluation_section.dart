
import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_submission_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_submission_review_model.dart';

class AssignmentEvaluationSection extends StatelessWidget {
  final CompanyTaskAssignmentSubmissionModel? submission;
  final CompanyTaskSubmissionReviewModel? review;

  final bool isSubmissionLoading;
  final bool isReviewLoading;
  final bool isSubmittingReview;

  final String submissionErrorMessage;
  final String reviewErrorMessage;

  final GlobalKey<FormState> formKey;
  final TextEditingController qualityScoreController;
  final TextEditingController commitmentScoreController;
  final TextEditingController communicationScoreController;
  final TextEditingController feedbackController;

  final String selectedFinalDecision;

  final String? Function(String?) scoreValidator;
  final String? Function(String?) feedbackValidator;

  final ValueChanged<String> onDecisionChanged;
  final VoidCallback onSubmit;
  final VoidCallback onRetry;

  final String Function(String) decisionLabel;
  final String Function(DateTime?) formatDateTime;

  const AssignmentEvaluationSection({
    super.key,
    required this.submission,
    required this.review,
    required this.isSubmissionLoading,
    required this.isReviewLoading,
    required this.isSubmittingReview,
    required this.submissionErrorMessage,
    required this.reviewErrorMessage,
    required this.formKey,
    required this.qualityScoreController,
    required this.commitmentScoreController,
    required this.communicationScoreController,
    required this.feedbackController,
    required this.selectedFinalDecision,
    required this.scoreValidator,
    required this.feedbackValidator,
    required this.onDecisionChanged,
    required this.onSubmit,
    required this.onRetry,
    required this.decisionLabel,
    required this.formatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    if (isSubmissionLoading && submission == null) {
      return const _EvaluationLoadingState(
        message: 'جاري التحقق من وجود تسليم نهائي...',
      );
    }

    if (submissionErrorMessage.isNotEmpty && submission == null) {
      return _EvaluationErrorState(
        title: 'تعذر التحقق من التسليم',
        message:
            'لم نتمكن من التحقق من وجود تسليم نهائي حالياً. يرجى المحاولة مرة أخرى.',
        onRetry: onRetry,
      );
    }

    if (submission == null) {
      return const _NoSubmissionEvaluationState();
    }

    if (isReviewLoading && review == null) {
      return const _EvaluationLoadingState(
        message: 'جاري تحميل بيانات التقييم...',
      );
    }

    if (reviewErrorMessage.isNotEmpty && review == null) {
      if (_isMissingReviewMessage(reviewErrorMessage)) {
        return _EvaluationForm(
          formKey: formKey,
          qualityScoreController: qualityScoreController,
          commitmentScoreController: commitmentScoreController,
          communicationScoreController: communicationScoreController,
          feedbackController: feedbackController,
          selectedFinalDecision: selectedFinalDecision,
          isSubmittingReview: isSubmittingReview,
          scoreValidator: scoreValidator,
          feedbackValidator: feedbackValidator,
          onDecisionChanged: onDecisionChanged,
          onSubmit: onSubmit,
        );
      }

      return _EvaluationErrorState(
        title: 'تعذر تحميل التقييم',
        message:
            'لم نتمكن من تحميل بيانات التقييم حالياً. يرجى المحاولة مرة أخرى.',
        onRetry: onRetry,
      );
    }

    if (review != null) {
      return _ReviewReadOnlyView(
        review: review!,
        decisionLabel: decisionLabel,
        formatDateTime: formatDateTime,
      );
    }

    return _EvaluationForm(
      formKey: formKey,
      qualityScoreController: qualityScoreController,
      commitmentScoreController: commitmentScoreController,
      communicationScoreController: communicationScoreController,
      feedbackController: feedbackController,
      selectedFinalDecision: selectedFinalDecision,
      isSubmittingReview: isSubmittingReview,
      scoreValidator: scoreValidator,
      feedbackValidator: feedbackValidator,
      onDecisionChanged: onDecisionChanged,
      onSubmit: onSubmit,
    );
  }

  static bool _isMissingReviewMessage(String message) {
    final normalizedMessage = message.toLowerCase();

    return normalizedMessage.contains('no review') ||
        normalizedMessage.contains('review not found') ||
        normalizedMessage.contains('not found') ||
        normalizedMessage.contains('لا يوجد تقييم') ||
        normalizedMessage.contains('لا توجد مراجعة') ||
        normalizedMessage.contains('غير موجود');
  }
}

class _NoSubmissionEvaluationState extends StatelessWidget {
  const _NoSubmissionEvaluationState();

  @override
  Widget build(BuildContext context) {
    return const _EvaluationStateCard(
      icon: Icons.lock_clock_outlined,
      title: 'لا يمكن تقييم المهمة حالياً',
      message:
          'يجب أن يرسل الطالب التسليم النهائي أولاً حتى تتمكن الشركة من تقييم جودة العمل والالتزام والتواصل.',
    );
  }
}

class _EvaluationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController qualityScoreController;
  final TextEditingController commitmentScoreController;
  final TextEditingController communicationScoreController;
  final TextEditingController feedbackController;
  final String selectedFinalDecision;
  final bool isSubmittingReview;
  final String? Function(String?) scoreValidator;
  final String? Function(String?) feedbackValidator;
  final ValueChanged<String> onDecisionChanged;
  final VoidCallback onSubmit;

  const _EvaluationForm({
    required this.formKey,
    required this.qualityScoreController,
    required this.commitmentScoreController,
    required this.communicationScoreController,
    required this.feedbackController,
    required this.selectedFinalDecision,
    required this.isSubmittingReview,
    required this.scoreValidator,
    required this.feedbackValidator,
    required this.onDecisionChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'تقييم التسليم النهائي',
            subtitle:
                'قيّم العمل بناءً على جودة التنفيذ، الالتزام، والتواصل مع الطالب.',
          ),
          const SizedBox(height: 16),

          _ScoreField(
            controller: qualityScoreController,
            label: 'درجة جودة التنفيذ',
            hint: 'مثال: 90',
            icon: Icons.workspace_premium_outlined,
            validator: scoreValidator,
          ),
          const SizedBox(height: 12),

          _ScoreField(
            controller: commitmentScoreController,
            label: 'درجة الالتزام',
            hint: 'مثال: 85',
            icon: Icons.event_available_outlined,
            validator: scoreValidator,
          ),
          const SizedBox(height: 12),

          _ScoreField(
            controller: communicationScoreController,
            label: 'درجة التواصل',
            hint: 'مثال: 88',
            icon: Icons.forum_outlined,
            validator: scoreValidator,
          ),
          const SizedBox(height: 16),

          const Text(
            'القرار النهائي',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),

          _DecisionSelector(
            selectedFinalDecision: selectedFinalDecision,
            onDecisionChanged: onDecisionChanged,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: feedbackController,
            validator: feedbackValidator,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            decoration: _inputDecoration(
              label: 'ملاحظات الشركة',
              hint:
                  'اكتب ملاحظات واضحة تساعد الطالب على فهم سبب التقييم والقرار النهائي.',
              icon: Icons.rate_review_outlined,
            ),
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSubmittingReview ? null : onSubmit,
              icon: isSubmittingReview
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 20,
                    ),
              label: Text(
                isSubmittingReview
                    ? 'جاري حفظ التقييم...'
                    : 'حفظ التقييم النهائي',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppColors.primaryBlue.withOpacity(0.45),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewReadOnlyView extends StatelessWidget {
  final CompanyTaskSubmissionReviewModel review;
  final String Function(String) decisionLabel;
  final String Function(DateTime?) formatDateTime;

  const _ReviewReadOnlyView({
    required this.review,
    required this.decisionLabel,
    required this.formatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'تم تقييم التسليم',
          subtitle:
              'تم حفظ تقييم الشركة لهذا التسليم النهائي، ويمكن استعراض النتيجة أدناه.',
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              _ReviewDecisionHeader(
                decision: decisionLabel(review.finalDecision),
                totalScore: review.scores.total,
              ),
              const Divider(height: 28),

              Row(
                children: [
                  Expanded(
                    child: _ScoreResultCard(
                      label: 'جودة التنفيذ',
                      value: review.scores.quality.toString(),
                      icon: Icons.workspace_premium_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ScoreResultCard(
                      label: 'الالتزام',
                      value: review.scores.commitment.toString(),
                      icon: Icons.event_available_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _ScoreResultCard(
                      label: 'التواصل',
                      value: review.scores.communication.toString(),
                      icon: Icons.forum_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ScoreResultCard(
                      label: 'المجموع',
                      value: review.scores.total.toStringAsFixed(2),
                      icon: Icons.analytics_outlined,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _InfoCard(
          title: 'ملاحظات الشركة',
          value: review.feedback.trim().isEmpty
              ? 'لم تتم إضافة ملاحظات.'
              : review.feedback,
          icon: Icons.rate_review_outlined,
        ),
        const SizedBox(height: 12),

        _InfoCard(
          title: 'تاريخ التقييم',
          value: formatDateTime(review.reviewedAt),
          icon: Icons.schedule_outlined,
        ),
      ],
    );
  }
}

class _ReviewDecisionHeader extends StatelessWidget {
  final String decision;
  final num totalScore;

  const _ReviewDecisionHeader({
    required this.decision,
    required this.totalScore,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.verified_outlined,
            color: AppColors.primaryBlue,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'القرار النهائي',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                decision,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            totalScore.toStringAsFixed(2),
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreResultCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ScoreResultCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 21,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DecisionSelector extends StatelessWidget {
  final String selectedFinalDecision;
  final ValueChanged<String> onDecisionChanged;

  const _DecisionSelector({
    required this.selectedFinalDecision,
    required this.onDecisionChanged,
  });

  @override
  Widget build(BuildContext context) {
    const decisions = [
      _DecisionOption(
        value: 'approved',
        label: 'مقبول',
        icon: Icons.check_circle_outline_rounded,
      ),
      _DecisionOption(
        value: 'needs_revision',
        label: 'يحتاج تعديلات',
        icon: Icons.edit_note_rounded,
      ),
      _DecisionOption(
        value: 'rejected',
        label: 'مرفوض',
        icon: Icons.cancel_outlined,
      ),
    ];

    return Column(
      children: decisions.map((decision) {
        final isSelected = selectedFinalDecision == decision.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onDecisionChanged(decision.value),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue.withOpacity(0.09)
                      : AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.primaryBlue.withOpacity(0.08),
                    width: isSelected ? 1.3 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      decision.icon,
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.textGrey,
                      size: 21,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        decision.label,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.textDark,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.textGrey.withOpacity(0.45),
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DecisionOption {
  final String value;
  final String label;
  final IconData icon;

  const _DecisionOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}

class _ScoreField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;

  const _ScoreField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      decoration: _inputDecoration(
        label: label,
        hint: hint,
        icon: icon,
      ),
      style: const TextStyle(
        color: AppColors.textDark,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    height: 1.6,
                    fontWeight: FontWeight.w700,
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12.5,
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

class _EvaluationStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EvaluationStateCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 24,
      ),
      decoration: _cardDecoration(radius: 22),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 12.5,
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EvaluationLoadingState extends StatelessWidget {
  final String message;

  const _EvaluationLoadingState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 36,
      ),
      decoration: _cardDecoration(radius: 22),
      child: Column(
        children: [
          const SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              color: AppColors.primaryBlue,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EvaluationErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const _EvaluationErrorState({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(radius: 22),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 12.5,
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
              ),
              label: const Text(
                'إعادة تحميل البيانات',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration({
  required String label,
  required String hint,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(
      icon,
      color: AppColors.primaryBlue,
      size: 21,
    ),
    filled: true,
    fillColor: AppColors.cardWhite,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 14,
    ),
    labelStyle: const TextStyle(
      color: AppColors.textGrey,
      fontWeight: FontWeight.w700,
    ),
    hintStyle: TextStyle(
      color: AppColors.textGrey.withOpacity(0.65),
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: AppColors.primaryBlue.withOpacity(0.08),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: AppColors.primaryBlue,
        width: 1.3,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Colors.redAccent,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Colors.redAccent,
      ),
    ),
  );
}

BoxDecoration _cardDecoration({
  double radius = 20,
}) {
  return BoxDecoration(
    color: AppColors.cardWhite,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: AppColors.primaryBlue.withOpacity(0.08),
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryBlue.withOpacity(0.05),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );
}