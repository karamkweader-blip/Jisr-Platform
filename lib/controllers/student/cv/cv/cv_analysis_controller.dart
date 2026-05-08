import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/cv/cv_analysis_response.dart';
import 'package:jisr_platform/services/student/cv/cv_analysis_service.dart';

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
}
