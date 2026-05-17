import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/assessment/assessment_models.dart';
import 'package:jisr_platform/services/student/assessment/assessment_service.dart';

class AssessmentController extends GetxController {
  final AssessmentService _service = AssessmentService();

  final TextEditingController answerController = TextEditingController();

  final RxBool isStarting = false.obs;
  final RxBool isLoadingQuestion = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isCompleted = false.obs;
  final RxBool isCompleting = false.obs;

  final Rxn<AssessmentSessionData> session = Rxn<AssessmentSessionData>();
  final Rxn<AssessmentQuestion> currentQuestion = Rxn<AssessmentQuestion>();
  final Rxn<AssessmentAnswerResult> lastResult = Rxn<AssessmentAnswerResult>();
  final Rxn<AssessmentCompleteData> completedAssessment =
      Rxn<AssessmentCompleteData>();

  late final int careerPathId;
  late final int cvId;
  late final List<int> skillIds;
  late final Map<int, String> skillNames;

  int currentSkillIndex = 0;

  int get assessmentSessionId => session.value?.assessmentSessionId ?? 0;

  int get currentSkillId => skillIds.isEmpty ? 0 : skillIds[currentSkillIndex];

  bool get isLastSkill => currentSkillIndex >= skillIds.length - 1;

  String get currentSkillName {
    final question = currentQuestion.value;
    if (question != null && question.skillName.isNotEmpty) {
      return question.skillName;
    }

    return skillNames[currentSkillId] ?? 'مهارة';
  }

  double get progress {
    if (skillIds.isEmpty) return 0;
    return (currentSkillIndex + 1) / skillIds.length;
  }

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>;

    careerPathId = args['careerPathId'] as int;
    cvId = args['cvId'] as int;
    skillIds = List<int>.from(args['skillIds'] ?? []);
    skillNames = Map<int, String>.from(args['skillNames'] ?? {});

    startAssessment();
  }

  Future<void> startAssessment() async {
    if (skillIds.isEmpty) {
      JisrSnackbar.show(
        title: 'لا توجد مهارات',
        message: 'لم يتم العثور على مهارات لإجراء الاختبار',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    try {
      isStarting.value = true;
      isLoadingQuestion.value = false;
      isCompleted.value = false;
      isCompleting.value = false;

      final response = await _service.createAssessment(
        careerPathId: careerPathId,
        cvId: cvId,
        skillIds: skillIds,
      );

      session.value = response.data;
      isStarting.value = false;

      await loadNextQuestion();
    } catch (e) {
      isStarting.value = false;
      isLoadingQuestion.value = false;

      JisrSnackbar.show(
        title: 'فشل بدء الاختبار',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    }
  }

  Future<void> loadNextQuestion() async {
    if (assessmentSessionId == 0 || isCompleted.value || isCompleting.value) {
      return;
    }

    try {
      isLoadingQuestion.value = true;

      final result = await _service.getNextQuestion(
        assessmentSessionId: assessmentSessionId,
        skillId: currentSkillId,
      );

      if (result.isSkillCompleted) {
        isLoadingQuestion.value = false;
        await finishCurrentSkill();
        return;
      }

      if (result.question != null) {
        currentQuestion.value = result.question;
        answerController.clear();
        lastResult.value = null;
        isLoadingQuestion.value = false;
        return;
      }

      isLoadingQuestion.value = false;

      JisrSnackbar.show(
        title: 'تعذر جلب السؤال',
        message: result.message,
        type: JisrSnackbarType.error,
      );
    } catch (e) {
      isLoadingQuestion.value = false;

      final error = e.toString().toLowerCase();

      if (error.contains('already completed') ||
          error.contains('completedat')) {
        await finishCurrentSkill();
        return;
      }

      JisrSnackbar.show(
        title: 'خطأ بجلب السؤال',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    }
  }

  Future<void> submitAnswer() async {
    if (isSubmitting.value || isCompleting.value || isCompleted.value) return;

    final question = currentQuestion.value;
    final answer = answerController.text.trim();

    if (question == null) return;

    if (answer.isEmpty) {
      JisrSnackbar.show(
        title: 'الإجابة فارغة',
        message: 'اكتبي إجابتك أولاً',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    try {
      isSubmitting.value = true;

      final result = await _service.submitAnswer(
        assessmentSessionId: assessmentSessionId,
        attemptId: question.attemptId,
        answer: answer,
      );

      lastResult.value = result;

      await Future.delayed(const Duration(milliseconds: 700));

      await loadNextQuestion();
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      final lowerError = errorMessage.toLowerCase();

      if (lowerError.contains('already been answered')) {
        await loadNextQuestion();
        return;
      }

      if (lowerError.contains('already completed') ||
          lowerError.contains('completedat')) {
        await finishCurrentSkill();
        return;
      }

      JisrSnackbar.show(
        title: 'فشل إرسال الإجابة',
        message: errorMessage,
        type: JisrSnackbarType.error,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> finishCurrentSkill() async {
    isLoadingQuestion.value = false;
    currentQuestion.value = null;
    answerController.clear();
    lastResult.value = null;

    if (isLastSkill) {
      await completeAssessmentSession();
      return;
    }

    currentSkillIndex++;

    JisrSnackbar.show(
      title: 'تم إنهاء المهارة',
      message: 'ننتقل الآن للمهارة التالية',
      type: JisrSnackbarType.success,
    );

    await Future.delayed(const Duration(milliseconds: 700));
    await loadNextQuestion();
  }

  Future<void> completeAssessmentSession() async {
    if (assessmentSessionId == 0 || isCompleting.value || isCompleted.value) {
      return;
    }

    try {
      isCompleting.value = true;
      isLoadingQuestion.value = false;
      isSubmitting.value = false;
      currentQuestion.value = null;
      answerController.clear();
      lastResult.value = null;

      final response = await _service.completeAssessment(
        assessmentSessionId: assessmentSessionId,
      );

      completedAssessment.value = response.data;
      isCompleted.value = true;
    } catch (e) {
      JisrSnackbar.show(
        title: 'فشل إنهاء الاختبار',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    } finally {
      isCompleting.value = false;
    }
  }

  @override
  void onClose() {
    answerController.dispose();
    super.onClose();
  }
}
