import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/mentor/student_mentor_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/jisr_primary_button.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/models/student/mentor/student_mentor_model.dart';

class StudentMentorView extends GetView<StudentMentorController> {
  const StudentMentorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: const StudentBottomNav(currentIndex: 0),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.primaryBlue),
          title: const Text(
            'المسار التدريبي',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 14),
                child: _MentorHero(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _MentorTabs(controller: controller),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: TabBarView(
                  controller: controller.tabController,
                  children: const [
                    _MentorApplicationTab(),
                    _MentorDiscoveryTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MentorHero extends StatelessWidget {
  const _MentorHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryBlue, Color(0xFF0077B6)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.16),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.school_rounded, color: AppColors.actionYellow, size: 38),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الإرشاد المهني',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'قدّم للانضمام كمرشد أو استكشف المرشدين المعتمدين.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MentorTabs extends StatelessWidget {
  final StudentMentorController controller;

  const _MentorTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(.08)),
      ),
      child: TabBar(
        controller: controller.tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.primaryBlue,
        labelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        indicator: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(17),
        ),
        tabs: const [
          Tab(text: 'التقديم كمرشد'),
          Tab(text: 'المرشدون'),
        ],
      ),
    );
  }
}

class _MentorApplicationTab extends GetView<StudentMentorController> {
  const _MentorApplicationTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isApplicationLoading.value &&
          controller.myApplication.value == null) {
        return const _MentorLoading();
      }

      if (controller.applicationLoadError.value.isNotEmpty) {
        return _MentorError(
          message: controller.applicationLoadError.value,
          onRetry: () => controller.loadMyApplication(showError: true),
        );
      }

      final application = controller.myApplication.value;
      if (application != null) {
        return RefreshIndicator(
          color: AppColors.actionYellow,
          onRefresh: controller.loadMyApplication,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            children: [_MentorApplicationStatus(application)],
          ),
        );
      }

      return const _MentorApplicationForm();
    });
  }
}

