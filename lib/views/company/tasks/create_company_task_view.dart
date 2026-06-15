import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/tasks/create_company_task_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/tasks/company_task_model.dart';

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

class _SkillsSelector
    extends GetView<CreateCompanyTaskController> {
  const _SkillsSelector();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingSkills.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(
              color: AppColors.primaryBlue,
            ),
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
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.primaryBlue,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                controller.skillsError.value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: controller.fetchSkills,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        );
      }

      if (controller.availableSkills.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.psychology_alt_outlined,
                color: AppColors.textGrey,
                size: 32,
              ),
              SizedBox(height: 10),
              Text(
                'لا توجد مهارات متاحة حاليًا',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
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
          border: Border.all(
            color: AppColors.primaryBlue.withOpacity(0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إضافة مهارة',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'حدد المهارة ومستواها وأهميتها بالنسبة للمهمة.',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<int>(
              value: controller.selectedSkillId.value,
              isExpanded: true,
              items: controller.availableSkills.map((skill) {
                return DropdownMenuItem<int>(
                  value: skill.id,
                  child: _SkillDropdownItem(
                    skill: skill,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                controller.selectedSkillId.value = value;
              },
              decoration: InputDecoration(
                hintText: 'اختر مهارة',
                prefixIcon: const Icon(
                  Icons.code_rounded,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 1.3,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              value: controller.selectedRequiredLevel.value,
              isExpanded: true,
              items: List.generate(
                5,
                (index) {
                  final level = index + 1;

                  return DropdownMenuItem<int>(
                    value: level,
                    child: Text(
                      controller.levelLabel(level),
                    ),
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
                prefixIcon: const Icon(
                  Icons.trending_up_rounded,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 1.3,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            _SkillWeightSelector(
              weight: controller.selectedWeight.value,
              onChanged: controller.updateSelectedWeight,
            ),

            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                value: controller.selectedMandatory.value,
                onChanged: (value) {
                  controller.selectedMandatory.value = value;
                },
                activeColor: AppColors.primaryBlue,
                title: const Text(
                  'مهارة أساسية',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  controller.selectedMandatory.value
                      ? 'يجب أن يمتلك الطالب هذه المهارة'
                      : 'وجود المهارة مفضل لكنه ليس شرطًا',
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 46,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: controller.addSelectedSkill,
                icon: const Icon(
                  Icons.add_rounded,
                ),
                label: const Text(
                  'إضافة المهارة',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(
                    color: AppColors.primaryBlue,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            if (controller.selectedSkills.isNotEmpty) ...[
              const SizedBox(height: 18),
              const Divider(
                color: AppColors.background,
                thickness: 1.4,
              ),
              const SizedBox(height: 12),
              const Text(
                'المهارات المضافة',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),

              ...List.generate(
                controller.selectedSkills.length,
                (index) {
                  final item =
                      controller.selectedSkills[index];

                  return _SelectedSkillCard(
                    item: item,
                    levelLabel: controller.levelLabel(
                      item.requiredLevel,
                    ),
                    onRemove: () {
                      controller.removeSelectedSkill(index);
                    },
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

class _SkillDropdownItem extends StatelessWidget {
  final AvailableSkillModel skill;

  const _SkillDropdownItem({
    required this.skill,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            skill.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (skill.category.trim().isNotEmpty) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              skill.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SkillWeightSelector extends StatelessWidget {
  final int weight;
  final ValueChanged<double> onChanged;

  const _SkillWeightSelector({
    required this.weight,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'وزن المهارة',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'مدى تأثير المهارة في مطابقة المرشحين',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                constraints: const BoxConstraints(
                  minWidth: 52,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$weight%',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: weight.toDouble(),
            min: 10,
            max: 100,
            divisions: 18,
            label: '$weight%',
            activeColor: AppColors.primaryBlue,
            inactiveColor:
                AppColors.primaryBlue.withOpacity(0.15),
            onChanged: onChanged,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'أقل أهمية',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 10.5,
                ),
              ),
              Text(
                'أعلى أهمية',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectedSkillCard extends StatelessWidget {
  final SelectedTaskSkill item;
  final String levelLabel;
  final VoidCallback onRemove;

  const _SelectedSkillCard({
    required this.item,
    required this.levelLabel,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.055),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.code_rounded,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.skill.name,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: item.mandatory
                            ? AppColors.actionYellow.withOpacity(0.12)
                            : AppColors.primaryBlue.withOpacity(0.09),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        item.mandatory ? 'أساسية' : 'مفضلة',
                        style: TextStyle(
                          color: item.mandatory
                              ? AppColors.actionYellow
                              : AppColors.primaryBlue,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _SelectedSkillInfoChip(
                      icon: Icons.trending_up_rounded,
                      label: levelLabel,
                    ),
                    _SelectedSkillInfoChip(
                      icon: Icons.percent_rounded,
                      label: 'الوزن ${item.weight}%',
                    ),
                    if (item.skill.category.trim().isNotEmpty)
                      _SelectedSkillInfoChip(
                        icon: Icons.category_outlined,
                        label: item.skill.category,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onRemove,
            tooltip: 'حذف المهارة',
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.textGrey,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedSkillInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SelectedSkillInfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 13,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}