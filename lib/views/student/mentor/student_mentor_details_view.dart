import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/mentor/student_mentor_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/student/mentor/student_mentor_model.dart';

class StudentMentorDetailsView extends GetView<StudentMentorController> {
  const StudentMentorDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.primaryBlue),
          title: const Text(
            'تفاصيل المرشد',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isMentorDetailsLoading.value &&
              controller.selectedMentor.value == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.actionYellow),
            );
          }
          if (controller.mentorDetailsError.value.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      controller.mentorDetailsError.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: controller.retryMentorDetails,
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

          final mentor = controller.selectedMentor.value;
          if (mentor == null) return const SizedBox.shrink();
          return RefreshIndicator(
            color: AppColors.actionYellow,
            onRefresh: controller.retryMentorDetails,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                _MentorProfileHeader(mentor),
                const SizedBox(height: 14),
                _DetailsSection(
                  title: 'الخبرات',
                  child: Text(
                    mentor.expertise,
                    style: _bodyStyle,
                  ),
                ),
                const SizedBox(height: 12),
                _DetailsSection(
                  title: 'نبذة',
                  child: Text(mentor.bio, style: _bodyStyle),
                ),
                if (mentor.mentoringTopics.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _DetailsSection(
                    title: 'مواضيع الإرشاد',
                    child: Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: mentor.mentoringTopics
                          .map(
                            (topic) => _DetailChip(
                              MentorTopics.label(topic),
                              AppColors.primaryBlue,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
                if (mentor.skills.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _DetailsSection(
                    title: 'المهارات',
                    child: Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: mentor.skills
                          .map(
                            (skill) => _DetailChip(
                              skill.name,
                              AppColors.actionYellow,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
                if (mentor.recommendation.matchingSkills.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _DetailsSection(
                    title: 'المهارات المتطابقة مع مسارك',
                    child: Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: mentor.recommendation.matchingSkills
                          .map(
                            (skill) => _DetailChip(skill.name, Colors.green),
                          )
                          .toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _ContactSection(mentor),
              ],
            ),
          );
        }),
      ),
    );
  }
}

const TextStyle _bodyStyle = TextStyle(
  fontFamily: 'Cairo',
  color: AppColors.textDark,
  fontSize: 12,
  height: 1.6,
);

class _MentorProfileHeader extends StatelessWidget {
  final StudentMentorModel mentor;

  const _MentorProfileHeader(this.mentor);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryBlue, Color(0xFF0077B6)],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 33,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_rounded, color: Colors.white, size: 38),
          ),
          const SizedBox(height: 10),
          Text(
            mentor.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            mentor.professionalTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 7,
            runSpacing: 7,
            children: [
              _HeaderChip(
                MentorSpecializations.label(mentor.specialization),
              ),
              if (mentor.recommendation.isRecommended)
                const _HeaderChip('موصى به لك'),
              if (mentor.recommendation.specializationMatch)
                const _HeaderChip('نفس التخصص'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String text;

  const _HeaderChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Cairo',
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailsSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String text;
  final Color color;

  const _DetailChip(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Cairo',
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ContactSection extends GetView<StudentMentorController> {
  final StudentMentorModel mentor;

  const _ContactSection(this.mentor);

  @override
  Widget build(BuildContext context) {
    return _DetailsSection(
      title: 'التواصل',
      child: Column(
        children: [
          if (mentor.email.isNotEmpty)
            _ContactButton(
              icon: Icons.email_outlined,
              label: mentor.email,
              onPressed: () => controller.openEmail(mentor.email),
            ),
          if (mentor.whatsappNumber.isNotEmpty)
            _ContactButton(
              icon: Icons.phone_outlined,
              label: mentor.whatsappNumber,
              onPressed: () =>
                  controller.openWhatsapp(mentor.whatsappNumber),
            ),
          if (mentor.linkedinUrl.isNotEmpty)
            _ContactButton(
              icon: Icons.link_rounded,
              label: 'LinkedIn',
              onPressed: () => controller.openWebLink(mentor.linkedinUrl),
            ),
          if (mentor.githubOrPortfolioUrl.isNotEmpty)
            _ContactButton(
              icon: Icons.code_rounded,
              label: 'GitHub / Portfolio',
              onPressed: () =>
                  controller.openWebLink(mentor.githubOrPortfolioUrl),
            ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.actionYellow),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.textDark,
          fontSize: 11,
        ),
      ),
      trailing: const Icon(
        Icons.open_in_new_rounded,
        color: AppColors.primaryBlue,
        size: 18,
      ),
      onTap: onPressed,
    );
  }
}
