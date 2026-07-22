import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/controllers/student/home/home_controller.dart';
import 'package:jisr_platform/models/student/assessment/assessment_models.dart';
import 'package:jisr_platform/services/student/assessment/assessment_service.dart';
import 'package:jisr_platform/services/student/assessment/assessment_learning_plan_cache.dart';
import 'package:jisr_platform/services/student/assessment/assessment_session_cache.dart';
import 'package:jisr_platform/services/student/assessment/assessment_lock_service.dart';

class AssessmentController extends GetxController with WidgetsBindingObserver {
  final AssessmentService _service = AssessmentService();
  final AssessmentLearningPlanCache _learningPlanCache =
      AssessmentLearningPlanCache();

  final TextEditingController answerController = TextEditingController();
  final AssessmentSessionCache _sessionCache = AssessmentSessionCache();

  final RxBool isAssessmentLocked = false.obs;
  final RxInt exitAttempts = 0.obs;

  int? _cachedAssessmentSessionId;
  bool _leftAppWhileAssessmentActive = false;
  final RxBool isStarting = false.obs;
  final AssessmentLockService _lockService = AssessmentLockService();
  final RxBool isLoadingQuestion = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isCompleted = false.obs;
  final RxBool isCompleting = false.obs;
  final RxBool isGeneratingAiPlan = false.obs;
  final RxBool isLoadingLatestAiPlan = false.obs;
  final Rxn<AssessmentSessionData> session = Rxn<AssessmentSessionData>();
  final Rxn<AssessmentQuestion> currentQuestion = Rxn<AssessmentQuestion>();
  final Rxn<AssessmentAnswerResult> lastResult = Rxn<AssessmentAnswerResult>();
  final Rxn<AssessmentCompleteData> completedAssessment =
      Rxn<AssessmentCompleteData>();

  late final int careerPathId;
  late final int cvId;
  late final bool isRetest;
  late final List<int> skillIds;
  late final Map<int, String> skillNames;
  final RxBool isLoadingReport = false.obs;

  final Rxn<AssessmentSummaryData> assessmentSummary =
      Rxn<AssessmentSummaryData>();

  final RxList<AssessmentSkillGap> skillGaps = <AssessmentSkillGap>[].obs;

  final RxList<AssessmentLearningPathItem> learningPath =
      <AssessmentLearningPathItem>[].obs;
  int currentSkillIndex = 0;

  int get assessmentSessionId {
    return session.value?.assessmentSessionId ??
        _cachedAssessmentSessionId ??
        0;
  }

  int get currentSkillId {
    if (skillIds.isEmpty || currentSkillIndex < 0) return 0;
    if (currentSkillIndex >= skillIds.length) return 0;
    return skillIds[currentSkillIndex];
  }

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
    WidgetsBinding.instance.addObserver(this);
    final args = Get.arguments as Map<String, dynamic>;

    careerPathId = int.tryParse(args['careerPathId']?.toString() ?? '') ?? 0;
    cvId = int.tryParse(args['cvId']?.toString() ?? '') ?? 0;
    isRetest = args['isRetest'] == true ||
        args['forceNewSession'] == true ||
        args['is_retest']?.toString().toLowerCase().trim() == 'true';
    skillIds = List<int>.from(
      (args['skillIds'] as List? ?? [])
          .map((item) => int.tryParse(item.toString()) ?? 0)
          .where((id) => id > 0),
    );
    skillNames = Map<int, String>.from(args['skillNames'] ?? {});

