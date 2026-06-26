import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/task_progress/student_task_progress_model.dart';
import 'package:jisr_platform/services/student/task_progress/student_task_progress_service.dart';

class StudentTaskProgressController extends GetxController {
  final StudentTaskProgressService _service = StudentTaskProgressService();

  final RxBool isLoading = false.obs;
  final RxBool isAddingProgress = false.obs;
  final RxBool isSubmittingFinal = false.obs;

  final Rxn<TaskAssignmentInfo> assignment = Rxn<TaskAssignmentInfo>();
  final RxList<TaskProgressUpdateModel> progressUpdates =
      <TaskProgressUpdateModel>[].obs;

  late final int assignmentId;

  final TextEditingController progressTitleController = TextEditingController();
  final TextEditingController progressDescriptionController =
      TextEditingController();
  final TextEditingController progressGithubController =
      TextEditingController();
  final TextEditingController progressDemoController = TextEditingController();

  final TextEditingController finalGithubController = TextEditingController();
  final TextEditingController finalDemoController = TextEditingController();
  final TextEditingController finalNotesController = TextEditingController();

  final RxDouble progressPercentage = 40.0.obs;

  final RxList<File> progressAttachments = <File>[].obs;
  final RxList<File> finalAttachments = <File>[].obs;

  @override
  void onInit() {
    super.onInit();

    assignmentId = Get.arguments as int;

    fetchProgress();
  }

  Future<void> fetchProgress() async {
    try {
      isLoading.value = true;

      final response = await _service.getProgress(assignmentId);

      assignment.value = response.data.assignment;
      progressUpdates.assignAll(response.data.progressUpdates);
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

  Future<void> pickProgressAttachments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result == null) return;

    final files = result.paths
        .whereType<String>()
        .map((path) => File(path))
        .toList();

    progressAttachments.assignAll(files);
  }

  Future<void> pickFinalAttachments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['zip', 'rar', '7z'],
    );

    if (result == null) return;

    final path = result.files.single.path;
    if (path == null) return;

    final file = File(path);
    final fileSize = await file.length();

    const maxSizeInBytes = 40 * 1024 * 1024;

    if (fileSize > maxSizeInBytes) {
      JisrSnackbar.show(
        title: 'الملف كبير جداً',
        message:
            'حجم الملف يجب أن يكون أقل من 40MB. حجم ملفك الحالي تقريباً ${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    finalAttachments.assignAll([file]);
  }

  void clearProgressForm() {
    progressTitleController.clear();
    progressDescriptionController.clear();
    progressGithubController.clear();
    progressDemoController.clear();
    progressPercentage.value = latestPercentage().toDouble();
    progressAttachments.clear();
  }

  void clearFinalForm() {
    finalGithubController.clear();
    finalDemoController.clear();
    finalNotesController.clear();
    finalAttachments.clear();
  }

  int latestPercentage() {
    if (progressUpdates.isEmpty) return 0;

    final percentages = progressUpdates
        .map((item) => item.progress.percentage)
        .where((value) => value >= 0 && value <= 100)
        .toList();

    if (percentages.isEmpty) return 0;

    percentages.sort();
    return percentages.last;
  }

  Future<void> addProgressUpdate() async {
    final title = progressTitleController.text.trim();
    final description = progressDescriptionController.text.trim();
    final githubUrl = progressGithubController.text.trim();
    final demoUrl = progressDemoController.text.trim();
    final percentage = progressPercentage.value.round();

    if (title.isEmpty || description.isEmpty) {
      JisrSnackbar.show(
        title: 'حقول ناقصة',
        message: 'العنوان والوصف مطلوبان لإضافة تحديث التقدم',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    if (percentage < 0 || percentage > 100) {
      JisrSnackbar.show(
        title: 'نسبة غير صحيحة',
        message: 'النسبة يجب أن تكون بين 0 و 100',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    try {
      isAddingProgress.value = true;

      final response = await _service.addProgressUpdate(
        assignmentId: assignmentId,
        title: title,
        description: description,
        percentage: percentage,
        githubUrl: githubUrl,
        demoUrl: demoUrl,
        attachments: progressAttachments,
      );

      progressUpdates.insert(0, response.data);

      Get.back();

      clearProgressForm();

      JisrSnackbar.show(
        title: 'تمت الإضافة',
        message: response.message,
        type: JisrSnackbarType.success,
      );
    } catch (e) {
      JisrSnackbar.show(
        title: 'فشل الإضافة',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    } finally {
      isAddingProgress.value = false;
    }
  }

  Future<void> submitFinalTask() async {
    final notes = finalNotesController.text.trim();
    final githubUrl = finalGithubController.text.trim();
    final demoUrl = finalDemoController.text.trim();

    final hasGithub = githubUrl.isNotEmpty;
    final hasDemo = demoUrl.isNotEmpty;
    final hasFiles = finalAttachments.isNotEmpty;

    if (notes.isEmpty) {
      JisrSnackbar.show(
        title: 'التسليم ناقص',
        message: 'ملاحظات التسليم مطلوبة',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    if (!hasGithub && !hasDemo && !hasFiles) {
      JisrSnackbar.show(
        title: 'التسليم ناقص',
        message: 'أضيفي رابط GitHub أو Demo أو ملف واحد على الأقل',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    try {
      isSubmittingFinal.value = true;

      final response = await _service.submitFinalTask(
        assignmentId: assignmentId,
        notes: notes,
        githubUrl: githubUrl,
        demoUrl: demoUrl,
        attachments: finalAttachments,
      );

      Get.back();

      clearFinalForm();

      await fetchProgress();

      JisrSnackbar.show(
        title: 'تم التسليم',
        message: response['message']?.toString() ?? 'تم إرسال التسليم النهائي',
        type: JisrSnackbarType.success,
      );
    } catch (e) {
      JisrSnackbar.show(
        title: 'فشل التسليم النهائي',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    } finally {
      isSubmittingFinal.value = false;
    }
  }

  String dateOnly(String? value) {
    if (value == null || value.isEmpty) return 'غير محدد';

    final parts = value.split('T');

    if (parts.isEmpty) return value;

    return parts.first;
  }

  String timeOnly(String? value) {
    if (value == null || value.isEmpty) return '';

    final parts = value.split('T');

    if (parts.length < 2) return '';

    final timePart = parts[1];

    if (timePart.length < 5) return timePart;

    return timePart.substring(0, 5);
  }

  String fileName(File file) {
    return file.path.split('/').last.split('\\').last;
  }

  @override
  void onClose() {
    progressTitleController.dispose();
    progressDescriptionController.dispose();
    progressGithubController.dispose();
    progressDemoController.dispose();
    finalGithubController.dispose();
    finalDemoController.dispose();
    finalNotesController.dispose();
    super.onClose();
  }
}
