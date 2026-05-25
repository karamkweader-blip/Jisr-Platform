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
    super.onClose();
  }
}
