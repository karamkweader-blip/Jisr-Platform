import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/models/company/tasks/company_task_application_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_details_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/company/tasks/company_task_details_service.dart';

class CompanyTaskDetailsController extends GetxController {
  final CompanyTaskDetailsService _detailsService;

  CompanyTaskDetailsController(this._detailsService);

  final RxBool isLoading = false.obs;
  final RxBool isPublishing = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool hasChanges = false.obs;

  final RxBool isApplicationsLoading = false.obs;
  final RxString applicationsErrorMessage = ''.obs;
  final RxList<CompanyTaskApplicationModel> applications =
      <CompanyTaskApplicationModel>[].obs;

  final RxString errorMessage = ''.obs;
  final Rxn<CompanyTaskDetailsModel> task = Rxn<CompanyTaskDetailsModel>();

  late final int taskId;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;

    taskId = int.tryParse(args?['taskId']?.toString() ?? '') ?? 0;

    if (taskId == 0) {
      errorMessage.value = 'رقم المهمة غير صالح';
      return;
    }

    fetchTaskDetails();
  }

  Future<void> fetchTaskDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      applicationsErrorMessage.value = '';

      final result = await _detailsService.getTaskDetails(taskId);
      task.value = result;

      if (!result.isDraft) {
        await fetchTaskApplications();
      } else {
        applications.clear();
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshTaskDetails() async {
    await fetchTaskDetails();
  }

  Future<void> fetchTaskApplications() async {
    try {
      isApplicationsLoading.value = true;
      applicationsErrorMessage.value = '';

      final result = await _detailsService.getTaskApplications(taskId);
      applications.assignAll(result);
    } catch (e) {
      applicationsErrorMessage.value =
          e.toString().replaceFirst('Exception: ', '');
    } finally {
      isApplicationsLoading.value = false;
    }
  }

  void closePage() {
    Get.back(result: hasChanges.value);
  }

  void handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        goToEditTask();
        break;
      case 'cancel':
  confirmCancelTask();
  break;
      case 'refresh':
        fetchTaskDetails();
        break;
    }
  }

  Future<void> goToEditTask() async {
    final currentTask = task.value;
    if (currentTask == null) return;

   if (!currentTask.canEdit) {
  Get.snackbar(
    'غير مسموح',
    'لا يمكن تعديل المهمة في حالتها الحالية',
    snackPosition: SnackPosition.BOTTOM,
  );
  return;
}

    final shouldRefresh = await Get.toNamed(
      Routes.createCompanyTask,
      arguments: {
        'mode': 'edit',
        'taskId': currentTask.id,
        'task': currentTask.toJson(),
      },
    );

    if (shouldRefresh == true) {
      hasChanges.value = true;
      await fetchTaskDetails();
    }
  }

  Future<void> confirmPublishTask() async {
    final currentTask = task.value;
    if (currentTask == null) return;

    if (!currentTask.isDraft) {
      Get.snackbar(
        'تنبيه',
        'هذه المهمة منشورة مسبقاً',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('نشر المهمة'),
        content: Text(
          'هل تريد نشر مهمة "${currentTask.title}"؟\nبعد النشر سيتمكن الطلاب المناسبون من التقديم عليها.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('نشر'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await publishTask();
    }
  }

  Future<void> publishTask() async {
    try {
      isPublishing.value = true;

      final updatedTask = await _detailsService.publishTask(taskId);

      task.value = updatedTask;
      hasChanges.value = true;

      await fetchTaskApplications();

      Get.snackbar(
        'تم النشر',
        'تم نشر المهمة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isPublishing.value = false;
    }
  }

Future<void> confirmCancelTask() async {
  final currentTask = task.value;

  if (currentTask == null) {
    return;
  }

  if (!currentTask.canCancel) {
    Get.snackbar(
      'غير مسموح',
      'لا يمكن إلغاء المهمة في حالتها الحالية',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('إلغاء المهمة'),
      content: Text(
        'هل تريد إلغاء مهمة "${currentTask.title}"؟\n'
        'ستتوقف المهمة عن استقبال المتقدمين وستصبح بحالة ملغاة.',
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('تراجع'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Get.back(result: true),
          child: const Text('تأكيد الإلغاء'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await cancelTask();
  }
}

Future<void> cancelTask() async {
  try {
    isDeleting.value = true;

    final cancelledTask = await _detailsService.cancelTask(taskId);

    task.value = cancelledTask;
    hasChanges.value = true;
    applications.clear();

    Get.snackbar(
      'تم الإلغاء',
      'تم إلغاء المهمة بنجاح',
      snackPosition: SnackPosition.BOTTOM,
    );
  } catch (e) {
    Get.snackbar(
      'تعذر الإلغاء',
      e.toString().replaceFirst('Exception: ', ''),
      snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isDeleting.value = false;
  }
}

  void goToApplicants() {
  final currentTask = task.value;
  if (currentTask == null) return;

  if (currentTask.isDraft) {
    Get.snackbar(
      'تنبيه',
      'يجب نشر المهمة أولاً حتى تتمكن من مراجعة المتقدمين',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  Get.toNamed(
    Routes.companyTaskApplicants,
    arguments: {
      'taskId': taskId,
      'taskTitle': currentTask.title,
    },
  );
}

  void goToApplicantDetails(CompanyTaskApplicationModel application) {
    Get.toNamed(
      Routes.companyTaskApplicantDetails,
      arguments: {
        'taskId': taskId,
        'applicationId': application.applicationId,
      },
    );
  }

  String statusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'مسودة';
      case 'published':
        return 'منشورة';
      case 'active':
        return 'نشطة';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتملة';
      case 'closed':
        return 'مغلقة';
      case 'cancelled':
        return 'ملغاة';
      default:
        return status;
    }
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

String submissionTypeLabel(String type) {
  switch (type) {
    case 'github_link':
      return 'رابط GitHub';
    case 'zip_file':
      return 'ملف ZIP';
    case 'demo_link':
      return 'رابط العرض التجريبي';
    case 'mixed':
      return 'تسليم مختلط';
    default:
      return type;
  }
}

  String formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';

    final local = date.toLocal();

    return '${local.year}/${_twoDigits(local.month)}/${_twoDigits(local.day)}';
  }

  String formatAppliedAt(DateTime? date) {
    if (date == null) return 'غير محدد';

    final local = date.toLocal();

    return '${local.year}/${_twoDigits(local.month)}/${_twoDigits(local.day)}';
  }

  String deadlineHint(DateTime? date) {
    if (date == null) return 'لا يوجد موعد نهائي';

    final now = DateTime.now();
    final local = date.toLocal();
    final difference = local.difference(now);

    if (difference.isNegative) {
      return 'انتهى الموعد';
    }

    if (difference.inDays == 0) {
      return 'ينتهي اليوم';
    }

    if (difference.inDays == 1) {
      return 'ينتهي غداً';
    }

    return 'ينتهي خلال ${difference.inDays} أيام';
  }

  int workflowIndex(String status) {
    switch (status) {
      case 'draft':
        return 0;
      case 'published':
        return 1;
      case 'active':
        return 2;
      case 'in_progress':
        return 4;
      case 'completed':
        return 6;
      case 'closed':
        return 6;
      default:
        return 0;
    }
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}