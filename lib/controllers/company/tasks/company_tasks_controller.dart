import 'package:get/get.dart';
import 'package:jisr_platform/models/company/tasks/company_task_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/company/tasks/company_task_service.dart';

enum CompanyTaskStatusFilter {
  all,
  draft,
  published,
  inProgress,
  closed,
  cancelled,
}

extension CompanyTaskStatusFilterExtension on CompanyTaskStatusFilter {
  String? get apiValue {
    switch (this) {
      case CompanyTaskStatusFilter.all:
        return null;
      case CompanyTaskStatusFilter.draft:
        return 'draft';
      case CompanyTaskStatusFilter.published:
        return 'published';
      case CompanyTaskStatusFilter.inProgress:
        return 'in_progress';
      case CompanyTaskStatusFilter.closed:
        return 'closed';
      case CompanyTaskStatusFilter.cancelled:
        return 'cancelled';
    }
  }

  String get label {
    switch (this) {
      case CompanyTaskStatusFilter.all:
        return 'الكل';
      case CompanyTaskStatusFilter.draft:
        return 'مسودات';
      case CompanyTaskStatusFilter.published:
        return 'منشورة';
      case CompanyTaskStatusFilter.inProgress:
        return 'قيد التنفيذ';
      case CompanyTaskStatusFilter.closed:
        return 'مغلقة';
      case CompanyTaskStatusFilter.cancelled:
        return 'ملغاة';
    }
  }

  String get sectionTitle {
    switch (this) {
      case CompanyTaskStatusFilter.all:
        return 'كل المهام';
      case CompanyTaskStatusFilter.draft:
        return 'المهام المسودة';
      case CompanyTaskStatusFilter.published:
        return 'المهام المنشورة';
      case CompanyTaskStatusFilter.inProgress:
        return 'المهام قيد التنفيذ';
      case CompanyTaskStatusFilter.closed:
        return 'المهام المغلقة';
      case CompanyTaskStatusFilter.cancelled:
        return 'المهام الملغاة';
    }
  }
}

class CompanyTasksController extends GetxController {
  final CompanyTaskService _taskService;

  CompanyTasksController(this._taskService);

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<CompanyTaskModel> tasks =
      <CompanyTaskModel>[].obs;

  final Rx<CompanyTaskStatusFilter> selectedStatusFilter =
      CompanyTaskStatusFilter.all.obs;

  int _fetchSequence = 0;

  String get tasksSectionTitle {
    return selectedStatusFilter.value.sectionTitle;
  }

  bool get isShowingAllTasks {
    return selectedStatusFilter.value == CompanyTaskStatusFilter.all;
  }

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final currentRequest = ++_fetchSequence;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _taskService.getCompanyTasks(
        status: selectedStatusFilter.value.apiValue,
      );

      if (currentRequest != _fetchSequence) {
        return;
      }

      tasks.assignAll(result);
    } catch (e) {
      if (currentRequest != _fetchSequence) {
        return;
      }

      errorMessage.value =
          e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (currentRequest == _fetchSequence) {
        isLoading.value = false;
      }
    }
  }

  Future<void> selectStatusFilter(
    CompanyTaskStatusFilter filter,
  ) async {
    if (selectedStatusFilter.value == filter) {
      return;
    }

    selectedStatusFilter.value = filter;
    await fetchTasks();
  }

  Future<void> goToCreateTask() async {
    final shouldRefresh = await Get.toNamed(
      Routes.createCompanyTask,
    );

    if (shouldRefresh == true) {
      await fetchTasks();
    }
  }

  Future<void> goToTaskDetails(int taskId) async {
    final shouldRefresh = await Get.toNamed(
      Routes.companyTaskDetails,
      arguments: {
        'taskId': taskId,
      },
    );

    if (shouldRefresh == true) {
      await fetchTasks();
    }
  }

  void goToTaskAssignments() {
    Get.toNamed(Routes.companyTaskAssignments);
  }

  String statusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'مسودة';
      case 'published':
        return 'منشورة';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'closed':
        return 'مغلقة';
      case 'cancelled':
        return 'ملغاة';
      default:
        return status;
    }
  }

  String difficultyLabel(String level) {
    switch (level) {
      case 'beginner':
        return 'مبتدئ';
      case 'intermediate':
        return 'متوسط';
      case 'advanced':
        return 'متقدم';
      default:
        return level;
    }
  }
}