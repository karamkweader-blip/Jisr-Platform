import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/task_applications/student_task_application_model.dart';
import 'package:jisr_platform/services/student/task_applications/student_task_application_service.dart';

enum TaskApplicationTab { all, applied, accepted, rejected }

class StudentTaskApplicationController extends GetxController {
  final StudentTaskApplicationService _service =
      StudentTaskApplicationService();

  final RxBool isLoading = false.obs;
  // التاب النشط حالياً (يتحكم بالفلترة من خلال كروت الإحصائيات)
  final Rx<TaskApplicationTab> selectedTab = TaskApplicationTab.all.obs;

  final RxList<StudentTaskApplicationModel> allTasks =
      <StudentTaskApplicationModel>[].obs;
  final RxList<StudentTaskApplicationModel> appliedTasks =
      <StudentTaskApplicationModel>[].obs;
  final RxList<StudentTaskApplicationModel> acceptedTasks =
      <StudentTaskApplicationModel>[].obs;
  final RxList<StudentTaskApplicationModel> rejectedTasks =
      <StudentTaskApplicationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // تركناها فارغة تماماً لحماية التطبيق من التعليق أثناء فتح الصفحة
  }

  @override
  void onReady() {
    super.onReady();
    // أفضل مكان لاستدعاء البيانات فور جاهزية الواجهة وبدون أي تجميد للشاشة
    fetchAllMyTasks();
  }

  // جلب القائمة الحالية بناءً على النوع المختار من لوحة الإحصائيات
  List<StudentTaskApplicationModel> get currentTasks {
    switch (selectedTab.value) {
      case TaskApplicationTab.all:
        return allTasks;
      case TaskApplicationTab.applied:
        return appliedTasks;
      case TaskApplicationTab.accepted:
        return acceptedTasks;
      case TaskApplicationTab.rejected:
        return rejectedTasks;
    }
  }

  // جلب كل البيانات من السيرفر وتوزيعها على المصفوفات
  Future<void> fetchAllMyTasks() async {
    try {
      isLoading.value = true;
      final response = await _service.getAllMyTasks();

      allTasks.assignAll(response.all);
      appliedTasks.assignAll(response.applied);
      acceptedTasks.assignAll(response.accepted);
      rejectedTasks.assignAll(response.rejected);
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // تحديث البيانات عند السحب للأسفل (Pull to Refresh)
  Future<void> refreshCurrentData() async {
    await fetchAllMyTasks();
  }

  // تغيير الفلتر النشط بسلاسة وبدون Rebuild لانهائي
  void selectFilter(TaskApplicationTab tab) {
    selectedTab.value = tab;
  }

  void _showError(Object e) {
    JisrSnackbar.show(
      title: 'خطأ',
      message: e.toString().replaceFirst('Exception: ', ''),
      type: JisrSnackbarType.error,
    );
  }

  String get currentTabTitle {
    switch (selectedTab.value) {
      case TaskApplicationTab.all:
        return 'كل التاسكات المتوفرة';
      case TaskApplicationTab.applied:
        return 'التاسكات المقدّم عليها';
      case TaskApplicationTab.accepted:
        return 'التاسكات المقبولة';
      case TaskApplicationTab.rejected:
        return 'التاسكات المرفوضة';
    }
  }

  String statusText(String status) {
    switch (status) {
      case 'pending':
        return 'بانتظار المراجعة';
      case 'accepted':
        return 'مقبولة';
      case 'working':
        return 'قيد العمل';
      case 'rejected':
        return 'مرفوضة';
      default:
        return status.isEmpty ? 'غير محدد' : status;
    }
  }

  String dateOnly(String? value) {
    if (value == null || value.isEmpty) return 'غير محدد';
    return value.split('T').first;
  }

  String companyName(StudentTaskApplicationModel item) {
    final company = item.task.company;
    if (company.name.isNotEmpty && company.name != 'شركة غير محددة') {
      return company.name;
    }
    return company.industry.isEmpty ? 'شركة غير محددة' : company.industry;
  }
}
