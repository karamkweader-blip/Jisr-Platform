import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/interviews/student_interview_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/student_bottom_nav.dart';
import 'package:jisr_platform/models/student/interviews/student_interview_model.dart';

class StudentInterviewsView extends GetView<StudentInterviewController> {
  const StudentInterviewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: const StudentBottomNav(currentIndex: 2),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.primaryBlue),
          title: const Text(
            'مقابلاتي',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Obx(
              () => IconButton(
                tooltip: 'تحديث المقابلات',
                onPressed: controller.isLoading.value
                    ? null
                    : controller.fetchInterviews,
                icon: controller.isLoading.value
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          color: AppColors.actionYellow,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.actionYellow,
                      ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
                child: const _InterviewsHero()
                    .animate()
                    .fadeIn(duration: 450.ms)
                    .slideY(begin: .14, curve: Curves.easeOutCubic),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const _InterviewFilters(),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.interviews.isEmpty) {
                    return const _InterviewsLoading();
                  }

                  if (controller.loadError.value.isNotEmpty &&
                      controller.interviews.isEmpty) {
                    return _InterviewsError(
                      message: controller.loadError.value,
                      onRetry: controller.fetchInterviews,
                    );
                  }

                  final interviews = controller.filteredInterviews;
                  return RefreshIndicator(
                    color: AppColors.actionYellow,
                    onRefresh: controller.fetchInterviews,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      itemCount: interviews.isEmpty ? 2 : interviews.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 13),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 1),
                            child: Text(
                              controller.currentTitle,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                color: AppColors.primaryBlue,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }

                        if (interviews.isEmpty) {
                          return _EmptyInterviews(
                            filter: controller.selectedFilter.value,
                          );
                        }

                        return _InterviewCard(interview: interviews[index - 1])
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 55 * (index - 1)),
                              duration: 380.ms,
                            )
                            .slideY(begin: .12, curve: Curves.easeOutCubic);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InterviewsHero extends StatelessWidget {
  const _InterviewsHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryBlue, Color(0xFF0077B6)],
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        children: [
          _HeroIcon(),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'استعد للخطوة القادمة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'تابع مواعيد مقابلاتك وتفاصيل الاجتماع من مكان واحد.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white70,
                    fontSize: 11.5,
                    height: 1.55,
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

class _HeroIcon extends StatelessWidget {
  const _HeroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.18)),
      ),
      child: const Icon(
        Icons.event_available_rounded,
        color: AppColors.actionYellow,
        size: 33,
      ),
    );
  }
}

