import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/opportunities/company_opportunity_form_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_model.dart';
import 'package:jisr_platform/views/company/opportunities/widgets/opportunity_form_skill_widgets.dart';

part 'widgets/opportunity_form_header_widgets.dart';
part 'widgets/opportunity_form_field_widgets.dart';
part 'widgets/opportunity_form_submit_widget.dart';

class CompanyOpportunityFormView
    extends GetView<CompanyOpportunityFormController> {
  const CompanyOpportunityFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final blueContainer = baseTheme.brightness == Brightness.dark
        ? const Color(0xFF123F5E)
        : const Color(0xFFDCEFFD);

    return Theme(
      data: baseTheme.copyWith(
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: AppColors.primaryBlue,
          onPrimary: Colors.white,
          primaryContainer: blueContainer,
          onPrimaryContainer: AppColors.primaryBlue,
          secondary: AppColors.primaryBlue,
          onSecondary: Colors.white,
          secondaryContainer: blueContainer,
          onSecondaryContainer: AppColors.primaryBlue,
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
        backgroundColor: AppColors.background,
       appBar: AppBar(
  backgroundColor: AppColors.background,
  foregroundColor: AppColors.textDark,
  elevation: 0,
  centerTitle: true,
  title: Text(
    controller.pageTitle,
    style: const TextStyle(
      color: AppColors.textDark,
      fontSize: 18,
      fontWeight: FontWeight.w900,
    ),
  ),
),
        body: SafeArea(
          top: false,
          child: Form(
            key: controller.formKey,
            child: ListView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                28,
              ),
              children: [
                Obx(
                  () => _OpportunityHero(
                    type: controller.type.value,
                    isEditing: controller.isEditing,
                  ),
                ),
                const SizedBox(height: 16),
                _FormSection(
                  icon: Icons.tune,
                  title: 'نوع الفرصة',
                  subtitle:
                      'اختر النوع بدقة حتى تظهر الفرصة للطلاب المناسبين.',
                  child: Obx(
                    () => _OpportunityTypeSelector(
                      selectedType: controller.type.value,
                      onChanged: controller.selectType,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => AnimatedSwitcher(
                    duration: const Duration(
                      milliseconds: 260,
                    ),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: controller.hasSelectedType
                        ? _buildOpportunityFields(
                            context,
                            isJob: controller.isJob,
                            key: ValueKey(
                              controller.type.value,
                            ),
                          )
                        : const SelectOpportunityTypePrompt(
                            key: ValueKey('select-type'),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Obx(
          () => _SubmitBar(
            label: controller.submitLabel,
            isLoading: controller.isSubmitting.value,
            onPressed: controller.hasSelectedType &&
                    !controller.isSubmitting.value
                ? controller.submit
                : null,
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildOpportunityFields(
    BuildContext context, {
    required bool isJob,
    required Key key,
  }) {
    return Column(
      key: key,
      children: [
        _FormSection(
          icon: isJob
              ? Icons.badge_outlined
              : Icons.school_outlined,
          title: isJob
              ? 'بيانات الوظيفة'
              : 'بيانات برنامج التدريب',
          subtitle: isJob
              ? 'عرّف المنصب والمسؤوليات بشكل واضح للمرشحين.'
              : 'وضّح محتوى التدريب والفائدة التي سيحصل عليها المتدرب.',
          child: Column(
            children: [
              _OpportunityField(
                controller: controller.titleController,
                label: isJob
                    ? 'المسمى الوظيفي'
                    : 'عنوان برنامج التدريب',
                hint: isJob
                    ? 'مثال: مطور Flutter مبتدئ'
                    : 'مثال: تدريب تطوير تطبيقات Flutter',
                icon: isJob
                    ? Icons.work_outline
                    : Icons.school_outlined,
                validator: (value) {
                  return _required(
                    value,
                    isJob
                        ? 'يرجى إدخال المسمى الوظيفي'
                        : 'يرجى إدخال عنوان التدريب',
                  );
                },
              ),
              const SizedBox(height: 14),
              _OpportunityField(
                controller:
                    controller.descriptionController,
                label: isJob
                    ? 'وصف الوظيفة والمسؤوليات'
                    : 'وصف التدريب وما سيتعلمه المتدرب',
                hint: isJob
                    ? 'اذكر المسؤوليات اليومية، طبيعة الدور والنتائج المتوقعة...'
                    : 'اذكر محاور التدريب، الخبرة العملية والنتائج المتوقعة...',
                icon: Icons.description_outlined,
                minLines: 5,
                maxLines: 7,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                validator: (value) {
                  return _required(
                    value,
                    isJob
                        ? 'يرجى كتابة وصف الوظيفة'
                        : 'يرجى كتابة وصف التدريب',
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _FormSection(
          icon: Icons.place_outlined,
          title: isJob
              ? 'مكان العمل والتعويض'
              : 'مكان التدريب والمكافأة',
          subtitle: isJob
              ? 'حدّد نمط العمل ونطاق الراتب المتوقع.'
              : 'حدّد نمط التدريب والمكافأة إن وُجدت.',
          child: Column(
            children: [
              _OpportunityField(
                controller: controller.locationController,
                label: isJob
                    ? 'موقع العمل أو نمطه'
                    : 'مكان التدريب أو نمطه',
                hint: 'مثال: عن بُعد، هجين، دمشق',
                icon: Icons.location_on_outlined,
                validator: (value) {
                  return _required(
                    value,
                    isJob
                        ? 'يرجى تحديد موقع أو نمط العمل'
                        : 'يرجى تحديد مكان أو نمط التدريب',
                  );
                },
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _OpportunityField(
                      controller:
                          controller.salaryMinController,
                      label: isJob
                          ? 'الراتب من'
                          : 'المكافأة من',
                      hint: '0',
                      icon: Icons.attach_money,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                      ),
                      validator: _amount,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _OpportunityField(
                      controller:
                          controller.salaryMaxController,
                      label: isJob
                          ? 'الراتب إلى'
                          : 'المكافأة إلى',
                      hint: '0',
                      icon: Icons.trending_up,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction:
                          TextInputAction.done,
                      validator: _amount,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _InlineHint(
                text: isJob
                    ? 'أدخل نطاق الراتب بالأرقام وبنفس العملة المعتمدة لديكم.'
                    : 'إذا كان التدريب غير مدفوع، أدخل 0 في حقلي المكافأة.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _FormSection(
          icon: Icons.event_available,
          title: 'مدة استقبال الطلبات',
          subtitle:
              'حدّد آخر يوم يستطيع فيه الطلاب إرسال طلباتهم.',
          child: Obx(
            () => _DeadlinePicker(
              date: controller.deadline.value,
              onTap: () => _pickDeadline(context),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _FormSection(
          icon: Icons.star_outline,
          title: 'المهارات المطلوبة',
          subtitle: isJob
              ? 'أضف المهارات التي سيُقيّم المرشح بناءً عليها.'
              : 'أضف المهارات الأساسية المطلوبة للالتحاق بالتدريب.',
          action: TextButton.icon(
            onPressed: () => _selectSkill(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
            ),
            icon: const Icon(
              Icons.add,
              size: 18,
            ),
            label: const Text(
              'إضافة',
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          child: Obx(
            () {
              if (controller.isLoadingSkills.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                  child: LinearProgressIndicator(
                    color: AppColors.primaryBlue,
                    backgroundColor:
                        Color(0xFFE3EBF1),
                  ),
                );
              }

              if (controller
                      .errorMessage.value.isNotEmpty &&
                  controller.availableSkills.isEmpty) {
                return OpportunitySkillsError(
                  message:
                      controller.errorMessage.value,
                  onRetry: controller.loadSkills,
                );
              }

              if (controller.selectedSkills.isEmpty) {
                return EmptyOpportunitySkills(
                  onAdd: () => _selectSkill(context),
                );
              }

              return Column(
                children: controller.selectedSkills
                    .map(
                      (skill) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: OpportunitySkillCard(
                          skill: skill,
                          onMandatoryChanged: (value) {
                            controller.updateSkill(
                              skill,
                              mandatory: value,
                            );
                          },
                          onLevelChanged: (value) {
                            controller.updateSkill(
                              skill,
                              level: value,
                            );
                          },
                          onWeightChanged: (value) {
                            controller.updateSkill(
                              skill,
                              weight: value,
                            );
                          },
                          onDelete: () {
                            controller.removeSkill(
                              skill.id,
                            );
                          },
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _pickDeadline(
    BuildContext context,
  ) async {
    final now = DateTime.now();

    final firstDate = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final current = controller.deadline.value;

    final initialDate =
        current != null && !current.isBefore(firstDate)
            ? current
            : firstDate.add(
                const Duration(days: 7),
              );

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 5),
      helpText: 'اختر آخر موعد للتقديم',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      builder: (pickerContext, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Theme(
            data: Theme.of(pickerContext).copyWith(
              colorScheme: Theme.of(pickerContext)
                  .colorScheme
                  .copyWith(
                    primary: AppColors.primaryBlue,
                    secondary: AppColors.actionYellow,
                  ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      controller.deadline.value = picked;
    }
  }

  Future<void> _selectSkill(
    BuildContext context,
  ) async {
    final skill =
        await showModalBottomSheet<AvailableSkillModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height:
                  MediaQuery.of(sheetContext).size.height *
                      0.68,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(
                      top: 10,
                      bottom: 12,
                    ),
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9E1E7),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      14,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إضافة مهارة',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 19,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'اختر مهارة ثم حدّد مستواها وأهميتها.',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFFE5ECF1),
                  ),
                  Expanded(
                    child: Obx(
                      () {
                        if (controller
                            .isLoadingSkills.value) {
                          return const Center(
                            child:
                                CircularProgressIndicator(
                              color:
                                  AppColors.primaryBlue,
                            ),
                          );
                        }

                        final items = controller
                            .availableSkills
                            .where(
                              (item) => !controller
                                  .selectedSkills
                                  .any(
                                    (selected) =>
                                        selected.id ==
                                        item.id,
                                  ),
                            )
                            .toList();

                        if (items.isEmpty) {
                          return const Center(
                            child: Text(
                              'لا توجد مهارات أخرى متاحة.',
                              style: TextStyle(
                                color:
                                    AppColors.textGrey,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(
                            16,
                            12,
                            16,
                            20,
                          ),
                          itemCount: items.length,
                          separatorBuilder: (
                            context,
                            index,
                          ) {
                            return const SizedBox(
                              height: 8,
                            );
                          },
                          itemBuilder: (
                            context,
                            index,
                          ) {
                            final item = items[index];

                            return ListTile(
                              tileColor:
                                  AppColors.background,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  15,
                                ),
                              ),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration:
                                    BoxDecoration(
                                  color: AppColors
                                      .primaryBlue
                                      .withOpacity(0.08),
                                  borderRadius:
                                      BorderRadius.circular(
                                    12,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: AppColors
                                      .primaryBlue,
                                ),
                              ),
                              title: Text(
                                item.name,
                                style: const TextStyle(
                                  color:
                                      AppColors.textDark,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                              subtitle:
                                  item.category.trim().isEmpty
                                      ? null
                                      : Text(
                                          item.category,
                                        ),
                              onTap: () {
                                Navigator.pop(
                                  sheetContext,
                                  item,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (skill != null) {
      controller.addSkill(skill);
    }
  }

  static String? _required(
    String? value,
    String message,
  ) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  static String? _amount(String? value) {
    final amount = double.tryParse(
      value?.trim() ?? '',
    );

    if (amount == null || amount < 0) {
      return 'أدخل رقمًا صحيحًا';
    }

    return null;
  }
}
