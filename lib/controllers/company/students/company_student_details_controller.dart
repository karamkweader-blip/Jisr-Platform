import 'package:get/get.dart';
import 'package:jisr_platform/models/company/students/company_student_details_model.dart';
import 'package:jisr_platform/services/company/students/company_student_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyStudentDetailsController
    extends GetxController {
  final CompanyStudentService _studentService;

  CompanyStudentDetailsController(
    this._studentService,
  );

  final Rxn<CompanyStudentDetailsModel> student =
      Rxn<CompanyStudentDetailsModel>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  late final int studentId;

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;

    studentId = arguments is Map
        ? int.tryParse(
              arguments['studentId']
                      ?.toString() ??
                  '',
            ) ??
            0
        : 0;

    if (studentId <= 0) {
      errorMessage.value =
          'معرف الطالب غير صالح';

      return;
    }

    fetchStudentDetails();
  }

  Future<void> fetchStudentDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      student.value =
          await _studentService
              .getStudentDetails(studentId);
    } catch (error) {
      errorMessage.value =
          _cleanError(error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openExternalUrl(
    String rawUrl,
  ) async {
    final uri = Uri.tryParse(rawUrl.trim());

    if (uri == null ||
        (uri.scheme != 'http' &&
            uri.scheme != 'https') ||
        uri.host.isEmpty) {
      _showLinkError();

      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        _showLinkError();
      }
    } catch (_) {
      _showLinkError();
    }
  }

  String formatDate(DateTime? value) {
    if (value == null) {
      return 'غير محدد';
    }

    final local = value.toLocal();

    return '${local.year}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.day.toString().padLeft(2, '0')}';
  }

  String sourceLabel(String source) {
    return switch (source) {
      'manual' => 'مضافة يدويًا',
      'cv' => 'من السيرة الذاتية',
      'assessment' => 'من اختبار المستوى',
      _ when source.trim().isEmpty =>
        'غير محدد',
      _ => source,
    };
  }

  void _showLinkError() {
    Get.snackbar(
      'تعذر فتح الرابط',
      'الرابط غير متاح حاليًا، حاول مجددًا لاحقًا.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '');
  }
}