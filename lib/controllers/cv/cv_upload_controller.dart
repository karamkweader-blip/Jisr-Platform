import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/cv/cv_upload_response.dart';
import 'package:jisr_platform/services/cv/cv_service.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class CvUploadController extends GetxController {
  final CvService _cvService = CvService();

  final RxBool isLoading = false.obs;
  final Rxn<PlatformFile> selectedFile = Rxn<PlatformFile>();
  final Rxn<CvUploadResponse> uploadedCv = Rxn<CvUploadResponse>();

  Future<void> pickCvFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;

    selectedFile.value = result.files.first;
    uploadedCv.value = null;
  }

  Future<void> uploadCv() async {
    final file = selectedFile.value;

    if (file == null || file.path == null) {
      JisrSnackbar.show(
        title: 'اختاري ملف أولاً',
        message: 'يرجى اختيار ملف CV بصيغة PDF أو Word',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await _cvService.uploadCv(
        filePath: file.path!,
        isPrimary: true,
      );

      uploadedCv.value = response;

      JisrSnackbar.show(
        title: 'تم رفع الملف بنجاح',
        message: 'سيتم تحليل السيرة الذاتية الآن',
        type: JisrSnackbarType.success,
      );

      Get.toNamed(Routes.cvAnalysis, arguments: response.cvId);
    } catch (e) {
      JisrSnackbar.show(
        title: 'فشل رفع الملف',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void removeFile() {
    selectedFile.value = null;
    uploadedCv.value = null;
  }
}
