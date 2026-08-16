import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/assigned_tasks/student_assigned_task_model.dart';
import 'package:jisr_platform/services/student/assigned_tasks/student_assigned_task_service.dart';

class StudentAssignedTaskController extends GetxController {
  final StudentAssignedTaskService _service = StudentAssignedTaskService();

  final RxBool isLoading = false.obs;
  final RxBool isStarting = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isSubmittingAppeal = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isLoadingAppeals = false.obs;
  final RxBool isLoadingMoreAppeals = false.obs;
  final RxBool hasLoadedAppeals = false.obs;

  final RxList<StudentAssignedTaskModel> tasks =
      <StudentAssignedTaskModel>[].obs;
  final RxMap<int, StudentProjectEvaluationResponse> evaluations =
      <int, StudentProjectEvaluationResponse>{}.obs;
  final RxSet<int> loadingEvaluationIds = <int>{}.obs;
  final RxMap<int, String> evaluationErrors = <int, String>{}.obs;
  final RxList<ProjectEvaluationAppealModel> myAppeals =
      <ProjectEvaluationAppealModel>[].obs;

  final TextEditingController appealReasonController = TextEditingController();
  final RxString appealReasonError = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalTasks = 0.obs;
  final RxString appealStatusFilter = 'all'.obs;
  final RxInt appealsCurrentPage = 1.obs;
  final RxInt appealsLastPage = 1.obs;
  final RxInt appealsTotal = 0.obs;

  static const int _perPage = 15;

  bool get hasMoreTasks => currentPage.value < lastPage.value;
  bool get hasMoreAppeals =>
      appealsCurrentPage.value < appealsLastPage.value;

  @override
  void onInit() {
    super.onInit();
    fetchAssignedTasks();
  }