class _MentorApplicationForm extends GetView<StudentMentorController> {
  const _MentorApplicationForm();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.applicationFormKey,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.manual,
              cacheExtent: 1200,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
              children: [
          const _SectionTitle(
            title: 'بيانات طلب الانضمام كمرشد',
            subtitle: 'الاسم والبريد يؤخذان تلقائياً من الحساب.',
          ),
          const SizedBox(height: 14),
          Obx(
            () => DropdownButtonFormField<String>(
              value: controller.selectedApplicationSpecialization.value.isEmpty
                  ? null
                  : controller.selectedApplicationSpecialization.value,
              items: MentorSpecializations.values
                  .map(
                    (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(MentorSpecializations.label(value)),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  controller.selectedApplicationSpecialization.value =
                      value ?? '',
              validator: controller.specializationValidator,
              decoration: _fieldDecoration(
                'التخصص',
                Icons.category_outlined,
              ),
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textDark,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _MentorField(
            controller: controller.professionalTitleController,
            label: 'المسمى المهني',
            icon: Icons.badge_outlined,
            validator: (value) =>
                controller.requiredText(value, 'المسمى المهني', 255),
          ),
          _MentorField(
            controller: controller.expertiseController,
            label: 'الخبرات',
            icon: Icons.workspace_premium_outlined,
            maxLines: 4,
            validator: (value) =>
                controller.requiredText(value, 'الخبرات', 5000),
          ),
          _MentorField(
            controller: controller.bioController,
            label: 'نبذة شخصية',
            icon: Icons.person_outline_rounded,
            maxLines: 4,
            validator: (value) =>
                controller.requiredText(value, 'النبذة الشخصية', 3000),
          ),
          _MentorField(
            controller: controller.linkedinController,
            label: 'رابط LinkedIn',
            icon: Icons.link_rounded,
            validator: (value) =>
                controller.urlValidator(value, 'رابط LinkedIn'),
          ),
          _MentorField(
            controller: controller.portfolioController,
            label: 'رابط GitHub أو Portfolio',
            icon: Icons.code_rounded,
            validator: (value) => controller.urlValidator(
              value,
              'رابط GitHub أو Portfolio',
            ),
          ),
          _MentorField(
            controller: controller.whatsappController,
            label: 'رقم WhatsApp',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            validator: (value) =>
                controller.requiredText(value, 'رقم WhatsApp', 50),
          ),
          const SizedBox(height: 2),
          const Text(
            'مواضيع الإرشاد',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 7,
              children: MentorTopics.values.map((topic) {
                final selected =
                    controller.selectedMentoringTopics.contains(topic);
                return FilterChip(
                  selected: selected,
                  label: Text(MentorTopics.label(topic)),
                  onSelected: (_) => controller.toggleMentoringTopic(topic),
                  selectedColor: AppColors.primaryBlue.withOpacity(.14),
                  checkmarkColor: AppColors.primaryBlue,
                  labelStyle: TextStyle(
                    fontFamily: 'Cairo',
                    color: selected
                        ? AppColors.primaryBlue
                        : AppColors.textDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _CvPicker(controller: controller),
                const SizedBox(height: 8),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: Obx(
                () => JisrPrimaryButton(
                  text: 'إرسال طلب الانضمام كمرشد',
                  icon: Icons.send_rounded,
                  isLoading: controller.isSubmittingApplication.value,
                  onPressed: controller.isSubmittingApplication.value
                      ? null
                      : () => controller.submitApplication(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CvPicker extends StatelessWidget {
  final StudentMentorController controller;

  const _CvPicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final file = controller.selectedCv.value;
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(.11)),
        ),
        child: file == null
            ? Row(
                children: [
                  const Expanded(
                    child: Text(
                      'السيرة الذاتية: PDF أو DOCX، بحد أقصى 5 MB',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textGrey,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: controller.pickCv,
                    icon: const Icon(Icons.upload_file_rounded),
                    label: const Text(
                      'اختيار ملف',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  const Icon(
                    Icons.description_rounded,
                    color: AppColors.actionYellow,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      file.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'إزالة الملف',
                    onPressed: controller.removeCv,
                    icon: const Icon(Icons.close_rounded, color: Colors.red),
                  ),
                ],
              ),
      );
    });
  }
}

class _MentorApplicationStatus
    extends GetView<StudentMentorController> {
  final MentorApplicationModel application;

  const _MentorApplicationStatus(this.application);

  Color get statusColor {
    switch (application.status) {
      case MentorApplicationStatuses.approved:
        return Colors.green;
      case MentorApplicationStatuses.rejected:
        return Colors.red;
      default:
        return AppColors.actionYellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: statusColor.withOpacity(.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fact_check_outlined, color: statusColor, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'حالة الطلب: ${MentorApplicationStatuses.label(application.status)}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: statusColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StatusInfo(label: 'الاسم', value: application.fullName),
          _StatusInfo(label: 'البريد', value: application.email),
          _StatusInfo(
            label: 'التخصص',
            value: MentorSpecializations.label(application.specialization),
          ),
          _StatusInfo(
            label: 'المسمى المهني',
            value: application.professionalTitle,
          ),
          _StatusInfo(label: 'الخبرات', value: application.expertise),
          _StatusInfo(label: 'النبذة', value: application.bio),
          _StatusInfo(label: 'WhatsApp', value: application.whatsappNumber),
          _StatusInfo(
            label: 'مواضيع الإرشاد',
            value: application.mentoringTopics
                .map(MentorTopics.label)
                .join('، '),
          ),
          _StatusInfo(
            label: 'تاريخ التقديم',
            value: controller.dateTimeText(application.createdAt),
          ),
          if (application.rejectionReason != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(.07),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'سبب الرفض: ${application.rejectionReason}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.red,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MentorDiscoveryTab extends GetView<StudentMentorController> {
  const _MentorDiscoveryTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Column(
            children: [
              TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: _fieldDecoration(
                  'ابحث بالاسم أو البريد الكامل',
                  Icons.search_rounded,
                ).copyWith(
                  suffixIcon: Obx(
                    () => controller.searchQuery.value.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            onPressed: () {
                              controller.searchController.clear();
                              controller.onSearchChanged('');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: controller.selectedMentorSpecialization.value,
                  items: <DropdownMenuItem<String>>[
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('كل التخصصات'),
                    ),
                    ...MentorSpecializations.values.map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(MentorSpecializations.label(value)),
                      ),
                    ),
                  ],
                  onChanged: controller.selectMentorSpecialization,
                  decoration: _fieldDecoration(
                    'تصفية حسب التخصص',
                    Icons.filter_alt_outlined,
                  ),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textDark,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isMentorsLoading.value &&
                controller.mentors.isEmpty) {
              return const _MentorLoading();
            }
            if (!controller.mentorsRequestSucceeded.value &&
                controller.mentors.isEmpty) {
              return _MentorError(
                message: controller.mentorsLoadError.value.isEmpty
                    ? 'تعذر جلب المرشدين من الخادم'
                    : controller.mentorsLoadError.value,
                onRetry: controller.fetchMentors,
              );
            }
            if (controller.mentorsRequestSucceeded.value &&
                controller.mentors.isEmpty) {
              return RefreshIndicator(
                color: AppColors.actionYellow,
                onRefresh: controller.fetchMentors,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 90),
                    Icon(
                      Icons.supervisor_account_outlined,
                      size: 62,
                      color: AppColors.actionYellow,
                    ),
                    SizedBox(height: 14),
                    Text(
                      'لا يوجد مرشدون مطابقون حالياً',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }

            final contextData = controller.recommendationContext.value;
            return RefreshIndicator(
              color: AppColors.actionYellow,
              onRefresh: controller.fetchMentors,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 28),
                itemCount: controller.mentors.length +
                    (controller.hasMoreMentors ? 1 : 0) +
                    (contextData != null && contextData.careerPath.isNotEmpty
                        ? 1
                        : 0),
                itemBuilder: (context, index) {
                  final hasContext = contextData != null &&
                      contextData.careerPath.isNotEmpty;
                  if (hasContext && index == 0) {
                    return _RecommendationContext(contextData!);
                  }
                  final mentorIndex = index - (hasContext ? 1 : 0);
                  if (mentorIndex == controller.mentors.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Obx(
                        () => OutlinedButton(
                          onPressed: controller.isLoadingMoreMentors.value
                              ? null
                              : () => controller.fetchMentors(loadMore: true),
                          child: controller.isLoadingMoreMentors.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryBlue,
                                  ),
                                )
                              : const Text(
                                  'تحميل المزيد',
                                  style: TextStyle(fontFamily: 'Cairo'),
                                ),
                        ),
                      ),
                    );
                  }
                  return _MentorCard(controller.mentors[mentorIndex]);
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _RecommendationContext extends StatelessWidget {
  final MentorRecommendationContextModel contextData;

  const _RecommendationContext(this.contextData);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'ترشيحات المسار: ${contextData.careerPath}',
        style: const TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.primaryBlue,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MentorCard extends GetView<StudentMentorController> {
  final StudentMentorModel mentor;

  const _MentorCard(this.mentor);

  @override
  Widget build(BuildContext context) {
    final recommendation = mentor.recommendation;
    return InkWell(
      onTap: () => controller.openMentorDetails(mentor.id),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: recommendation.isRecommended
                ? AppColors.actionYellow.withOpacity(.45)
                : AppColors.primaryBlue.withOpacity(.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryBlue.withOpacity(.09),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mentor.fullName,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.primaryBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        mentor.professionalTitle,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textGrey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.actionYellow,
                  size: 17,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _Badge(
                  text: MentorSpecializations.label(mentor.specialization),
                  color: AppColors.primaryBlue,
                ),
                if (recommendation.isRecommended)
                  const _Badge(
                    text: 'موصى به لك',
                    color: AppColors.actionYellow,
                  ),
                if (recommendation.specializationMatch)
                  const _Badge(
                    text: 'نفس التخصص',
                    color: Colors.green,
                  ),
                if (recommendation.matchingSkillCount > 0)
                  _Badge(
                    text:
                        '${recommendation.matchingSkillCount} مهارات متطابقة',
                    color: Colors.teal,
                  ),
              ],
            ),
            if (recommendation.matchingSkills.isNotEmpty) ...[
              const SizedBox(height: 9),
              Text(
                recommendation.matchingSkills
                    .map((skill) => skill.name)
                    .join('، '),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textDark,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Cairo',
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MentorField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?) validator;

  const _MentorField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: validator,
        autovalidateMode: AutovalidateMode.disabled,
        onFieldSubmitted: (_) {
          if (textInputAction == TextInputAction.done) {
            FocusScope.of(context).unfocus();
          } else {
            FocusScope.of(context).nextFocus();
          }
        },
        style: const TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.textDark,
          fontSize: 13,
        ),
        decoration: _fieldDecoration(label, icon),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.primaryBlue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.textGrey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _StatusInfo extends StatelessWidget {
  final String label;
  final String value;

  const _StatusInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textGrey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'غير محدد' : value,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textDark,
                fontSize: 10,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MentorLoading extends StatelessWidget {
  const _MentorLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.actionYellow),
    );
  }
}

class _MentorError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _MentorError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textDark,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
    prefixIcon: Icon(icon, color: AppColors.primaryBlue),
    filled: true,
    fillColor: AppColors.cardWhite,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: AppColors.primaryBlue.withOpacity(.08),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primaryBlue),
    ),
  );
}
