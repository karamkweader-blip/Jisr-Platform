import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/models/company/company_task_model.dart';
import 'package:jisr_platform/services/company/company_task_service.dart';

class CreateCompanyTaskController extends GetxController {
  final CompanyTaskService _taskService;

  CreateCompanyTaskController(this._taskService);

  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final durationDaysController = TextEditingController();
  final maxApplicantsController = TextEditingController();
  final maxAcceptedStudentsController = TextEditingController();

  final RxString difficultyLevel = 'intermediate'.obs;
  final RxString submissionType = 'github_link'.obs;
  final Rxn<DateTime> deadline = Rxn<DateTime>();

  final RxList<String> deliverables = <String>[].obs;
  final RxList<String> acceptanceCriteria = <String>[].obs;

  final RxList<AvailableSkillModel> availableSkills = <AvailableSkillModel>[].obs;
  final RxList<SelectedTaskSkill> selectedSkills = <SelectedTaskSkill>[].obs;

  final RxnInt selectedSkillId = RxnInt();
  final RxInt selectedRequiredLevel = 3.obs;
  final RxBool selectedMandatory = true.obs;

  final RxBool isLoadingSkills = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString skillsError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSkills();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    durationDaysController.dispose();
    maxApplicantsController.dispose();
    maxAcceptedStudentsController.dispose();
    super.onClose();
  }

  Future<void> fetchSkills() async {
    try {
      isLoadingSkills.value = true;
      skillsError.value = '';

      final result = await _taskService.getAvailableSkills();
      availableSkills.assignAll(result);
    } catch (e) {
      skillsError.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingSkills.value = false;
    }
  }

  void setDeadline(DateTime value) {
    deadline.value = value;
  }

  void addDeliverable(String value) {
    final cleanValue = value.trim();
    if (cleanValue.isEmpty) return;
    deliverables.add(cleanValue);
  }

  void removeDeliverable(int index) {
    deliverables.removeAt(index);
  }

  void addAcceptanceCriterion(String value) {
    final cleanValue = value.trim();
    if (cleanValue.isEmpty) return;
    acceptanceCriteria.add(cleanValue);
  }

  void removeAcceptanceCriterion(int index) {
    acceptanceCriteria.removeAt(index);
  }

  void addSelectedSkill() {
    final skillId = selectedSkillId.value;

    if (skillId == null) {
      Get.snackbar(
        'تنبيه',
        'يرجى اختيار مهارة',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final alreadyExists = selectedSkills.any((item) => item.skill.id == skillId);

    if (alreadyExists) {
      Get.snackbar(
        'تنبيه',
        'هذه المهارة مضافة مسبقًا',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final skill = availableSkills.firstWhereOrNull((item) => item.id == skillId);

    if (skill == null) {
      Get.snackbar(
        'خطأ',
        'المهارة المحددة غير متاحة',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    selectedSkills.add(
      SelectedTaskSkill(
        skill: skill,
        requiredLevel: selectedRequiredLevel.value,
        mandatory: selectedMandatory.value,
      ),
    );

    selectedSkillId.value = null;
    selectedRequiredLevel.value = 3;
    selectedMandatory.value = true;
  }

  void removeSelectedSkill(int index) {
    selectedSkills.removeAt(index);
  }

  Future<void> pickDeadline(BuildContext context) async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: deadline.value ?? now.add(const Duration(days: 3)),
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (selectedDate == null || !context.mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 23, minute: 59),
    );

    if (selectedTime == null) return;

    deadline.value = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  Future<void> createTaskAsDraft() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (deadline.value == null) {
      Get.snackbar(
        'تنبيه',
        'يرجى تحديد موعد التسليم النهائي',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (deliverables.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'يرجى إضافة مخرج واحد على الأقل',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (acceptanceCriteria.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'يرجى إضافة معيار قبول واحد على الأقل',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedSkills.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'يرجى إضافة مهارة واحدة على الأقل',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSubmitting.value = true;

      final request = CreateCompanyTaskRequest(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        difficultyLevel: difficultyLevel.value,
        durationDays: int.parse(durationDaysController.text.trim()),
        deadline: _formatDateTimeForApi(deadline.value!),
        maxApplicants: int.parse(maxApplicantsController.text.trim()),
        maxAcceptedStudents: int.parse(maxAcceptedStudentsController.text.trim()),
        deliverables: deliverables.toList(),
        acceptanceCriteria: acceptanceCriteria.toList(),
        submissionType: submissionType.value,
        skills: selectedSkills.toList(),
      );

      final createdTask = await _taskService.createTask(request);

      _showCreatedDialog(createdTask);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> publishCreatedTask(int taskId) async {
    try {
      isSubmitting.value = true;

      await _taskService.publishTask(taskId);

      Get.back(); // close dialog
      Get.back(result: true); // close create page

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
      isSubmitting.value = false;
    }
  }

  void _showCreatedDialog(CompanyTaskModel task) {
    Get.dialog(
      AlertDialog(
        title: const Text('تم حفظ المهمة كمسودة'),
        content: const Text(
          'يمكنك نشر المهمة الآن ليتمكن الطلاب من التقديم عليها، أو تركها كمسودة ونشرها لاحقًا.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back(result: true);
            },
            child: const Text('لاحقًا'),
          ),
          ElevatedButton(
            onPressed: () => publishCreatedTask(task.id),
            child: const Text('نشر الآن'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  String levelLabel(int level) {
    switch (level) {
      case 1:
        return 'مبتدئ';
      case 2:
        return 'مبتدئ جيد';
      case 3:
        return 'متوسط';
      case 4:
        return 'متقدم';
      case 5:
        return 'خبير';
      default:
        return 'متوسط';
    }
  }

  String formattedDeadline() {
    final value = deadline.value;
    if (value == null) return 'حدد موعد التسليم';

    return '${value.year}-${_twoDigits(value.month)}-${_twoDigits(value.day)} '
        '${_twoDigits(value.hour)}:${_twoDigits(value.minute)}';
  }

  String _formatDateTimeForApi(DateTime value) {
    return '${value.year}-${_twoDigits(value.month)}-${_twoDigits(value.day)} '
        '${_twoDigits(value.hour)}:${_twoDigits(value.minute)}:00';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}