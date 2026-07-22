import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/assessment/assessment_models.dart';
import 'package:jisr_platform/models/student/home/home_model.dart';
import 'package:jisr_platform/services/student/assessment/assessment_learning_plan_cache.dart';
import 'package:jisr_platform/services/student/assessment/assessment_service.dart';

class HomeController extends GetxController {
  final AssessmentLearningPlanCache _learningPlanCache =
      AssessmentLearningPlanCache();
  final AssessmentService _assessmentService = AssessmentService();

  final isLoading = false.obs;
  final RxBool isLoadingLatestLearningPlan = false.obs;
  final RxBool isGeneratingAiPlan = false.obs;
  final RxBool isLoadingLatestAiPlan = false.obs;
  final Rxn<AssessmentLearningPlanCacheData> latestLearningPlanCache =
      Rxn<AssessmentLearningPlanCacheData>();
  final Rxn<AssessmentAiLearningPlan> latestAiLearningPlan =
      Rxn<AssessmentAiLearningPlan>();
  final RxList<AssessmentLearningPathItem> latestRoadmap =
      <AssessmentLearningPathItem>[].obs;

  final homeData = HomeModel(
    title: 'أهلاً بك في جسور',
    subtitle: 'ابدأ ببناء ملفك المهني واستعد لفرصك القادمة',
  );

  bool get hasLatestLearningPlan => latestLearningPlanCache.value != null;

  @override
  void onReady() {
    super.onReady();
    loadLatestLearningPlan();
  }

  Future<void> loadLatestLearningPlan({bool silent = false}) async {
    try {
      if (!silent) isLoadingLatestLearningPlan.value = true;

      final cached = await _learningPlanCache.read();
      latestLearningPlanCache.value = cached;

      if (cached == null) {
        latestAiLearningPlan.value = null;
        latestRoadmap.clear();
        return;
      }

      // أولاً: اعرض النسخة الكاملة المحفوظة، حتى لا تختفي المهارات المناسبة.
      latestRoadmap.assignAll(cached.roadmap);

      try {
        final roadmapResponse = await _assessmentService.getLearningPath(
          assessmentSessionId: cached.assessmentSessionId,
        );

        if (roadmapResponse.data.isNotEmpty) {
          await _learningPlanCache.mergeRoadmap(
            assessmentSessionId: cached.assessmentSessionId,
            careerPath: cached.careerPath,
            careerPathId: cached.careerPathId,
            cvId: cached.cvId,
            updatedItems: roadmapResponse.data,
          );

          final refreshed = await _learningPlanCache.read();
          latestLearningPlanCache.value = refreshed ?? cached;
          latestRoadmap.assignAll(refreshed?.roadmap ?? cached.roadmap);
        }
      } catch (_) {
        // لا نمسح الخريطة من الواجهة إذا فشل الباك أو رجع فقط المهارات الضعيفة.
        latestRoadmap.assignAll(cached.roadmap);
      }

      try {
        final response = await _assessmentService.getLatestAiLearningPlan(
          assessmentSessionId: cached.assessmentSessionId,
        );
        latestAiLearningPlan.value = response.data;
      } catch (_) {
        latestAiLearningPlan.value = null;
      }
    } finally {
      if (!silent) isLoadingLatestLearningPlan.value = false;
    }
  }

  void showNoLearningPlanMessage() {
    JisrSnackbar.show(
      title: 'لا توجد خريطة بعد',
      message: 'أنه الاختبار ليتم حفظ خريطة التطوير هنا.',
      type: JisrSnackbarType.warning,
    );
  }

  Future<AssessmentAiLearningPlan?> generateAiLearningPlan({
    required int weeks,
    required int hoursPerWeek,
  }) async {
    final cached = latestLearningPlanCache.value;
    if (cached == null) {
      showNoLearningPlanMessage();
      return null;
    }

    try {
      isGeneratingAiPlan.value = true;

      final response = await _assessmentService.generateAiLearningPlan(
        assessmentSessionId: cached.assessmentSessionId,
        weeks: weeks,
        hoursPerWeek: hoursPerWeek,
      );

      latestAiLearningPlan.value = response.data;
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
    final cached = latestLearningPlanCache.value;
    if (cached == null) {
      showNoLearningPlanMessage();
      return null;
    }

    try {
      isLoadingLatestAiPlan.value = true;

      final response = await _assessmentService.getLatestAiLearningPlan(
        assessmentSessionId: cached.assessmentSessionId,
      );

      latestAiLearningPlan.value = response.data;
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
}
