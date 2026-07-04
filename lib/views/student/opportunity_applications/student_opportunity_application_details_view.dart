import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/student/opportunity_applications/student_opportunity_application_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/student/opportunity_applications/student_opportunity_application_model.dart';

class StudentOpportunityApplicationDetailsView extends StatefulWidget {
  const StudentOpportunityApplicationDetailsView({super.key});

  @override
  State<StudentOpportunityApplicationDetailsView> createState() =>
      _StudentOpportunityApplicationDetailsViewState();
}

class _StudentOpportunityApplicationDetailsViewState
    extends State<StudentOpportunityApplicationDetailsView> {
  final StudentOpportunityApplicationController controller =
      Get.find<StudentOpportunityApplicationController>();

  @override
  void initState() {
    super.initState();

    final applicationId = Get.arguments as int;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchApplicationDetails(applicationId);
    });
  }

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
            'تفاصيل طلب التقديم',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoadingDetails.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.actionYellow),
            );
          }

          final application = controller.selectedApplication.value;

          if (application == null) {
            return const Center(
              child: Text(
                'لم يتم العثور على طلب التقديم',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textGrey,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
            child: Column(
              children: [
                _ApplicationDetailsHero(application: application)
                    .animate()
                    .fadeIn(duration: 520.ms)
                    .slideY(begin: .20, curve: Curves.easeOutBack),
                const SizedBox(height: 16),
                _DetailsInfoCard(
                  icon: Icons.mail_rounded,
                  title: 'رسالة التقديم',
                  value: application.coverLetter,
                ).animate().fadeIn(delay: 90.ms).slideX(begin: .16),
                _DetailsInfoCard(
                  icon: Icons.business_rounded,
                  title: 'الشركة',
                  value:
                      '${controller.companyName(application.opportunity.company)}\n${application.opportunity.company.industry}',
                ).animate().fadeIn(delay: 150.ms).slideX(begin: .16),
                _ApplicationDetailsGrid(application: application)
                    .animate()
                    .fadeIn(delay: 220.ms)
                    .slideY(begin: .16),
                if (application.matchReasons.isNotEmpty)
                  _MatchReasonsCard(reasons: application.matchReasons)
                      .animate()
                      .fadeIn(delay: 290.ms)
                      .slideY(begin: .16),
                if ((application.reviewerNotes ?? '').trim().isNotEmpty)
                  _DetailsInfoCard(
                    icon: Icons.rate_review_rounded,
                    title: 'ملاحظات المراجع',
                    value: application.reviewerNotes ?? '',
                  ).animate().fadeIn(delay: 350.ms).slideY(begin: .16),
                const SizedBox(height: 18),
                if (application.status == 'pending')
                  _WithdrawButton(applicationId: application.id)
                      .animate()
                      .fadeIn(delay: 410.ms)
                      .slideY(begin: .18),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ApplicationDetailsHero
    extends GetView<StudentOpportunityApplicationController> {
  final StudentOpportunityApplicationModel application;

  const _ApplicationDetailsHero({required this.application});

  Color get statusColor {
    switch (application.status) {
      case 'pending':
        return AppColors.actionYellow;
      case 'withdrawn':
        return Colors.redAccent;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.redAccent;
      default:
        return AppColors.actionYellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final opportunity = application.opportunity;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(31),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryBlue, Color(0xFF0077B6)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.20),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.14),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Icon(
                  opportunity.type == 'job'
                      ? Icons.work_rounded
                      : Icons.school_rounded,
                  color: AppColors.actionYellow,
                  size: 31,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.06, 1.06),
                    duration: 1700.ms,
                  ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.title,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: 18.5,
                        fontWeight: FontWeight.bold,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      controller.companyName(opportunity.company),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white70,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _HeroStatusChip(
                icon: Icons.flag_rounded,
                text: controller.displayStatusText(application.displayStatus),
                color: statusColor,
              ),
              _HeroStatusChip(
                icon: Icons.star_rounded,
                text:
                    'تطابق ${application.matchScore.isEmpty ? 'غير محدد' : application.matchScore}',
                color: AppColors.actionYellow,
              ),
              _HeroStatusChip(
                icon: Icons.category_rounded,
                text: controller.opportunityTypeLabel(opportunity.type),
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStatusChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _HeroStatusChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: color == Colors.white ? Colors.white : color,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailsInfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final shownValue = value.trim().isEmpty ? 'غير محدد' : value;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.actionYellow),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  shownValue,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textDark,
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

class _ApplicationDetailsGrid
    extends GetView<StudentOpportunityApplicationController> {
  final StudentOpportunityApplicationModel application;

  const _ApplicationDetailsGrid({required this.application});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 11,
      mainAxisSpacing: 11,
      childAspectRatio: 1.18,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _MiniDetailsCard(
          icon: Icons.event_rounded,
          title: 'تاريخ التقديم',
          value: controller.dateOnly(application.appliedAt),
        ),
        _MiniDetailsCard(
          icon: Icons.calendar_month_rounded,
          title: 'موعد الفرصة',
          value: controller.dateOnly(application.opportunity.deadline),
        ),
        _MiniDetailsCard(
          icon: Icons.info_rounded,
          title: 'حالة الفرصة',
          value: application.opportunity.status,
        ),
        _MiniDetailsCard(
          icon: Icons.badge_rounded,
          title: 'رقم الطلب',
          value: '#${application.id}',
        ),
      ],
    );
  }
}

class _MiniDetailsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MiniDetailsCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.05),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.actionYellow, size: 24),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textGrey,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value.trim().isEmpty ? 'غير محدد' : value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchReasonsCard extends StatelessWidget {
  final List<String> reasons;

  const _MatchReasonsCard({required this.reasons});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 13),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: AppColors.actionYellow),
              SizedBox(width: 9),
              Text(
                'أسباب التطابق',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.primaryBlue,
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          ...reasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.actionYellow,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reason,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textDark,
                        height: 1.55,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WithdrawButton extends GetView<StudentOpportunityApplicationController> {
  final int applicationId;

  const _WithdrawButton({required this.applicationId});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ElevatedButton.icon(
        onPressed: controller.isWithdrawing.value
            ? null
            : () => _confirmWithdraw(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          disabledBackgroundColor: AppColors.textGrey.withOpacity(.25),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        icon: controller.isWithdrawing.value
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.undo_rounded),
        label: Text(
          controller.isWithdrawing.value ? 'جار سحب الطلب...' : 'سحب طلب التقديم',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmWithdraw(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'تأكيد سحب الطلب',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'سيتم تغيير حالة طلب التقديم إلى مسحوب.',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textDark,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'سحب الطلب',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) {
      await controller.withdrawApplication(applicationId);
    }
  }
}
