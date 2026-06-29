import 'package:get/get.dart';
import 'package:jisr_platform/models/company/tasks/company_task_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/company/tasks/company_task_service.dart';

class CompanyTasksController extends GetxController {
  final CompanyTaskService _taskService;

  CompanyTasksController(this._taskService);

  final RxBool isLoading = false.obs;
  // final RxBool isPublishing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<CompanyTaskModel> tasks = <CompanyTaskModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _taskService.getCompanyTasks();
      tasks.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> goToCreateTask() async {
   final shouldRefresh = await Get.toNamed(
      Routes.createCompanyTask,);

    if (shouldRefresh == true) {
      fetchTasks();
    }
  }

  Future<void> goToTaskDetails(int taskId) async {
  final shouldRefresh = await Get.toNamed(
    Routes.companyTaskDetails,
    arguments: {'taskId': taskId},
  );

  if (shouldRefresh == true) {
    fetchTasks();
  }
}

void goToTaskAssignments() {
  Get.toNamed(Routes.companyTaskAssignments);
}

  // Future<void> confirmPublishTask(CompanyTaskModel task) async {
  //   final confirmed = await Get.dialog<bool>(
  //     AlertDialog(
  //       title: const Text('نشر المهمة'),
  //       content: Text(
  //         'هل تريد نشر مهمة "${task.title}"؟\nبعد النشر سيتمكن الطلاب المناسبون من التقديم عليها.',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Get.back(result: false),
  //           child: const Text('إلغاء'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () => Get.back(result: true),
  //           child: const Text('نشر'),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (confirmed == true) {
  //     await publishTask(task.id);
  //   }
  // }

  // Future<void> publishTask(int taskId) async {
  //   try {
  //     isPublishing.value = true;

  //     await _taskService.publishTask(taskId);
  //     await fetchTasks();

  //     Get.snackbar(
  //       'تم النشر',
  //       'تم نشر المهمة بنجاح',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   } catch (e) {
  //     Get.snackbar(
  //       'خطأ',
  //       e.toString().replaceFirst('Exception: ', ''),
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   } finally {
  //     isPublishing.value = false;
  //   }
  // }

  String statusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'مسودة';
      case 'published':
        return 'منشورة';
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