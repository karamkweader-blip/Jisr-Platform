import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/models/company/tasks/company_task_details_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_model.dart';
import 'package:jisr_platform/services/company/tasks/company_task_details_service.dart';
import 'package:jisr_platform/services/company/tasks/company_task_service.dart';

class CreateCompanyTaskController extends GetxController {
  final CompanyTaskService _taskService;
  final CompanyTaskDetailsService _taskDetailsService;

  CreateCompanyTaskController(
    this._taskService,
    this._taskDetailsService,
  );

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
  final RxInt selectedWeight = 60.obs;
  final RxBool selectedMandatory = true.obs;

  final RxBool isLoadingSkills = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString skillsError = ''.obs;

  final RxBool isEditMode = false.obs;

  int? _editingTaskId;
  CompanyTaskDetailsModel? _originalTask;

  List<SelectedTaskSkill> _initialSelectedSkills =
      <SelectedTaskSkill>[];

  bool _skillsHydrated = false;
  bool _submissionTypeTouched = false;

  bool get isEditing => isEditMode.value;

  String get pageTitle {
    return isEditing ? 'تعديل المهمة' : 'إنشاء مهمة';
  }

  String get submitButtonLabel {
    return isEditing ? 'حفظ التعديلات' : 'حفظ كمسودة';
  }

