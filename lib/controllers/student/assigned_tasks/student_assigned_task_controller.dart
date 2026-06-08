import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/assigned_tasks/student_assigned_task_model.dart';
import 'package:jisr_platform/services/student/assigned_tasks/student_assigned_task_service.dart';

class StudentAssignedTaskController extends GetxController {
  final StudentAssignedTaskService _service = StudentAssignedTaskService();

  final RxBool isLoading = false.obs;
  final RxBool isStarting = false.obs;
  final RxBool isSubmitting = false.obs;

  final RxList<StudentAssignedTaskModel> tasks =
      <StudentAssignedTaskModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAssignedTasks();
  }

  Future<void> fetchAssignedTasks() async {
    try {
      isLoading.value = true;

      final response = await _service.getAssignedTasks();
      tasks.assignAll(response);
    } catch (e) {
      JisrSnackbar.show(
        title: 'خطأ',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startTask(StudentAssignedTaskModel task) async {
    try {
      isStarting.value = true;

      final updatedTask = await _service.startTask(task.id);
      _updateTaskInList(updatedTask);

      JisrSnackbar.show(
        title: 'تم البدء',
        message: 'تم تغيير حالة المهمة إلى قيد العمل',
        type: JisrSnackbarType.success,
      );
    } catch (e) {
      JisrSnackbar.show(
        title: 'فشل بدء المهمة',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    } finally {
      isStarting.value = false;
    }
  }

  Future<void> submitTask(StudentAssignedTaskModel task) async {
    try {
      isSubmitting.value = true;

      final updatedTask = await _service.submitTask(task.id);
      _updateTaskInList(updatedTask);

      JisrSnackbar.show(
        title: 'تم التسليم',
        message: 'تم رفع المهمة بنجاح',
        type: JisrSnackbarType.success,
      );
    } catch (e) {
      JisrSnackbar.show(
        title: 'فشل تسليم المهمة',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _updateTaskInList(StudentAssignedTaskModel updatedTask) {
    final index = tasks.indexWhere((item) => item.id == updatedTask.id);

    if (index != -1) {
      tasks[index] = updatedTask;
      tasks.refresh();
    }
  }

  String statusText(String status) {
    switch (status) {
      case 'assigned':
        return 'لم يبدأ';
      case 'in_progress':
        return 'قيد العمل';
      case 'submitted':
        return 'تم الرفع';
      case 'completed':
        return 'مكتملة';
      default:
        return status.isEmpty ? 'غير محدد' : status;
    }
  }

  String dateOnly(String? value) {
    if (value == null || value.isEmpty) return 'غير محدد';
    return value.split('T').first;
  }
}
