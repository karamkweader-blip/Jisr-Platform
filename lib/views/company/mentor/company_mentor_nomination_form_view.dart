import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/mentor/company_mentor_nomination_form_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/company/jisr_button.dart';
import 'package:jisr_platform/models/company/mentor/company_mentor_constants.dart';

class CompanyMentorNominationFormView
    extends GetView<CompanyMentorNominationFormController> {
  const CompanyMentorNominationFormView({super.key});

  @override
  Widget build(BuildContext context) {
    // يتم إنشاء الـScaffold مرة واحدة.
    // عند تغير isSubmitting يتحدث PopScope فقط ولا يعاد بناء الفورم كله.
    final scaffold = Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.cardWhite,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: AppColors.primaryBlue,
        ),
        title: const Text(
          'ترشيح مرشد جديد',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Form(
          key: controller.formKey,
          child: ListView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              18,
              16,
              18,
              30,
            ),
            children: <Widget>[
              const _FormHeader(),
              const SizedBox(height: 16),
              _FormSection(
                number: '01',
                title: 'بيانات المرشح',
                subtitle:
                    'معلومات التواصل الأساسية للموظف',
                child: Column(
                  children: <Widget>[
                    _MentorFormField(
                      controller:
                          controller.fullNameController,
                      label: 'الاسم الكامل',
                      hint: 'مثال: أحمد علي',
                      maxLength: 255,
                      textInputAction:
                          TextInputAction.next,
                      onChanged: (_) {
                        controller.clearFieldError(
                          'full_name',
                        );
                      },
                      validator: (value) =>
                          controller.requiredText(
                        'full_name',
                        value,
                        'الاسم الكامل',
                        255,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _MentorFormField(
                      controller:
                          controller.emailController,
                      label: 'البريد الإلكتروني',
                      hint: 'employee@company.com',
                      maxLength: 254,
                      keyboardType:
                          TextInputType.emailAddress,
                      textInputAction:
                          TextInputAction.next,
                      textDirection: TextDirection.ltr,
                      onChanged: (_) {
                        controller.clearFieldError(
                          'email',
                        );
                      },
                      validator:
                          controller.emailValidator,
                    ),
                    const SizedBox(height: 15),
                    _MentorFormField(
                      controller:
                          controller.whatsappController,
                      label: 'رقم WhatsApp',
                      hint: '+963 999 999 999',
                      maxLength: 50,
                      keyboardType:
                          TextInputType.phone,
                      textInputAction:
                          TextInputAction.next,
                      textDirection: TextDirection.ltr,
                      onChanged: (_) {
                        controller.clearFieldError(
                          'whatsapp_number',
                        );
                      },
                      validator: (value) =>
                          controller.requiredText(
                        'whatsapp_number',
                        value,
                        'رقم WhatsApp',
                        50,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _FormSection(
                number: '02',
                title: 'الخبرة المهنية',
                subtitle:
                    'المجال والخبرة التي سيقدمها المرشد',
                child: Column(
                  children: <Widget>[
                    _SpecializationField(
                      controller: controller,
                    ),
                    const SizedBox(height: 15),
                    _MentorFormField(
                      controller: controller
                          .professionalTitleController,
                      label: 'المسمى المهني',
                      hint:
                          'مثال: Senior Backend Engineer',
                      maxLength: 255,
                      textInputAction:
                          TextInputAction.next,
                      onChanged: (_) {
                        controller.clearFieldError(
                          'professional_title',
                        );
                      },
                      validator: (value) =>
                          controller.requiredText(
                        'professional_title',
                        value,
                        'المسمى المهني',
                        255,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _MentorFormField(
                      controller:
                          controller.expertiseController,
                      label: 'الخبرات',
                      hint:
                          'اذكر التقنيات والمجالات والخبرات العملية التي يتقنها الموظف',
                      maxLength: 5000,
                      maxLines: 5,
                      onChanged: (_) {
                        controller.clearFieldError(
                          'expertise',
                        );
                      },
                      validator: (value) =>
                          controller.requiredText(
                        'expertise',
                        value,
                        'الخبرات',
                        5000,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _MentorFormField(
                      controller:
                          controller.bioController,
                      label: 'نبذة عن المرشد',
                      hint:
                          'نبذة مختصرة توضّح خبرته واهتمامه بمساعدة الطلاب',
                      maxLength: 3000,
                      maxLines: 5,
                      onChanged: (_) {
                        controller.clearFieldError(
                          'bio',
                        );
                      },
                      validator: (value) =>
                          controller.requiredText(
                        'bio',
                        value,
                        'النبذة',
                        3000,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _FormSection(
                number: '03',
                title: 'الملف المهني',
                subtitle:
                    'روابط مهنية تساعد الإدارة في المراجعة',
                child: Column(
                  children: <Widget>[
                    _MentorFormField(
                      controller:
                          controller.linkedinController,
                      label: 'رابط LinkedIn',
                      hint:
                          'https://linkedin.com/in/username',
                      maxLength: 2048,
                      keyboardType:
                          TextInputType.url,
                      textInputAction:
                          TextInputAction.next,
                      textDirection: TextDirection.ltr,
                      onChanged: (_) {
                        controller.clearFieldError(
                          'linkedin_url',
                        );
                      },
                      validator: (value) =>
                          controller.urlValidator(
                        'linkedin_url',
                        value,
                        'رابط LinkedIn',
                      ),
                    ),
                    const SizedBox(height: 15),
                    _MentorFormField(
                      controller:
                          controller.portfolioController,
                      label:
                          'رابط GitHub أو Portfolio',
                      hint:
                          'https://github.com/username',
                      maxLength: 2048,
                      keyboardType:
                          TextInputType.url,
                      textInputAction:
                          TextInputAction.done,
                      textDirection: TextDirection.ltr,
                      onChanged: (_) {
                        controller.clearFieldError(
                          'github_or_portfolio_url',
                        );
                      },
                      validator: (value) =>
                          controller.urlValidator(
                        'github_or_portfolio_url',
                        value,
                        'رابط GitHub أو Portfolio',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _FormSection(
                number: '04',
                title: 'مجالات الإرشاد',
                subtitle:
                    'اختر مجالًا واحدًا على الأقل',
                child: _MentoringTopicsSelector(
                  controller: controller,
                ),
              ),
              const SizedBox(height: 14),
              _FormSection(
                number: '05',
                title: 'السيرة الذاتية',
                subtitle:
                    'PDF أو DOCX، وبحجم لا يتجاوز 5 MB',
                child: _CvPicker(
                  controller: controller,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              18,
              11,
              18,
              14,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              border: Border(
                top: BorderSide(
                  color:
                      AppColors.textGrey.withOpacity(0.12),
                ),
              ),
            ),
            child: JisrButton(
              title: 'إرسال الترشيح للمراجعة',
              isLoading:
                  controller.isSubmitting.value,
              onPressed: controller.submit,
            ),
          ),
        ),
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Obx(
        () => PopScope(
          canPop: !controller.isSubmitting.value,
          child: scaffold,
        ),
      ),
    );
  }
}

class _FormHeader extends StatelessWidget {
  const _FormHeader();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.16),
                ),
              ),
              child: const Text(
                'طلب ترشيح جديد',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 13),
            const Text(
              'رشّح خبرة تستحق أن تُشارك',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'أدخل معلومات الموظف بدقة. سيصل الطلب إلى إدارة جسور للمراجعة دون إنشاء حساب للمرشح.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.82),
                fontSize: 11.5,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final Widget child;

  const _FormSection({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.textGrey.withOpacity(0.11),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue
                        .withOpacity(0.07),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Text(
                    number,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 10.8,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _SpecializationField extends StatelessWidget {
  final CompanyMentorNominationFormController controller;

  const _SpecializationField({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _FieldLabel(text: 'التخصص'),
          const SizedBox(height: 7),
          DropdownButtonFormField<String>(
            value:
                controller.selectedSpecialization.value.isEmpty
                    ? null
                    : controller
                        .selectedSpecialization.value,
            isExpanded: true,
            items: CompanyMentorSpecializations.values
                .map(
                  (specialization) =>
                      DropdownMenuItem<String>(
                    value: specialization,
                    child: Text(
                      CompanyMentorSpecializations.label(
                        specialization,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: controller.isSubmitting.value
                ? null
                : controller.selectSpecialization,
            validator:
                controller.specializationValidator,
            autovalidateMode:
                AutovalidateMode.onUserInteraction,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primaryBlue,
            ),
            decoration: _inputDecoration(
              hint:
                  'اختر المجال التقني للموظف',
            ),
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MentorFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLength;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextDirection? textDirection;
  final ValueChanged<String>? onChanged;
  final String? Function(String?) validator;

  const _MentorFormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.maxLength,
    required this.validator,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.textDirection,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _FieldLabel(text: label),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: maxLines > 1
              ? TextInputAction.newline
              : textInputAction,
          textDirection: textDirection,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
          validator: validator,
          autovalidateMode:
              AutovalidateMode.onUserInteraction,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 13.2,
            fontWeight: FontWeight.w600,
          ),
          decoration: _inputDecoration(
            hint: hint,
            alignLabelWithHint: maxLines > 1,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(text: text),
          const TextSpan(
            text: '  *',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ],
      ),
      style: const TextStyle(
        color: AppColors.textDark,
        fontSize: 11.7,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _MentoringTopicsSelector extends StatelessWidget {
  final CompanyMentorNominationFormController controller;

  const _MentoringTopicsSelector({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final error =
            controller.fieldErrors['mentoring_topics'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth =
                    (constraints.maxWidth - 9) / 2;

                return Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children:
                      CompanyMentorTopics.values.map((topic) {
                    final selected = controller
                        .selectedMentoringTopics
                        .contains(topic);

                    return SizedBox(
                      width: itemWidth,
                      child: _TopicOption(
                        topic: topic,
                        selected: selected,
                        enabled:
                            !controller.isSubmitting.value,
                        onTap: () {
                          controller.toggleMentoringTopic(
                            topic,
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            if (error != null) ...<Widget>[
              const SizedBox(height: 9),
              Text(
                error,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 10.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _TopicOption extends StatelessWidget {
  final String topic;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _TopicOption({
    required this.topic,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 180),
          constraints: const BoxConstraints(
            minHeight: 70,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryBlue.withOpacity(0.07)
                : AppColors.background,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected
                  ? AppColors.primaryBlue.withOpacity(0.48)
                  : AppColors.textGrey.withOpacity(0.12),
              width: selected ? 1.3 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      CompanyMentorTopics.label(topic),
                      style: TextStyle(
                        color: selected
                            ? AppColors.primaryBlue
                            : AppColors.textDark,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _topicDescription(topic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 9.6,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              AnimatedContainer(
                duration:
                    const Duration(milliseconds: 180),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryBlue
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.primaryBlue
                        : AppColors.textGrey
                            .withOpacity(0.35),
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _topicDescription(String value) {
    switch (value) {
      case CompanyMentorTopics.careerGuidance:
        return 'المسار والتطور المهني';

      case CompanyMentorTopics.projectReview:
        return 'ملاحظات عملية على المشاريع';

      case CompanyMentorTopics.interviewPreparation:
        return 'استعداد وتدريب للمقابلات';

      case CompanyMentorTopics.cvReview:
        return 'تحسين السيرة والملف المهني';

      default:
        return '';
    }
  }
}

class _CvPicker extends StatelessWidget {
  final CompanyMentorNominationFormController controller;

  const _CvPicker({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final file = controller.selectedCv.value;
        final error = controller.fieldErrors['cv'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: controller.isSubmitting.value
                    ? null
                    : controller.pickCv,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: file == null
                        ? AppColors.background
                        : AppColors.primaryBlue
                            .withOpacity(0.055),
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: error != null
                          ? Colors.red
                          : file == null
                              ? AppColors.textGrey
                                  .withOpacity(0.14)
                              : AppColors.primaryBlue
                                  .withOpacity(0.35),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Icon(
                          file == null
                              ? Icons.file_upload_outlined
                              : Icons.description_outlined,
                          color: AppColors.primaryBlue,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              file?.name ??
                                  'اختر ملف السيرة الذاتية',
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              file == null
                                  ? 'PDF أو DOCX — حتى 5 MB'
                                  : _fileSize(file.size),
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 10.3,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (file != null)
                        IconButton(
                          tooltip: 'إزالة الملف',
                          onPressed:
                              controller.isSubmitting.value
                                  ? null
                                  : controller.removeCv,
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.red,
                            size: 20,
                          ),
                        )
                      else
                        const Text(
                          'اختيار',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (error != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                error,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 10.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  static String _fileSize(int bytes) {
    final megabytes = bytes / (1024 * 1024);

    return '${megabytes.toStringAsFixed(
      megabytes < 1 ? 2 : 1,
    )} MB';
  }
}

InputDecoration _inputDecoration({
  required String hint,
  bool alignLabelWithHint = false,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide(
      color: AppColors.textGrey.withOpacity(0.14),
    ),
  );

  return InputDecoration(
    hintText: hint,
    alignLabelWithHint: alignLabelWithHint,
    filled: true,
    fillColor: AppColors.background,
    counterText: '',
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 15,
    ),
    hintStyle: TextStyle(
      color: AppColors.textGrey.withOpacity(0.66),
      fontSize: 11.5,
      fontWeight: FontWeight.w500,
    ),
    enabledBorder: border,
    disabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: const BorderSide(
        color: AppColors.primaryBlue,
        width: 1.4,
      ),
    ),
    errorBorder: border.copyWith(
      borderSide: const BorderSide(
        color: Colors.red,
      ),
    ),
    focusedErrorBorder: border.copyWith(
      borderSide: const BorderSide(
        color: Colors.red,
        width: 1.4,
      ),
    ),
    errorStyle: const TextStyle(
      color: Colors.red,
      fontSize: 10.5,
      fontWeight: FontWeight.w600,
    ),
  );
}