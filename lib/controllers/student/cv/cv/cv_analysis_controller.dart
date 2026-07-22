import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/cv/cv_analysis_response.dart';
import 'package:jisr_platform/services/student/cv/cv_analysis_service.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/student/assessment/assessment_learning_plan_cache.dart';

class CvAnalysisController extends GetxController {
  final CvAnalysisService _analysisService = CvAnalysisService();

  final RxBool isLoading = false.obs;
  final Rxn<CvAnalysisResponse> analysis = Rxn<CvAnalysisResponse>();

  late final int cvId;

  @override
  void onInit() {
    super.onInit();

    cvId = Get.arguments as int;
    analyzeCv();
  }

  Future<void> analyzeCv() async {
    try {
      isLoading.value = true;

      final result = await _analysisService.analyzeCv(cvId);
      analysis.value = result;

      JisrSnackbar.show(
        title: 'تم تحليل السيرة الذاتية',
        message: 'استخرجنا مهاراتك بنجاح',
        type: JisrSnackbarType.success,
      );
    } catch (e) {
      JisrSnackbar.show(
        title: 'فشل التحليل',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startAssessment() async {
    final result = analysis.value;

    if (result == null) return;

    final skillIds = result.skills
        .map((skill) => skill.skillId)
        .where((id) => id != 0)
        .toList();

    final skillNames = {
      for (final skill in result.skills) skill.skillId: skill.skillName,
    };

    await AssessmentLearningPlanCache().saveRetestSeed(
      careerPathId: 1,
      cvId: result.cvId,
    );

    Get.toNamed(
      Routes.assessment,
      arguments: {
        'careerPathId': 1,
        'cvId': result.cvId,
        'skillIds': skillIds,
        'skillNames': skillNames,
      },
    );
  }
}
