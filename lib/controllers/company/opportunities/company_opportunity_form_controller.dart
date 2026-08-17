import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_model.dart';
import 'package:jisr_platform/services/company/opportunities/company_opportunity_service.dart';
import 'package:jisr_platform/services/company/tasks/company_task_service.dart';

class CompanyOpportunityFormController extends GetxController {
  final CompanyOpportunityService _service;
  final CompanyTaskService _taskService;

  CompanyOpportunityFormController(
    this._service,
    this._taskService,
  );

  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final salaryMinController = TextEditingController();
  final salaryMaxController = TextEditingController();

  final type = ''.obs;
  final deadline = Rxn<DateTime>();

  final availableSkills = <AvailableSkillModel>[].obs;
  final selectedSkills = <CompanyOpportunitySkill>[].obs;

  final isLoadingSkills = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;

  int? opportunityId;

  bool get isEditing => opportunityId != null;

  bool get hasSelectedType {
    return type.value == 'job' ||
        type.value == 'internship';
  }

  bool get isJob => type.value == 'job';

  bool get isInternship {
    return type.value == 'internship';
  }

  String get opportunityTypeLabel {
    if (isJob) return 'وظيفة';
    if (isInternship) return 'تدريب';

    return 'فرصة';
  }

  String get pageTitle {
    if (isEditing) {
      return 'تعديل $opportunityTypeLabel';
    }

    return 'إنشاء فرصة جديدة';
  }

  String get submitLabel {
    if (isEditing) {
      return 'حفظ التعديلات';
    }

    if (isJob) {
      return 'حفظ الوظيفة كمسودة';
    }

    if (isInternship) {
      return 'حفظ التدريب كمسودة';
    }

    return 'حفظ كمسودة';
  }

  @override
  void onInit() {
    super.onInit();

    _readArguments();
    loadSkills();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    salaryMinController.dispose();
    salaryMaxController.dispose();

    super.onClose();
  }

  void _readArguments() {
    final args = Get.arguments;

    if (args is! Map) return;

    final requestedType = args['type']?.toString();

    if (requestedType == 'job' ||
        requestedType == 'internship') {
      type.value = requestedType!;
    }

    final raw = args['opportunity'];

    if (args['mode'] != 'edit' || raw is! Map) {
      return;
    }

    final opportunity =
        CompanyOpportunityModel.fromJson(
      Map<String, dynamic>.from(raw),
    );

    opportunityId = opportunity.id;

    titleController.text = opportunity.title;
    descriptionController.text =
        opportunity.description;
    locationController.text = opportunity.location;

    salaryMinController.text =
        opportunity.salaryMin?.toString() ?? '';

    salaryMaxController.text =
        opportunity.salaryMax?.toString() ?? '';

    type.value = opportunity.type == 'job'
        ? 'job'
        : 'internship';

    deadline.value =
        opportunity.deadline?.toLocal();

    selectedSkills.assignAll(
      opportunity.skills,
    );
  }

  Future<void> loadSkills() async {
    try {
      isLoadingSkills.value = true;
      errorMessage.value = '';

      final skills =
          await _taskService.getAvailableSkills();

      availableSkills.assignAll(skills);
    } catch (error) {
      errorMessage.value = _clean(error);
    } finally {
      isLoadingSkills.value = false;
    }
  }

  void selectType(String value) {
    if (value != 'job' &&
        value != 'internship') {
      return;
    }

    type.value = value;
  }

  void addSkill(AvailableSkillModel skill) {
    final isAlreadySelected = selectedSkills.any(
      (item) => item.id == skill.id,
    );

    if (isAlreadySelected) {
      Get.snackbar(
        'تنبيه',
        'هذه المهارة مضافة مسبقًا',
      );

      return;
    }

    selectedSkills.add(
      CompanyOpportunitySkill(
        id: skill.id,
        name: skill.name,
        requiredLevel: 50,
        mandatory: true,
        weight: 1,
      ),
    );
  }

  void updateSkill(
    CompanyOpportunitySkill skill, {
    int? level,
    bool? mandatory,
    double? weight,
  }) {
    final index = selectedSkills.indexWhere(
      (item) => item.id == skill.id,
    );

    if (index == -1) return;

    selectedSkills[index] =
        CompanyOpportunitySkill(
      id: skill.id,
      name: skill.name,
      requiredLevel:
          level ?? skill.requiredLevel,
      mandatory:
          mandatory ?? skill.mandatory,
      weight: weight ?? skill.weight,
    );

    selectedSkills.refresh();
  }

  void removeSkill(int id) {
    selectedSkills.removeWhere(
      (item) => item.id == id,
    );
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;

    if (!hasSelectedType) {
      Get.snackbar(
        'حدد نوع الفرصة',
        'اختر وظيفة أو تدريب قبل متابعة إدخال البيانات',
      );

      return;
    }

    final isValid =
        formKey.currentState?.validate() == true;

    if (!isValid) return;

    if (deadline.value == null) {
      Get.snackbar(
        'بيانات ناقصة',
        'يرجى تحديد آخر موعد للتقديم',
      );

      return;
    }

    if (selectedSkills.isEmpty) {
      Get.snackbar(
        'بيانات ناقصة',
        'أضف مهارة واحدة على الأقل',
      );

      return;
    }

    final minimumAmount = double.tryParse(
      salaryMinController.text.trim(),
    );

    final maximumAmount = double.tryParse(
      salaryMaxController.text.trim(),
    );

    final hasInvalidAmount =
        minimumAmount == null ||
        maximumAmount == null ||
        minimumAmount < 0 ||
        maximumAmount < minimumAmount;

    if (hasInvalidAmount) {
      final amountLabel =
          isJob ? 'الراتب' : 'المكافأة';

      Get.snackbar(
        'قيمة غير صالحة',
        'تحقق من الحد الأدنى والأعلى لـ$amountLabel',
      );

      return;
    }

    try {
      isSubmitting.value = true;

      final request =
          SaveCompanyOpportunityRequest(
        title: titleController.text.trim(),
        description:
            descriptionController.text.trim(),
        type: type.value,
        location:
            locationController.text.trim(),
        salaryMin: minimumAmount,
        salaryMax: maximumAmount,
        deadline: _date(deadline.value!),
        skills: selectedSkills.toList(),
      );

      if (isEditing) {
        await _service.updateOpportunity(
          opportunityId!,
          request,
        );
      } else {
        await _service.createOpportunity(
          request,
        );
      }

      Get.back(result: true);

      Get.snackbar(
        'تم الحفظ',
        isEditing
            ? 'تم تعديل $opportunityTypeLabel بنجاح'
            : 'تم حفظ $opportunityTypeLabel كمسودة',
      );
    } catch (error) {
      Get.snackbar(
        'تعذر الحفظ',
        _clean(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  String _date(DateTime value) {
    final localDate = value.toLocal();

    final month = localDate.month
        .toString()
        .padLeft(2, '0');

    final day = localDate.day
        .toString()
        .padLeft(2, '0');

    return '${localDate.year}-$month-$day';
  }

  String _clean(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '');
  }
}