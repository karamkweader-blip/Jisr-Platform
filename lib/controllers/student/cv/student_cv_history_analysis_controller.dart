import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/cv/student_cv_history_models.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/student/assessment/assessment_learning_plan_cache.dart';
import 'package:jisr_platform/services/student/assessment/assessment_career_path_resolver.dart';
import 'package:jisr_platform/services/student/cv/student_cv_history_service.dart';

class StudentCvHistoryAnalysisController extends GetxController {
  final StudentCvHistoryService _service = StudentCvHistoryService();
  final AssessmentCareerPathResolver _careerPathResolver =
      AssessmentCareerPathResolver();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<StudentCvAnalysisDetailsResponse> details =
      Rxn<StudentCvAnalysisDetailsResponse>();

  int cvId = 0;

  @override
  void onInit() {
    super.onInit();
    cvId = int.tryParse(Get.arguments?.toString() ?? '') ?? 0;
    if (cvId <= 0) {
      errorMessage.value = 'تعذر تحديد السيرة الذاتية المطلوبة';
      return;
    }
    loadAnalysis();
  }

  Future<void> loadAnalysis() async {
    if (isLoading.value || cvId <= 0) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      details.value = await _service.getAnalysis(cvId);
    } catch (error) {
      errorMessage.value = error.toString();
      if (error is StudentCvHistoryException && error.statusCode == 404) {
        JisrSnackbar.show(
          title: 'التحليل غير متاح',
          message: errorMessage.value,
          type: JisrSnackbarType.warning,
        );
        Future<void>.microtask(() => Get.back(result: true));
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startAssessment() async {
    final value = details.value;
    if (value == null) return;

    final skillIds = value.analysis.skills
        .map((skill) => skill.skillId)
        .whereType<int>()
        .where((id) => id > 0)
        .toList(growable: false);
    if (skillIds.isEmpty) {
      JisrSnackbar.show(
        title: 'لا يمكن بدء الاختبار',
        message: 'لا توجد مهارات مرتبطة بمعرّفات صالحة في هذا التحليل.',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    final skillNames = <int, String>{
      for (final skill in value.analysis.skills)
        if (skill.skillId != null && skill.skillId! > 0)
          skill.skillId!: skill.displayName,
    };

    try {
      final careerPathId = await _careerPathResolver.resolveForCv(
        cvId: value.cv.cvId,
      );
      if (careerPathId == null) return;

      await AssessmentLearningPlanCache().saveRetestSeed(
        careerPathId: careerPathId,
        cvId: value.cv.cvId,
      );

      Get.toNamed(
        Routes.assessment,
        arguments: <String, dynamic>{
          'careerPathId': careerPathId,
          'cvId': value.cv.cvId,
          'skillIds': skillIds,
          'skillNames': skillNames,
        },
      );
    } catch (error) {
      JisrSnackbar.show(
        title: 'تعذر بدء الاختبار',
        message: error.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    }
  }
}