  @override
  void onInit() {
    super.onInit();

    _readEditArguments();
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

  void _readEditArguments() {
    final arguments = Get.arguments;

    if (arguments is! Map) {
      return;
    }

    final mode = arguments['mode']?.toString();

    if (mode != 'edit') {
      return;
    }

    final rawTask = arguments['task'];

    if (rawTask is! Map) {
      _showWarning('تعذر قراءة بيانات المهمة المراد تعديلها');
      return;
    }

    final task = CompanyTaskDetailsModel.fromJson(
      Map<String, dynamic>.from(rawTask),
    );

    final passedTaskId = _toInt(arguments['taskId']);
    final taskId = passedTaskId > 0 ? passedTaskId : task.id;

    if (taskId <= 0) {
      _showWarning('معرف المهمة غير صالح');
      return;
    }

    isEditMode.value = true;
    _editingTaskId = taskId;
    _originalTask = task;

    _populateFormForEdit(task);
  }

  void _populateFormForEdit(CompanyTaskDetailsModel task) {
    titleController.text = task.title;
    descriptionController.text = task.description;
    durationDaysController.text = task.durationDays.toString();
    maxApplicantsController.text = task.maxApplicants.toString();
    maxAcceptedStudentsController.text =
        task.maxAcceptedStudents.toString();

    difficultyLevel.value = _supportedDifficultyLevel(
      task.difficultyLevel,
    );

    submissionType.value = _supportedSubmissionType(
      task.submissionType,
    );

    deadline.value = task.deadline?.toLocal();

    deliverables.assignAll(task.deliverables);
    acceptanceCriteria.assignAll(task.acceptanceCriteria);

    _submissionTypeTouched = false;
  }

  Future<void> fetchSkills() async {
    try {
      isLoadingSkills.value = true;
      skillsError.value = '';

      final result = await _taskService.getAvailableSkills();

      availableSkills.assignAll(result);

      if (isEditing && !_skillsHydrated) {
        _hydrateExistingSkills();
      }
    } catch (e) {
      skillsError.value = _cleanError(e);
    } finally {
      isLoadingSkills.value = false;
    }
  }

  void _hydrateExistingSkills() {
    final originalTask = _originalTask;

    if (originalTask == null) {
      return;
    }

    final hydratedSkills = <SelectedTaskSkill>[];

    for (final taskSkill in originalTask.skills) {
      final availableSkill = availableSkills.firstWhereOrNull(
        (skill) => skill.id == taskSkill.id,
      );

      final skill = availableSkill ??
          AvailableSkillModel(
            id: taskSkill.id,
            name: taskSkill.name,
            category: taskSkill.category,
          );

      hydratedSkills.add(
        SelectedTaskSkill(
          skill: skill,
          requiredLevel: _normalizeRequiredLevel(
            taskSkill.requiredLevel,
          ),
          weight: _normalizeWeight(taskSkill.weight),
          mandatory: taskSkill.mandatory,
        ),
      );
    }

    selectedSkills.assignAll(hydratedSkills);
    _initialSelectedSkills = List<SelectedTaskSkill>.from(
      hydratedSkills,
    );

    _skillsHydrated = true;
  }

  void setDifficultyLevel(String value) {
    difficultyLevel.value = value;
  }

  void setSubmissionType(String value) {
    submissionType.value = value;
    _submissionTypeTouched = true;
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
      _showWarning('المهارة المحددة غير متاحة');
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
      firstDate: DateTime(now.year, now.month, now.day),
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

    if (!isEditing && !selectedDeadline.isAfter(DateTime.now())) {
      _showWarning('يجب أن يكون موعد التسليم في المستقبل');
      return;
    }

    deadline.value = selectedDeadline;
  }

  Future<void> submitTask() async {
    if (isEditing) {
      await updateTask();
      return;
    }

    await createTaskAsDraft();
  }

  Future<void> createTaskAsDraft() async {
    if (isEditing) {
      await updateTask();
      return;
    }

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

    final durationDays = _readPositiveInt(
      durationDaysController.text,
    );

    final maxApplicants = _readPositiveInt(
      maxApplicantsController.text,
    );

    final maxAcceptedStudents = _readPositiveInt(
      maxAcceptedStudentsController.text,
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

  Future<void> updateTask() async {
    final originalTask = _originalTask;
    final taskId = _editingTaskId;

    if (!isEditing || originalTask == null || taskId == null) {
      _showWarning('تعذر تحديد المهمة المراد تعديلها');
      return;
    }

    if (!originalTask.canEdit) {
      _showWarning('لا يمكن تعديل المهمة في حالتها الحالية');
      return;
    }

    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final durationDays = _readPositiveInt(
      durationDaysController.text,
    );

    final maxApplicants = _readPositiveInt(
      maxApplicantsController.text,
    );

    final maxAcceptedStudents = _readPositiveInt(
      maxAcceptedStudentsController.text,
    );

    if (durationDays == null ||
        maxApplicants == null ||
        maxAcceptedStudents == null) {
      _showWarning('يرجى التأكد من صحة الحقول الرقمية');
      return;
    }

    final applicantLimitsChanged =
        maxApplicants != originalTask.maxApplicants ||
            maxAcceptedStudents != originalTask.maxAcceptedStudents;

    if (applicantLimitsChanged &&
        maxAcceptedStudents > maxApplicants) {
      _showWarning(
        'عدد المقبولين لا يمكن أن يكون أكبر من عدد المتقدمين',
      );
      return;
    }

    final deadlineChanged = !_sameDateTimeToMinute(
      deadline.value,
      originalTask.deadline,
    );

    if (deadlineChanged) {
      if (deadline.value == null) {
        _showWarning('يرجى تحديد موعد تسليم صالح');
        return;
      }

      if (!deadline.value!.isAfter(DateTime.now())) {
        _showWarning('يجب أن يكون موعد التسليم في المستقبل');
        return;
      }
    }

    final deliverablesChanged = !_sameStringList(
      deliverables,
      originalTask.deliverables,
    );

    if (deliverablesChanged && deliverables.isEmpty) {
      _showWarning('يجب أن تحتوي المهمة على مخرج واحد على الأقل');
      return;
    }

    final acceptanceCriteriaChanged = !_sameStringList(
      acceptanceCriteria,
      originalTask.acceptanceCriteria,
    );

    if (acceptanceCriteriaChanged &&
        acceptanceCriteria.isEmpty) {
      _showWarning('يجب إضافة معيار قبول واحد على الأقل');
      return;
    }

    final skillsChanged = !_sameSelectedSkills(
      selectedSkills,
      _initialSelectedSkills,
    );

    if (skillsChanged && selectedSkills.isEmpty) {
      _showWarning('يجب أن تحتوي المهمة على مهارة واحدة على الأقل');
      return;
    }

    final request = _buildUpdateRequest(
      durationDays: durationDays,
      maxApplicants: maxApplicants,
      maxAcceptedStudents: maxAcceptedStudents,
      deadlineChanged: deadlineChanged,
      deliverablesChanged: deliverablesChanged,
      acceptanceCriteriaChanged: acceptanceCriteriaChanged,
      skillsChanged: skillsChanged,
    );

    if (request.isEmpty) {
      _showWarning('لم يتم إجراء أي تعديل على المهمة');
      return;
    }

    try {
      isSubmitting.value = true;

      await _taskDetailsService.updateTask(
        taskId: taskId,
        request: request,
      );

      Get.back(result: true);

      Get.snackbar(
        'تم التعديل',
        'تم حفظ تعديلات المهمة بنجاح',
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

  UpdateCompanyTaskRequest _buildUpdateRequest({
    required int durationDays,
    required int maxApplicants,
    required int maxAcceptedStudents,
    required bool deadlineChanged,
    required bool deliverablesChanged,
    required bool acceptanceCriteriaChanged,
    required bool skillsChanged,
  }) {
    final originalTask = _originalTask!;

    final currentTitle = titleController.text.trim();
    final currentDescription = descriptionController.text.trim();

    final originalDifficulty = _supportedDifficultyLevel(
      originalTask.difficultyLevel,
    );

    final originalSubmissionType = _supportedSubmissionType(
      originalTask.submissionType,
    );

    final submissionTypeChanged = _submissionTypeTouched
        ? submissionType.value != originalTask.submissionType
        : submissionType.value != originalSubmissionType;

    return UpdateCompanyTaskRequest(
      title: currentTitle != originalTask.title.trim()
          ? currentTitle
          : null,
      description: currentDescription != originalTask.description.trim()
          ? currentDescription
          : null,
      difficultyLevel: difficultyLevel.value != originalDifficulty
          ? difficultyLevel.value
          : null,
      durationDays: durationDays != originalTask.durationDays
          ? durationDays
          : null,
      deadline: deadlineChanged && deadline.value != null
          ? _formatDateTimeForApi(deadline.value!)
          : null,
      maxApplicants: maxApplicants != originalTask.maxApplicants
          ? maxApplicants
          : null,
      maxAcceptedStudents:
          maxAcceptedStudents != originalTask.maxAcceptedStudents
              ? maxAcceptedStudents
              : null,
      deliverables: deliverablesChanged
          ? deliverables.toList()
          : null,
      acceptanceCriteria: acceptanceCriteriaChanged
          ? acceptanceCriteria.toList()
          : null,
      submissionType: submissionTypeChanged
          ? submissionType.value
          : null,
      skills: skillsChanged ? selectedSkills.toList() : null,
    );
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

  int? _readPositiveInt(String value) {
    final parsedValue = int.tryParse(value.trim());

    if (parsedValue == null || parsedValue <= 0) {
      return null;
    }

    return parsedValue;
  }

  int _normalizeRequiredLevel(int level) {
    if (level >= 1 && level <= 5) {
      return level;
    }

    return 3;
  }

  int _normalizeWeight(double weight) {
    final normalizedWeight = weight.round();

    if (normalizedWeight < 10) {
      return 10;
    }

    if (normalizedWeight > 100) {
      return 100;
    }

    return normalizedWeight;
  }

  String _supportedDifficultyLevel(String value) {
    const allowedLevels = [
      'beginner',
      'intermediate',
      'advanced',
    ];

    return allowedLevels.contains(value)
        ? value
        : 'intermediate';
  }

 String _supportedSubmissionType(String value) {
  const allowedTypes = [
    'github_link',
    'zip_file',
    'demo_link',
    'mixed',
  ];

  return allowedTypes.contains(value)
      ? value
      : 'github_link';
}

  bool _sameStringList(
    List<String> first,
    List<String> second,
  ) {
    if (first.length != second.length) {
      return false;
    }

    for (var index = 0; index < first.length; index++) {
      if (first[index].trim() != second[index].trim()) {
        return false;
      }
    }

    return true;
  }

  bool _sameSelectedSkills(
    List<SelectedTaskSkill> first,
    List<SelectedTaskSkill> second,
  ) {
    if (first.length != second.length) {
      return false;
    }

    for (var index = 0; index < first.length; index++) {
      final firstSkill = first[index];
      final secondSkill = second[index];

      if (firstSkill.skill.id != secondSkill.skill.id ||
          firstSkill.requiredLevel != secondSkill.requiredLevel ||
          firstSkill.weight != secondSkill.weight ||
          firstSkill.mandatory != secondSkill.mandatory) {
        return false;
      }
    }

    return true;
  }

  bool _sameDateTimeToMinute(
    DateTime? first,
    DateTime? second,
  ) {
    if (first == null || second == null) {
      return first == second;
    }

    final firstLocal = first.toLocal();
    final secondLocal = second.toLocal();

    return firstLocal.year == secondLocal.year &&
        firstLocal.month == secondLocal.month &&
        firstLocal.day == secondLocal.day &&
        firstLocal.hour == secondLocal.hour &&
        firstLocal.minute == secondLocal.minute;
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
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