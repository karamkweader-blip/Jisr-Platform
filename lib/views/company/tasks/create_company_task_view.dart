import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/create_company_task_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/company_task_model.dart';

class CreateCompanyTaskView extends GetView<CreateCompanyTaskController> {
  const CreateCompanyTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          'إنشاء مهمة',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            children: [
              const _FormSectionTitle(
                title: 'المعلومات الأساسية',
                subtitle: 'عرّف المهمة بشكل واضح للطلاب.',
              ),
              const SizedBox(height: 12),
              _TextInput(
                controller: controller.titleController,
                label: 'عنوان المهمة',
                icon: Icons.title_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال عنوان المهمة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _TextInput(
                controller: controller.descriptionController,
                label: 'وصف المهمة',
                icon: Icons.description_outlined,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال وصف المهمة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Obx(
                () => _SelectInput<String>(
                  label: 'مستوى الصعوبة',
                  value: controller.difficultyLevel.value,
                  items: const [
                    DropdownMenuItem(
                      value: 'beginner',
                      child: Text('مبتدئ'),
                    ),
                    DropdownMenuItem(
                      value: 'intermediate',
                      child: Text('متوسط'),
                    ),
                    DropdownMenuItem(
                      value: 'advanced',
                      child: Text('متقدم'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.difficultyLevel.value = value;
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      controller: controller.durationDaysController,
                      label: 'المدة بالأيام',
                      icon: Icons.timelapse_rounded,
                      keyboardType: TextInputType.number,
                      validator: _positiveNumberValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => _DatePickerCard(
                        label: controller.formattedDeadline(),
                        onTap: () => controller.pickDeadline(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const _FormSectionTitle(
                title: 'حدود التقديم والقبول',
                subtitle: 'حدد عدد المتقدمين والطلاب المقبولين.',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      controller: controller.maxApplicantsController,
                      label: 'عدد المتقدمين',
                      icon: Icons.people_outline_rounded,
                      keyboardType: TextInputType.number,
                      validator: _positiveNumberValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      controller: controller.maxAcceptedStudentsController,
                      label: 'عدد المقبولين',
                      icon: Icons.verified_user_outlined,
                      keyboardType: TextInputType.number,
                      validator: _positiveNumberValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const _FormSectionTitle(
                title: 'المتطلبات والتسليم',
                subtitle: 'وضح المطلوب تسليمه ومعايير قبول المهمة.',
              ),
              const SizedBox(height: 12),
              Obx(
                () => _SelectInput<String>(
                  label: 'نوع التسليم',
                  value: controller.submissionType.value,
                  items: const [
                    DropdownMenuItem(
                      value: 'github_link',
                      child: Text('رابط GitHub'),
                    ),
                    DropdownMenuItem(
                      value: 'file_upload',
                      child: Text('رفع ملف'),
                    ),
                    DropdownMenuItem(
                      value: 'text',
                      child: Text('نص / شرح'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.submissionType.value = value;
                    }
                  },
                ),
              ),
              const SizedBox(height: 14),
             Obx(
  () => _DynamicTextList(
    title: 'المخرجات المطلوبة',
    addLabel: 'إضافة مخرج',
    values: controller.deliverables.toList(),
    onAdd: controller.addDeliverable,
    onRemove: controller.removeDeliverable,
  ),
),
              const SizedBox(height: 14),
              Obx(
  () => _DynamicTextList(
    title: 'معايير القبول',
    addLabel: 'إضافة معيار',
    values: controller.acceptanceCriteria.toList(),
    onAdd: controller.addAcceptanceCriterion,
    onRemove: controller.removeAcceptanceCriterion,
  ),
),
              const SizedBox(height: 26),
              const _FormSectionTitle(
                title: 'المهارات المطلوبة',
                subtitle: 'اختر المهارات التي يحتاجها الطالب لتنفيذ المهمة.',
              ),
              const SizedBox(height: 12),
              const _SkillsSelector(),
              const SizedBox(height: 28),
              Obx(
                () => SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.createTaskAsDraft,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'حفظ كمسودة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String? _positiveNumberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'مطلوب';
    }

    final number = int.tryParse(value.trim());

    if (number == null || number <= 0) {
      return 'رقم غير صالح';
    }

    return null;
  }
}

class _FormSectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FormSectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _TextInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
        filled: true,
        fillColor: AppColors.cardWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _SelectInput<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _SelectInput({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: AppColors.cardWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _DatePickerCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DatePickerCard({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.event_outlined,
              color: AppColors.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DynamicTextList extends StatelessWidget {
  final String title;
  final String addLabel;
  final List<String> values;
  final ValueChanged<String> onAdd;
  final ValueChanged<int> onRemove;

  const _DynamicTextList({
    required this.title,
    required this.addLabel,
    required this.values,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (values.isEmpty)
            const Text(
              'لم تتم إضافة عناصر بعد',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 13,
              ),
            )
          else
            ...List.generate(
              values.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        values[index],
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => onRemove(index),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textGrey,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          TextButton.icon(
            onPressed: () => _showAddTextDialog(
              context: context,
              title: addLabel,
              onSubmit: onAdd,
            ),
            icon: const Icon(Icons.add_rounded),
            label: Text(addLabel),
          ),
        ],
      ),
    );
  }

  void _showAddTextDialog({
    required BuildContext context,
    required String title,
    required ValueChanged<String> onSubmit,
  }) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: textController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'اكتب هنا',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                onSubmit(textController.text);
                Navigator.pop(context);
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }
}

class _SkillsSelector extends GetView<CreateCompanyTaskController> {
  const _SkillsSelector();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingSkills.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
        );
      }

      if (controller.skillsError.value.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Text(
                controller.skillsError.value,
                style: const TextStyle(color: AppColors.textGrey),
              ),
              TextButton(
                onPressed: controller.fetchSkills,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: controller.selectedSkillId.value,
              items: controller.availableSkills
                  .map(
                    (skill) => DropdownMenuItem<int>(
                      value: skill.id,
                      child: Text(skill.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => controller.selectedSkillId.value = value,
              decoration: InputDecoration(
                hintText: 'اختر مهارة',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: controller.selectedRequiredLevel.value,
              items: List.generate(
                5,
                (index) {
                  final level = index + 1;
                  return DropdownMenuItem<int>(
                    value: level,
                    child: Text(controller.levelLabel(level)),
                  );
                },
              ),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedRequiredLevel.value = value;
                }
              },
              decoration: InputDecoration(
                hintText: 'المستوى المطلوب',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: controller.selectedMandatory.value,
              onChanged: (value) => controller.selectedMandatory.value = value,
              activeColor: AppColors.primaryBlue,
              title: const Text(
                'مهارة أساسية',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: const Text(
                'فعّلها إذا كانت المهارة ضرورية لتنفيذ المهمة',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12.5,
                ),
              ),
            ),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: controller.addSelectedSkill,
                icon: const Icon(Icons.add_rounded),
                label: const Text('إضافة المهارة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            if (controller.selectedSkills.isNotEmpty) ...[
              const SizedBox(height: 14),
              ...List.generate(
                controller.selectedSkills.length,
                (index) {
                  final item = controller.selectedSkills[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.skill.name} · ${controller.levelLabel(item.requiredLevel)} · ${item.mandatory ? 'أساسية' : 'مفضلة'}',
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => controller.removeSelectedSkill(index),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ), 
            ],
          ],
        ),
      );
    });
  }
}