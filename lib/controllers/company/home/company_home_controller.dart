import 'package:get/get.dart';
import 'package:jisr_platform/models/company/company_home_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/company/company_home_service.dart';

class CompanyHomeController extends GetxController {
  final CompanyHomeService _homeService;

  CompanyHomeController(this._homeService);

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<CompanyHomeModel> homeData = Rxn<CompanyHomeModel>();

  @override
  void onInit() {
    super.onInit();
    fetchCompanyHome();
  }

  Future<void> fetchCompanyHome() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _homeService.getCompanyHome();
      homeData.value = result;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onCreateTaskPressed() async {
    final shouldRefresh = await Get.toNamed(
      Routes.createCompanyTask,
    );

    if (shouldRefresh == true) {
      await fetchCompanyHome();
    }
  }

  Future<void> onRequiredActionPressed(CompanyRequiredAction action) async {
    switch (action.targetType) {
      case 'task_application':
        await _openApplicantDetails(
          applicationId: action.targetId,
        );
        break;

      case 'task_applications':
        await _openTaskApplicants(
          taskId: action.targetId,
        );
        break;

      case 'task':
        await _openTaskDetails(
          taskId: action.targetId,
        );
        break;

      default:
        _showUnsupportedAction();
    }
  }

  Future<void> onRecentActivityPressed(CompanyRecentActivity activity) async {
    switch (activity.targetType) {
      case 'task_applications':
        await _openTaskApplicants(
          taskId: activity.targetId,
        );
        break;

      case 'task_application':
        await _openApplicantDetails(
          applicationId: activity.targetId,
        );
        break;

      case 'task':
        await _openTaskDetails(
          taskId: activity.targetId,
        );
        break;

      default:
        _showUnsupportedAction();
    }
  }

  Future<void> _openApplicantDetails({
    required int applicationId,
  }) async {
    if (applicationId == 0) {
      Get.snackbar(
        'تنبيه',
        'رقم طلب التقديم غير صالح',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await Get.toNamed(
      Routes.companyTaskApplicantDetails,
      arguments: {
        'applicationId': applicationId,
        'taskId': 0,
        'taskTitle': 'المهمة',
        'studentName': 'الطالب',
      },
    );

    await fetchCompanyHome();
  }

  Future<void> _openTaskApplicants({
    required int taskId,
  }) async {
    if (taskId == 0) {
      Get.snackbar(
        'تنبيه',
        'رقم المهمة غير صالح',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await Get.toNamed(
      Routes.companyTaskApplicants,
      arguments: {
        'taskId': taskId,
        'taskTitle': 'المهمة رقم $taskId',
      },
    );

    await fetchCompanyHome();
  }

  Future<void> _openTaskDetails({
    required int taskId,
  }) async {
    if (taskId == 0) {
      Get.snackbar(
        'تنبيه',
        'رقم المهمة غير صالح',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await Get.toNamed(
      Routes.companyTaskDetails,
      arguments: {
        'taskId': taskId,
      },
    );

    await fetchCompanyHome();
  }

  void _showUnsupportedAction() {
    Get.snackbar(
      'تنبيه',
      'نوع الإجراء غير مدعوم حاليًا',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String resolveActionButtonLabel({
    required String targetType,
    required String fallbackLabel,
  }) {
    switch (targetType) {
      case 'task_application':
        return 'مراجعة الطلب';
      case 'task_applications':
        return 'عرض الطلبات';
      case 'task':
        return 'عرض المهمة';
      case 'submission':
        return 'مراجعة التسليم';
      case 'conversation':
        return 'فتح المحادثة';
      default:
        return fallbackLabel.trim().isNotEmpty ? fallbackLabel : 'عرض التفاصيل';
    }
  }
}