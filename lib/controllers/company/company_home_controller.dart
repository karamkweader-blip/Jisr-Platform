import 'package:get/get.dart';
import 'package:jisr_platform/models/company/company_home_model.dart';
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

  void onCreateTaskPressed() {
    // TODO: اربطها لاحقًا مع Route إنشاء مهمة جديدة.
    Get.snackbar(
      'إنشاء مهمة',
      'سيتم فتح صفحة إنشاء مهمة جديدة',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onRequiredActionPressed(CompanyRequiredAction action) {
    switch (action.targetType) {
      case 'task_application':
        // targetId هنا هو application id
        Get.snackbar(
          'مراجعة الطلب',
          'سيتم فتح طلب التقديم رقم ${action.targetId}',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;

      case 'task_applications':
        // targetId هنا هو task id
        Get.snackbar(
          'طلبات المهمة',
          'سيتم فتح طلبات المهمة رقم ${action.targetId}',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;

      default:
        Get.snackbar(
          'تنبيه',
          'نوع الإجراء غير مدعوم حاليًا',
          snackPosition: SnackPosition.BOTTOM,
        );
    }
  }

  void onRecentActivityPressed(CompanyRecentActivity activity) {
    switch (activity.targetType) {
      case 'task_applications':
        // targetId هنا هو task id
        Get.snackbar(
          'طلبات المهمة',
          'سيتم فتح طلبات المهمة رقم ${activity.targetId}',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;

      case 'task_application':
        // targetId هنا هو application id
        Get.snackbar(
          'تفاصيل الطلب',
          'سيتم فتح طلب التقديم رقم ${activity.targetId}',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;

      default:
        Get.snackbar(
          'تنبيه',
          'نوع النشاط غير مدعوم حاليًا',
          snackPosition: SnackPosition.BOTTOM,
        );
    }
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