  Future<void> fetchAssignedTasks({bool loadMore = false}) async {
    if (loadMore && (isLoadingMore.value || !hasMoreTasks)) return;

    try {
      if (loadMore) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }

      final page = loadMore ? currentPage.value + 1 : 1;
      final response = await _service.getAssignedTasks(
        page: page,
        perPage: _perPage,
      );

      if (loadMore) {
        final existingIds = tasks.map((item) => item.id).toSet();
        tasks.addAll(
          response.tasks.where((item) => !existingIds.contains(item.id)),
        );
      } else {
        tasks.assignAll(response.tasks);
      }

      currentPage.value = response.pagination.currentPage;
      lastPage.value = response.pagination.lastPage;
      totalTasks.value = response.pagination.total;

      final assignmentIds = tasks
          .map((item) => item.projectAssignmentId)
          .where((id) => id > 0)
          .toSet();
      evaluations.removeWhere((id, _) => !assignmentIds.contains(id));
      evaluationErrors.removeWhere((id, _) => !assignmentIds.contains(id));
    } catch (e) {
      JisrSnackbar.show(
        title: loadMore ? 'تعذر تحميل المزيد' : 'تعذر تحميل المهام',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    } finally {
      if (loadMore) {
        isLoadingMore.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  Future<void> fetchMyAppeals({
    bool loadMore = false,
    int? projectAssignmentId,
  }) async {
    if (loadMore &&
        (isLoadingMoreAppeals.value || !hasMoreAppeals)) {
      return;
    }

    try {
      if (loadMore) {
        isLoadingMoreAppeals.value = true;
      } else {
        isLoadingAppeals.value = true;
      }

      final page = loadMore ? appealsCurrentPage.value + 1 : 1;
      final selectedStatus = appealStatusFilter.value;
      final response = await _service.getEvaluationAppeals(
        status: selectedStatus == 'all' ? null : selectedStatus,
        projectAssignmentId: projectAssignmentId,
        page: page,
        perPage: _perPage,
      );

      if (selectedStatus != appealStatusFilter.value) return;

      if (loadMore) {
        final existingIds = myAppeals.map((appeal) => appeal.id).toSet();
        myAppeals.addAll(
          response.appeals.where(
            (appeal) => !existingIds.contains(appeal.id),
          ),
        );
      } else {
        myAppeals.assignAll(response.appeals);
      }

      appealsCurrentPage.value = response.pagination.currentPage;
      appealsLastPage.value = response.pagination.lastPage;
      appealsTotal.value = response.pagination.total;
      hasLoadedAppeals.value = true;
    } catch (e) {
      JisrSnackbar.show(
        title: loadMore ? 'تعذر تحميل المزيد' : 'تعذر تحميل الاعتراضات',
        message: _cleanError(e),
        type: JisrSnackbarType.error,
      );
    } finally {
      if (loadMore) {
        isLoadingMoreAppeals.value = false;
      } else {
        isLoadingAppeals.value = false;
      }
    }
  }

  Future<void> selectAppealStatus(String status) async {
    if (appealStatusFilter.value == status && hasLoadedAppeals.value) return;
    appealStatusFilter.value = status;
    myAppeals.clear();
    hasLoadedAppeals.value = false;
    appealsCurrentPage.value = 1;
    appealsLastPage.value = 1;
    await fetchMyAppeals();
  }

  Future<void> loadProjectEvaluation(
    int projectAssignmentId, {
    bool showErrorSnackbar = true,
  }) async {
    if (projectAssignmentId <= 0 ||
        loadingEvaluationIds.contains(projectAssignmentId)) {
      return;
    }

    try {
      loadingEvaluationIds.add(projectAssignmentId);
      evaluationErrors.remove(projectAssignmentId);

      final response = await _service.getProjectEvaluation(
        projectAssignmentId,
      );
      evaluations[projectAssignmentId] = response;
    } catch (e) {
      final message = _cleanError(e);
      evaluationErrors[projectAssignmentId] = message;

      if (showErrorSnackbar) {
        JisrSnackbar.show(
          title: 'تعذر تحميل التقييم',
          message: message,
          type: JisrSnackbarType.error,
        );
      }
    } finally {
      loadingEvaluationIds.remove(projectAssignmentId);
    }
  }

  void prepareAppeal() {
    appealReasonController.clear();
    appealReasonError.value = '';
  }

  void onAppealReasonChanged(String value) {
    if (appealReasonError.value.isNotEmpty) {
      appealReasonError.value = _validateAppealReason(value) ?? '';
    }
  }

  Future<void> submitAppeal(int projectAssignmentId) async {
    if (isSubmittingAppeal.value) return;

    final reason = appealReasonController.text.trim();
    final validationMessage = _validateAppealReason(reason);
    if (validationMessage != null) {
      appealReasonError.value = validationMessage;
      return;
    }

    final response = evaluations[projectAssignmentId];
    final evaluation = response?.evaluation;

    if (response == null ||
        !response.hasEvaluation ||
        evaluation == null ||
        evaluation.id <= 0) {
      JisrSnackbar.show(
        title: 'تعذر إرسال الاعتراض',
        message: 'لم يرسل الخادم معرّف تقييم صالح لهذا المشروع',
        type: JisrSnackbarType.error,
      );
      return;
    }

    if (!response.canAppeal) {
      JisrSnackbar.show(
        title: 'الاعتراض غير متاح',
        message: 'حالة التقييم الحالية لا تسمح بتقديم اعتراض',
        type: JisrSnackbarType.warning,
      );
      await loadProjectEvaluation(projectAssignmentId);
      return;
    }

    try {
      isSubmittingAppeal.value = true;

      await _service.submitProjectEvaluationAppeal(
        evaluationId: evaluation.id,
        reason: reason,
      );

      Get.back();
      prepareAppeal();

      JisrSnackbar.show(
        title: 'تم إرسال الاعتراض',
        message: 'تم إرسال الاعتراض بنجاح وهو الآن قيد المراجعة.',
        type: JisrSnackbarType.success,
      );

      await loadProjectEvaluation(
        projectAssignmentId,
        showErrorSnackbar: false,
      );

      if (hasLoadedAppeals.value) {
        await fetchMyAppeals();
      }
    } on StudentAssignedTaskApiException catch (e) {
      final title = e.statusCode == 403
          ? 'غير مصرح بتقديم الاعتراض'
          : e.statusCode == 422
          ? 'تعذر تقديم الاعتراض'
          : 'فشل إرسال الاعتراض';
      JisrSnackbar.show(
        title: title,
        message: e.message,
        type: JisrSnackbarType.error,
      );

      if (e.statusCode == 422) {
        await loadProjectEvaluation(
          projectAssignmentId,
          showErrorSnackbar: false,
        );
      }
    } catch (e) {
      JisrSnackbar.show(
        title: 'فشل إرسال الاعتراض',
        message: _cleanError(e),
        type: JisrSnackbarType.error,
      );
    } finally {
      isSubmittingAppeal.value = false;
    }
  }

  String? _validateAppealReason(String value) {
    final length = value.trim().length;
    if (length < 10) return 'يجب ألا يقل سبب الاعتراض عن 10 أحرف';
    if (length > 3000) return 'يجب ألا يزيد سبب الاعتراض عن 3000 حرف';
    return null;
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
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
      final currentTask = tasks[index];
      tasks[index] = currentTask.copyWith(
        status: updatedTask.status,
        startedAt: updatedTask.startedAt,
        submittedAt: updatedTask.submittedAt,
        completedAt: updatedTask.completedAt,
      );
      tasks.refresh();
    }
  }

  String statusText(String status) {
    switch (status) {
      case 'todo':
      case 'assigned':
        return 'لم يبدأ';
      case 'in_progress':
        return 'قيد العمل';
      case 'submitted':
        return 'تم الرفع';
      case 'under_review':
        return 'قيد المراجعة';
      case 'revision_requested':
        return 'مطلوب تعديل';
      case 'done':
      case 'completed':
        return 'مكتملة';
      default:
        return status.isEmpty ? 'غير محدد' : status;
    }
  }

  String projectStatusText(String status) {
    switch (status) {
      case 'assigned':
        return 'تم الإسناد';
      case 'in_progress':
      case 'working':
        return 'قيد العمل';
      case 'submitted':
        return 'تم التسليم';
      case 'under_review':
        return 'قيد المراجعة';
      case 'completed':
        return 'مكتمل';
      default:
        return status.isEmpty ? 'غير محدد' : status;
    }
  }

  String evaluationStatusText(String status) {
    switch (status) {
      case 'draft':
        return 'مسودة';
      case 'submitted':
        return 'تم اعتماد التقييم';
      case 'under_revision':
        return 'قيد المراجعة';
      case 'revised':
        return 'تم تعديل التقييم';
      default:
        return status.isEmpty ? 'غير محدد' : status;
    }
  }

  String appealStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد المراجعة';
      case 'accepted':
        return 'تم قبول الاعتراض';
      case 'rejected':
        return 'تم رفض الاعتراض';
      case 'cancelled':
        return 'تم إلغاء الاعتراض';
      default:
        return status.isEmpty ? 'غير محدد' : status;
    }
  }

  String dateOnly(String? value) {
    if (value == null || value.isEmpty) return 'غير محدد';
    return value.split('T').first;
  }

  String dateTimeText(String? value) {
    if (value == null || value.isEmpty) return 'غير محدد';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value.replaceFirst('T', ' ');

    final local = parsed.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }

  @override
  void onClose() {
    appealReasonController.dispose();
    super.onClose();
  }
}