    startAssessment();
  }

  Future<void> _saveActiveSession() async {
    if (assessmentSessionId == 0 || skillIds.isEmpty) return;

    await _sessionCache.save(
      AssessmentSessionCacheData(
        assessmentSessionId: assessmentSessionId,
        careerPathId: careerPathId,
        cvId: cvId,
        skillIds: skillIds,
        skillNames: skillNames,
        currentSkillIndex: currentSkillIndex,
        exitAttempts: exitAttempts.value,
      ),
    );
  }

  void showBlockedExitMessage() {
    JisrSnackbar.show(
      title: 'الاختبار قيد التنفيذ',
      message: 'لا يمكن مغادرة شاشة الاختبار قبل إنهائه.',
      type: JisrSnackbarType.warning,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!isAssessmentLocked.value || isCompleted.value) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _leftAppWhileAssessmentActive = true;
      exitAttempts.value++;
      _saveActiveSession();
    }

    if (state == AppLifecycleState.resumed && _leftAppWhileAssessmentActive) {
      _leftAppWhileAssessmentActive = false;

      JisrSnackbar.show(
        title: 'تنبيه',
        message: 'تم تسجيل محاولة خروج أثناء الاختبار.',
        type: JisrSnackbarType.warning,
      );
    }
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
      isAssessmentLocked.value = true;

      if (isRetest) {
        await _sessionCache.clear();
        _cachedAssessmentSessionId = null;
        session.value = null;
        currentSkillIndex = 0;
        exitAttempts.value = 0;
      }

      final cached = isRetest ? null : await _sessionCache.read();

      if (cached != null &&
          cached.matches(
            careerPathId: careerPathId,
            cvId: cvId,
            skillIds: skillIds,
          )) {
        _cachedAssessmentSessionId = cached.assessmentSessionId;
        currentSkillIndex = cached.currentSkillIndex
            .clamp(0, skillIds.length - 1)
            .toInt();
        exitAttempts.value = cached.exitAttempts;

        isStarting.value = false;
        await loadNextQuestion();
        return;
      }

      final response = await _service.createAssessment(
        careerPathId: careerPathId,
        cvId: cvId > 0 ? cvId : null,
        skillIds: skillIds,
      );

      session.value = response.data;
      _cachedAssessmentSessionId = response.data.assessmentSessionId;

      await _saveActiveSession();

      isStarting.value = false;
      await loadNextQuestion();
    } catch (e) {
      isStarting.value = false;
      isLoadingQuestion.value = false;
      isAssessmentLocked.value = false;

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
        await _saveActiveSession();
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
          error.contains('completedat') ||
          error.contains('اكتمل') ||
          error.contains('اكتملت') ||
          error.contains('مكتمل') ||
          error.contains('انتهت') ||
          error.contains('انتهى') ||
          error.contains('خلصت')) {
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

      await Future.delayed(const Duration(seconds: 1));

      if (result.isSkillCompleted) {
        await finishCurrentSkill();
        return;
      }

      await loadNextQuestion();
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      final lowerError = errorMessage.toLowerCase();

      if (lowerError.contains('already been answered')) {
        await loadNextQuestion();
        return;
      }

      if (lowerError.contains('already completed') ||
          lowerError.contains('completedat') ||
          lowerError.contains('اكتمل') ||
          lowerError.contains('اكتملت') ||
          lowerError.contains('مكتمل') ||
          lowerError.contains('انتهت') ||
          lowerError.contains('انتهى') ||
          lowerError.contains('خلصت')) {
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
    isLoadingQuestion.value = true;
    await _saveActiveSession();

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

      // /complete قد يرجع in_progress أو needs_review، وهذا يعني أن الاختبار لم ينتهِ بعد.
      if (!response.data.isReadyToShowFinalResults) {
        AssessmentCompleteSkill? nextSkill;
        for (final skill in response.data.skills) {
          if (skill.needsMoreQuestions) {
            nextSkill = skill;
            break;
          }
        }

        if (nextSkill != null) {
          final nextIndex = skillIds.indexOf(nextSkill.skillId);
          if (nextIndex != -1) currentSkillIndex = nextIndex;
        }

        isCompleting.value = false;
        await _saveActiveSession();
        await Future.delayed(const Duration(milliseconds: 350));
        await loadNextQuestion();
        return;
      }

      isAssessmentLocked.value = false;
      await _lockService.stopLock();
      await _sessionCache.clear();

      await fetchAssessmentReport();

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

  Future<void> fetchAssessmentReport() async {
    if (assessmentSessionId == 0) return;

    try {
      isLoadingReport.value = true;

      final results = await Future.wait([
        _service.getAssessmentSummary(assessmentSessionId: assessmentSessionId),
        _service.getSkillGaps(assessmentSessionId: assessmentSessionId),
        _service.getLearningPath(assessmentSessionId: assessmentSessionId),
      ]);

      assessmentSummary.value = (results[0] as AssessmentSummaryResponse).data;
      skillGaps.assignAll((results[1] as AssessmentSkillGapsResponse).gaps);
      final rawLearningPath = (results[2] as AssessmentLearningPathResponse).data;

      final mergedSnapshot = _buildRoadmapSnapshot(
        summary: assessmentSummary.value,
        gaps: skillGaps,
        learningPathItems: rawLearningPath,
      );

      learningPath.assignAll(mergedSnapshot);

      await _learningPlanCache.mergeRoadmap(
        assessmentSessionId: assessmentSessionId,
        careerPath: assessmentSummary.value?.careerPath ?? '',
        careerPathId: careerPathId,
        cvId: cvId > 0 ? cvId : null,
        updatedItems: mergedSnapshot,
      );

      // مهم جداً: إذا كان المستخدم راجع من إعادة تحديد المستوى، حدّث خريطة التطوير
      // الموجودة بالرئيسية فوراً بدل ما تبقى تعرض مستويات الجلسة القديمة.
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        await homeController.loadLatestLearningPlan(silent: true);
      }
    } catch (e) {
      JisrSnackbar.show(
        title: 'تعذر جلب التقرير',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.warning,
      );
    } finally {
      isLoadingReport.value = false;
    }
  }


  List<AssessmentLearningPathItem> _buildRoadmapSnapshot({
    required AssessmentSummaryData? summary,
    required List<AssessmentSkillGap> gaps,
    required List<AssessmentLearningPathItem> learningPathItems,
  }) {
    final byPath = <int, AssessmentLearningPathItem>{
      for (final item in learningPathItems)
        if (item.skillId > 0) item.skillId: item,
    };

    final byGap = <int, AssessmentSkillGap>{
      for (final gap in gaps)
        if (gap.skillId > 0) gap.skillId: gap,
    };

    final result = <AssessmentLearningPathItem>[];
    final used = <int>{};

    final summarySkills = summary?.skills ?? const <AssessmentSummarySkill>[];

    for (final skill in summarySkills) {
      if (skill.skillId <= 0) continue;

      final pathItem = byPath[skill.skillId];
      final gap = byGap[skill.skillId];

      final currentFromSummary = _bestCurrentLevel(skill);
      final currentFromGap = gap?.actualLevel ?? 0;
      final currentFromPath = pathItem?.currentLevel ?? 0;
      final current = currentFromSummary > 0
          ? currentFromSummary
          : (currentFromGap > 0
              ? currentFromGap
              : (currentFromPath > 0 ? currentFromPath : 0.0));

      final targetFromPath = pathItem?.targetLevel ?? 0;
      final targetFromGap = gap?.requiredLevel ?? 0;
      final target = targetFromPath > 0
          ? targetFromPath
          : (targetFromGap > 0 ? targetFromGap : current);

      final ready = target > 0 && current >= target;

      result.add(
        AssessmentLearningPathItem(
          skillId: skill.skillId,
          skillName: skill.skillName.isNotEmpty
              ? skill.skillName
              : (pathItem?.skillName ?? gap?.skillName ?? 'مهارة'),
          currentLevel: current,
          targetLevel: target > 0 ? target : current,
          priority: ready
              ? 'market_ready'
              : (current <= 0
                  ? 'unknown'
                  : (pathItem?.priority.isNotEmpty == true
                      ? pathItem!.priority
                      : (gap?.priority.isNotEmpty == true ? gap!.priority : 'medium'))),
          resources: ready ? <AssessmentLearningResource>[] : (pathItem?.resources ?? const []),
        ),
      );
      used.add(skill.skillId);
    }

    for (final item in learningPathItems) {
      if (item.skillId <= 0 || used.contains(item.skillId)) continue;
      final current = item.currentLevel < 0 ? 0.0 : item.currentLevel;
      final target = item.targetLevel > 0 ? item.targetLevel : current;
      final ready = target > 0 && current >= target;
      result.add(
        item.copyWith(
          currentLevel: current,
          targetLevel: target,
          priority: ready
              ? 'market_ready'
              : (current <= 0 ? 'unknown' : (item.priority.isEmpty ? 'medium' : item.priority)),
          resources: ready ? <AssessmentLearningResource>[] : item.resources,
        ),
      );
    }

    return result;
  }

  double _bestCurrentLevel(AssessmentSummarySkill skill) {
    if (skill.finalLevel != null && skill.finalLevel! > 0) {
      return skill.finalLevel!;
    }
    if (skill.currentLevel > 0) return skill.currentLevel;
    if (skill.initialLevel > 0) return skill.initialLevel;
    return 0;
  }

  Future<AssessmentAiLearningPlan?> generateAiLearningPlan({
    required int weeks,
    required int hoursPerWeek,
  }) async {
    if (assessmentSessionId == 0) return null;

    try {
      isGeneratingAiPlan.value = true;

      final response = await _service.generateAiLearningPlan(
        assessmentSessionId: assessmentSessionId,
        weeks: weeks,
        hoursPerWeek: hoursPerWeek,
      );

      await _learningPlanCache.save(
        assessmentSessionId: assessmentSessionId,
        careerPath: response.data.plan.careerPath,
        careerPathId: careerPathId,
        cvId: cvId > 0 ? cvId : null,
      );

      return response.data;
    } catch (e) {
      JisrSnackbar.show(
        title: 'تعذر إنشاء الخطة',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
      return null;
    } finally {
      isGeneratingAiPlan.value = false;
    }
  }

  Future<AssessmentAiLearningPlan?> getLatestAiLearningPlan() async {
    if (assessmentSessionId == 0) return null;

    try {
      isLoadingLatestAiPlan.value = true;

      final response = await _service.getLatestAiLearningPlan(
        assessmentSessionId: assessmentSessionId,
      );

      return response.data;
    } catch (e) {
      JisrSnackbar.show(
        title: 'تعذر جلب الخطة',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
      return null;
    } finally {
      isLoadingLatestAiPlan.value = false;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    answerController.dispose();
    super.onClose();
  }
}
