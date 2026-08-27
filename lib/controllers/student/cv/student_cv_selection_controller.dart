import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/cv/student_cv_history_analysis_controller.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/cv/student_cv_history_models.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/student/cv/student_cv_history_service.dart';

class StudentCvSelectionController extends GetxController {
  final StudentCvHistoryService _service = StudentCvHistoryService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<StudentCvItem> cvs = <StudentCvItem>[].obs;
  bool _requestInProgress = false;

  @override
  void onReady() {
    super.onReady();
    loadCvs();
  }

  Future<void> loadCvs() async {
    if (_requestInProgress) return;
    final fullLoading = cvs.isEmpty;

    try {
      _requestInProgress = true;
      if (fullLoading) isLoading.value = true;
      errorMessage.value = '';
      final response = await _service.getStudentCvs();
      cvs.assignAll(response.cvs);
    } catch (error) {
      errorMessage.value = error.toString();
      if (cvs.isNotEmpty) {
        JisrSnackbar.show(
          title: 'تعذر تحديث السير الذاتية',
          message: errorMessage.value,
          type: JisrSnackbarType.error,
        );
      }
    } finally {
      if (fullLoading) isLoading.value = false;
      _requestInProgress = false;
    }
  }

  Future<void> openCv(StudentCvItem cv) async {
    if (!cv.hasAnalysis) {
      JisrSnackbar.show(
        title: 'لا يوجد تحليل محفوظ',
        message: 'هذه السيرة الذاتية لا تحتوي على تحليل ضمن البيانات الحالية.',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    if (Get.isRegistered<StudentCvHistoryAnalysisController>()) {
      await Get.delete<StudentCvHistoryAnalysisController>(force: true);
    }

    final shouldRefresh = await Get.toNamed(
      Routes.cvHistoryAnalysis,
      arguments: cv.cvId,
    );
    if (shouldRefresh == true) await loadCvs();
  }
}
