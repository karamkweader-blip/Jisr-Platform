import 'package:get/get.dart';
import 'package:jisr_platform/models/company/tasks/company_task_application_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/company/tasks/company_task_applicants_service.dart';

class CompanyTaskApplicantsController extends GetxController {
  final CompanyTaskApplicantsService _applicantsService;

  CompanyTaskApplicantsController(this._applicantsService);

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<CompanyTaskApplicationModel> applications =
      <CompanyTaskApplicationModel>[].obs;

  late final int taskId;
  late final String taskTitle;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;

    taskId = int.tryParse(args?['taskId']?.toString() ?? '') ?? 0;
    taskTitle = args?['taskTitle']?.toString() ?? 'المهمة';

    if (taskId == 0) {
      errorMessage.value = 'رقم المهمة غير صالح';
      return;
    }

    fetchApplications();
  }

  Future<void> fetchApplications() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _applicantsService.getTaskApplications(taskId);

      final sortedResult = [...result]
        ..sort((a, b) => b.matchScore.compareTo(a.matchScore));

      applications.assignAll(sortedResult);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshApplications() async {
    await fetchApplications();
  }

  void goToApplicantDetails(CompanyTaskApplicationModel application) {
    Get.toNamed(
      Routes.companyTaskApplicantDetails,
      arguments: {
        'taskId': taskId,
        'taskTitle': taskTitle,
        'applicationId': application.applicationId,
        'studentName': application.student.name,
      },
    );
  }

  String applicationStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'بانتظار المراجعة';
      case 'accepted':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  String formatAppliedAt(DateTime? date) {
    if (date == null) return 'غير محدد';

    final local = date.toLocal();

    return '${local.year}/${_twoDigits(local.month)}/${_twoDigits(local.day)}';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}