class _InterviewFilters extends GetView<StudentInterviewController> {
  const _InterviewFilters();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _FilterButton(
              label: 'الكل',
              count: controller.interviews.length,
              icon: Icons.view_agenda_outlined,
              filter: StudentInterviewFilter.all,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _FilterButton(
              label: 'القادمة',
              count: controller.upcomingCount,
              icon: Icons.upcoming_outlined,
              filter: StudentInterviewFilter.upcoming,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _FilterButton(
              label: 'السجل',
              count: controller.historyCount,
              icon: Icons.history_rounded,
              filter: StudentInterviewFilter.history,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends GetView<StudentInterviewController> {
  final String label;
  final int count;
  final IconData icon;
  final StudentInterviewFilter filter;

  const _FilterButton({
    required this.label,
    required this.count,
    required this.icon,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedFilter.value == filter;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => controller.selectFilter(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 11),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? AppColors.primaryBlue
                  : AppColors.primaryBlue.withOpacity(.09),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(selected ? .12 : .04),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? AppColors.actionYellow : AppColors.primaryBlue,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: selected ? Colors.white : AppColors.primaryBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                constraints: const BoxConstraints(minWidth: 20),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withOpacity(.15)
                      : AppColors.primaryBlue.withOpacity(.08),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: selected ? Colors.white : AppColors.primaryBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InterviewCard extends GetView<StudentInterviewController> {
  final StudentInterviewModel interview;

  const _InterviewCard({required this.interview});

  Color get statusColor {
    switch (interview.status) {
      case 'scheduled':
        return interview.hasPassed ? AppColors.textGrey : AppColors.primaryBlue;
      case 'rescheduled':
        return interview.hasPassed ? AppColors.textGrey : AppColors.actionYellow;
      case 'completed':
        return const Color(0xFF2A9D8F);
      case 'cancelled':
        return const Color(0xFFE76F51);
      default:
        return AppColors.textGrey;
    }
  }

  IconData get statusIcon {
    switch (interview.status) {
      case 'scheduled':
        return interview.hasPassed
            ? Icons.history_rounded
            : Icons.event_available_rounded;
      case 'rescheduled':
        return interview.hasPassed
            ? Icons.history_rounded
            : Icons.update_rounded;
      case 'completed':
        return Icons.task_alt_rounded;
      case 'cancelled':
        return Icons.event_busy_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: statusColor.withOpacity(.16)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(.11),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(statusIcon, color: statusColor, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      interview.opportunity.title.isEmpty
                          ? 'فرصة عمل'
                          : interview.opportunity.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.primaryBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.companyName(interview.company),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textGrey,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(
                text: controller.statusLabel(interview),
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 15),
          _InterviewInfoRow(
            icon: Icons.schedule_rounded,
            label: 'الموعد',
            value: controller.scheduledDateText(interview.scheduledAt),
            color: AppColors.actionYellow,
          ),
          const SizedBox(height: 10),
          _InterviewInfoRow(
            icon: _meetingIcon(interview.meetingType),
            label: 'نوع المقابلة',
            value: controller.meetingTypeLabel(interview.meetingType),
            color: AppColors.primaryBlue,
          ),
          if (interview.meetingType == 'onsite' &&
              interview.location != null) ...[
            const SizedBox(height: 10),
            _InterviewInfoRow(
              icon: Icons.location_on_outlined,
              label: 'المكان',
              value: interview.location!,
              color: const Color(0xFF2A9D8F),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 7,
            children: [
              _SmallChip(
                icon: Icons.category_outlined,
                text: controller.opportunityTypeLabel(
                  interview.opportunity.type,
                ),
                color: AppColors.primaryBlue,
              ),
              if (interview.company.industry.isNotEmpty)
                _SmallChip(
                  icon: Icons.business_center_outlined,
                  text: interview.company.industry,
                  color: AppColors.textGrey,
                ),
            ],
          ),
          if (interview.notes.isNotEmpty) ...[
            const SizedBox(height: 13),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(.06),
                ),
              ),
              child: Text(
                interview.notes,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textDark,
                  fontSize: 11,
                  height: 1.55,
                ),
              ),
            ),
          ],
          if (interview.canJoinOnlineMeeting) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => FilledButton.icon(
                  onPressed: controller.isOpeningLink.value
                      ? null
                      : () => controller.openMeetingLink(interview),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: controller.isOpeningLink.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.video_call_rounded),
                  label: const Text(
                    'الدخول إلى المقابلة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _meetingIcon(String type) {
    switch (type) {
      case 'online':
        return Icons.videocam_outlined;
      case 'onsite':
        return Icons.location_on_outlined;
      case 'phone':
        return Icons.phone_outlined;
      default:
        return Icons.handshake_outlined;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 92),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Cairo',
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InterviewInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InterviewInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(.09),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 19, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textGrey,
                  fontSize: 9.5,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textDark,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmallChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _SmallChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: color,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InterviewsLoading extends StatelessWidget {
  const _InterviewsLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.actionYellow),
          SizedBox(height: 13),
          Text(
            'جاري جلب المقابلات...',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InterviewsError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _InterviewsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.actionYellow,
              size: 58,
            ),
            const SizedBox(height: 13),
            const Text(
              'تعذر جلب المقابلات',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textGrey,
                fontSize: 11,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
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

class _EmptyInterviews extends StatelessWidget {
  final StudentInterviewFilter filter;

  const _EmptyInterviews({required this.filter});

  @override
  Widget build(BuildContext context) {
    final message = switch (filter) {
      StudentInterviewFilter.all => 'لا توجد مقابلات مرتبطة بحسابك حالياً.',
      StudentInterviewFilter.upcoming => 'لا توجد مقابلات قادمة في الوقت الحالي.',
      StudentInterviewFilter.history => 'لا توجد مقابلات سابقة حتى الآن.',
    };

    return Padding(
      padding: const EdgeInsets.only(top: 55),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: AppColors.actionYellow,
              size: 40,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
