import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/tasks/student_task_model.dart';
import 'package:jisr_platform/services/student/tasks/student_task_service.dart';

class StudentTaskController extends GetxController {
  final StudentTaskService _service = StudentTaskService();

  final searchController = TextEditingController();

  final RxBool isLoadingRecommended = false.obs;
  final RxBool isLoadingExplore = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isLoadingDetails = false.obs;

  final RxList<StudentTaskModel> exploreTasks = <StudentTaskModel>[].obs;
  final RxList<StudentTaskModel> recommendedTasks = <StudentTaskModel>[].obs;
  final Rxn<StudentTaskDetailsModel> selectedTask =
      Rxn<StudentTaskDetailsModel>();
  final applyMessageController = TextEditingController();
  final portfolioUrlController = TextEditingController();
  final githubUrlController = TextEditingController();

  final RxBool isApplying = false.obs;
  Timer? _searchTimer;

  bool get isLoading => isLoadingRecommended.value && isLoadingExplore.value;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchInitialTasks() async {
    fetchRecommendedTasks();
    fetchExploreTasks();
  }

  Future<void> fetchRecommendedTasks() async {
    try {
      isLoadingRecommended.value = true;

      final response = await _service.recommendedTasks();
      recommendedTasks.assignAll(response.data);
    } catch (e) {
      recommendedTasks.clear();
      debugPrint('RECOMMENDED TASKS ERROR: $e');
    } finally {
      isLoadingRecommended.value = false;
    }
  }

  Future<void> fetchExploreTasks({String? title}) async {
    try {
      isLoadingExplore.value = title == null || title.trim().isEmpty;
      isSearching.value = title != null && title.trim().isNotEmpty;

      final response = await _service.exploreTasks(title: title);
      exploreTasks.assignAll(response.data);
    } catch (e) {
      exploreTasks.clear();
      debugPrint('EXPLORE TASKS ERROR: $e');
    } finally {
      isLoadingExplore.value = false;
      isSearching.value = false;
    }
  }

  void onSearchChanged(String value) {
    _searchTimer?.cancel();

    _searchTimer = Timer(const Duration(milliseconds: 450), () {
      fetchExploreTasks(title: value);
    });
  }

  Future<void> refreshTasks() async {
    searchController.clear();
    await Future.wait([fetchRecommendedTasks(), fetchExploreTasks()]);
  }

  void prepareApplyForm() {
    applyMessageController.clear();
    portfolioUrlController.clear();
    githubUrlController.clear();
  }

  bool _isValidUrl(String value) {
    final trimmed = value.trim();
    return trimmed.startsWith('http://') || trimmed.startsWith('https://');
  }

  Future<void> applyToTask(int taskId) async {
    final message = applyMessageController.text.trim();
    final portfolioUrl = portfolioUrlController.text.trim();
    final githubUrl = githubUrlController.text.trim();

    if (message.isEmpty || portfolioUrl.isEmpty || githubUrl.isEmpty) {
      JisrSnackbar.show(
        title: 'حقول ناقصة',
        message: 'رسالة التقديم ورابط البورتفوليو ورابط GitHub مطلوبة',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    if (!_isValidUrl(portfolioUrl)) {
      JisrSnackbar.show(
        title: 'رابط البورتفوليو غير صحيح',
        message: 'يجب أن يبدأ الرابط بـ https:// أو http://',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    if (!_isValidUrl(githubUrl)) {
      JisrSnackbar.show(
        title: 'رابط GitHub غير صحيح',
        message: 'يجب أن يبدأ الرابط بـ https:// أو http://',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    try {
      isApplying.value = true;

      final messageResponse = await _service.applyToTask(
        taskId: taskId,
        message: message,
        portfolioUrl: portfolioUrl,
        githubUrl: githubUrl,
      );

      Get.back();

      JisrSnackbar.show(
        title: 'تم التقديم',
        message: messageResponse,
        type: JisrSnackbarType.success,
      );
    } catch (e) {
      JisrSnackbar.show(
        title: 'فشل التقديم',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    } finally {
      isApplying.value = false;
    }
  }

  Future<void> fetchTaskDetails(int taskId) async {
    try {
      isLoadingDetails.value = true;
      selectedTask.value = null;

      final response = await _service.taskDetails(taskId);
      selectedTask.value = response.data;
    } catch (e) {
      JisrSnackbar.show(
        title: 'خطأ',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    } finally {
      isLoadingDetails.value = false;
    }
  }

  String dateOnly(String? value) {
    if (value == null || value.isEmpty) return 'غير محدد';
    return value.split('T').first;
  }

  String deadlineText(String? value) {
    if (value == null || value.isEmpty) return 'غير محدد';

    final deadline = DateTime.tryParse(value);
    if (deadline == null) return dateOnly(value);

    final days = deadline.difference(DateTime.now()).inDays;

    if (days < 0) return 'منتهي';
    if (days == 0) return 'ينتهي اليوم';
    if (days == 1) return 'باقي يوم واحد';
    return 'باقي $days يوم';
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    searchController.dispose();
    applyMessageController.dispose();
    portfolioUrlController.dispose();
    githubUrlController.dispose();
    super.onClose();
  }
}
