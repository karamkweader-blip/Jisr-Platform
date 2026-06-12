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

  final RxList<AvailableSkillModel> availableSkills =
      <AvailableSkillModel>[].obs;

  final RxList<SelectedTaskSkill> selectedSkills =
      <SelectedTaskSkill>[].obs;

  final RxnInt selectedSkillId = RxnInt();
  final RxInt selectedRequiredLevel = 3.obs;

  // وزن المهارة المختارة حاليًا
  final RxInt selectedWeight = 60.obs;

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
      skillsError.value = _cleanError(e);
    } finally {
      isLoadingSkills.value = false;
    }
  }

  void setDeadline(DateTime value) {
    deadline.value = value;
  }

  void addDeliverable(String value) {
    final cleanValue = value.trim();

    if (cleanValue.isEmpty) {
      return;
    }

    deliverables.add(cleanValue);
  }

  void removeDeliverable(int index) {
    if (index < 0 || index >= deliverables.length) {
      return;
    }

    deliverables.removeAt(index);
  }

  void addAcceptanceCriterion(String value) {
    final cleanValue = value.trim();

    if (cleanValue.isEmpty) {
      return;
    }

    acceptanceCriteria.add(cleanValue);
  }

  void removeAcceptanceCriterion(int index) {
    if (index < 0 || index >= acceptanceCriteria.length) {
      return;
    }

    acceptanceCriteria.removeAt(index);
  }

  void updateSelectedWeight(double value) {
    selectedWeight.value = value.round();
  }

  void addSelectedSkill() {
    final skillId = selectedSkillId.value;

    if (skillId == null) {
      _showWarning('يرجى اختيار مهارة');
      return;
    }

    final alreadyExists = selectedSkills.any(
      (item) => item.skill.id == skillId,
    );

    if (alreadyExists) {
      _showWarning('هذه المهارة مضافة مسبقًا');
      return;
    }

    final skill = availableSkills.firstWhereOrNull(
      (item) => item.id == skillId,
    );

    if (skill == null) {
      Get.snackbar(
        'خطأ',
        'المهارة المحددة غير متاحة',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final weight = selectedWeight.value;

    if (weight < 10 || weight > 100) {
      _showWarning('يجب أن يكون وزن المهارة بين 10 و100');
      return;
    }

    selectedSkills.add(
      SelectedTaskSkill(
        skill: skill,
        requiredLevel: selectedRequiredLevel.value,
        weight: weight,
        mandatory: selectedMandatory.value,
      ),
    );

    _resetSkillSelection();
  }

  void removeSelectedSkill(int index) {
    if (index < 0 || index >= selectedSkills.length) {
      return;
    }

    selectedSkills.removeAt(index);
  }

  void _resetSkillSelection() {
    selectedSkillId.value = null;
    selectedRequiredLevel.value = 3;
    selectedWeight.value = 60;
    selectedMandatory.value = true;
  }

  Future<void> pickDeadline(BuildContext context) async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: deadline.value ?? now.add(const Duration(days: 3)),
      firstDate: DateTime(
        now.year,
        now.month,
        now.day,
      ),
      lastDate: DateTime(now.year + 2),
    );

    if (selectedDate == null || !context.mounted) {
      return;
    }

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(
        hour: 23,
        minute: 59,
      ),
    );

    if (selectedTime == null) {
      return;
    }

    final selectedDeadline = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (!selectedDeadline.isAfter(DateTime.now())) {
      _showWarning('يجب أن يكون موعد التسليم في المستقبل');
      return;
    }

    deadline.value = selectedDeadline;
  }

  Future<void> createTaskAsDraft() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (deadline.value == null) {
      _showWarning('يرجى تحديد موعد التسليم النهائي');
      return;
    }

    if (!deadline.value!.isAfter(DateTime.now())) {
      _showWarning('يجب أن يكون موعد التسليم في المستقبل');
      return;
    }

    if (deliverables.isEmpty) {
      _showWarning('يرجى إضافة مخرج واحد على الأقل');
      return;
    }

    if (acceptanceCriteria.isEmpty) {
      _showWarning('يرجى إضافة معيار قبول واحد على الأقل');
      return;
    }

    if (selectedSkills.isEmpty) {
      _showWarning('يرجى إضافة مهارة واحدة على الأقل');
      return;
    }

    final durationDays = int.tryParse(
      durationDaysController.text.trim(),
    );

    final maxApplicants = int.tryParse(
      maxApplicantsController.text.trim(),
    );

    final maxAcceptedStudents = int.tryParse(
      maxAcceptedStudentsController.text.trim(),
    );

    if (durationDays == null ||
        maxApplicants == null ||
        maxAcceptedStudents == null) {
      _showWarning('يرجى التأكد من صحة الحقول الرقمية');
      return;
    }

    if (maxAcceptedStudents > maxApplicants) {
      _showWarning(
        'عدد المقبولين لا يمكن أن يكون أكبر من عدد المتقدمين',
      );
      return;
    }

    try {
      isSubmitting.value = true;

      final request = CreateCompanyTaskRequest(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        difficultyLevel: difficultyLevel.value,
        durationDays: durationDays,
        deadline: _formatDateTimeForApi(deadline.value!),
        maxApplicants: maxApplicants,
        maxAcceptedStudents: maxAcceptedStudents,
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
        _cleanError(e),
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

      Get.back();
      Get.back(result: true);

      Get.snackbar(
        'تم النشر',
        'تم نشر المهمة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        _cleanError(e),
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
          'يمكنك نشر المهمة الآن ليتمكن الطلاب من التقديم عليها، '
          'أو تركها كمسودة ونشرها لاحقًا.',
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

  void _showWarning(String message) {
    Get.snackbar(
      'تنبيه',
      message,
      snackPosition: SnackPosition.BOTTOM,
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

    if (value == null) {
      return 'حدد موعد التسليم';
    }

    return '${value.year}-'
        '${_twoDigits(value.month)}-'
        '${_twoDigits(value.day)} '
        '${_twoDigits(value.hour)}:'
        '${_twoDigits(value.minute)}';
  }

  String _formatDateTimeForApi(DateTime value) {
    return '${value.year}-'
        '${_twoDigits(value.month)}-'
        '${_twoDigits(value.day)} '
        '${_twoDigits(value.hour)}:'
        '${_twoDigits(value.minute)}:00';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .trim();
  }
}