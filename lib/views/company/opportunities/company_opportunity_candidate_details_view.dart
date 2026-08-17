import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/opportunities/company_opportunity_candidate_details_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_candidate_model.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyOpportunityCandidateDetailsView extends GetView<CompanyOpportunityCandidateDetailsController> {
  const CompanyOpportunityCandidateDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.close();
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(leading: IconButton(onPressed: controller.close, icon: const Icon(Icons.arrow_back_ios_new_rounded)), title: const Text('تفاصيل المرشح')),
          body: Obx(() {
            if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
            if (controller.errorMessage.value.isNotEmpty) return _Error(message: controller.errorMessage.value, onRetry: controller.fetchCandidate);
            final item = controller.candidate.value;
            if (item == null) return const _Error(message: 'لا توجد بيانات للمرشح');
            return RefreshIndicator(
              onRefresh: controller.fetchCandidate,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  _profile(item),
                  const SizedBox(height: 12),
                  _section('طلب التقديم', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.coverLetter.isEmpty ? 'لا توجد رسالة تعريفية' : item.coverLetter, style: const TextStyle(height: 1.6)),
                    if (item.cv?.fileUrl.isNotEmpty == true) ...[
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => _openUrl(item.cv!.fileUrl, 'رابط السيرة الذاتية'),
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('عرض السيرة الذاتية'),
                      ),
                    ],
                    if (item.matchReasons.isNotEmpty) ...[const SizedBox(height: 10), ...item.matchReasons.map((reason) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check_circle_outline, size: 18, color: AppColors.primaryBlue), const SizedBox(width: 7), Expanded(child: Text(reason))])))]
                  ])),
                  if (item.interview != null) _interview(item),
                  if (item.interview == null && item.actions.canScheduleInterview)
                    FilledButton.icon(onPressed: () => controller.openInterviewForm(), icon: const Icon(Icons.event_available_outlined), label: const Text('جدولة مقابلة')),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _profile(CompanyOpportunityCandidate item) => Card(
    elevation: 0,
    color: AppColors.cardWhite,
    child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
      CircleAvatar(radius: 34, backgroundImage: item.student.profilePictureUrl?.isNotEmpty == true ? NetworkImage(item.student.profilePictureUrl!) : null, child: item.student.profilePictureUrl?.isNotEmpty == true ? null : Text(item.student.name.isEmpty ? '؟' : item.student.name[0], style: const TextStyle(fontSize: 22))),
      const SizedBox(height: 10), Text(item.student.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), Text(item.student.email, style: const TextStyle(color: AppColors.textGrey)),
      if (item.student.university.isNotEmpty || item.student.major.isNotEmpty) Text('${item.student.major} • ${item.student.university}', textAlign: TextAlign.center),
      if (item.matchScore != null) Padding(padding: const EdgeInsets.only(top: 10), child: Chip(label: Text('التطابق ${item.matchScore!.round()}%'))),
    ])),
  );

  Widget _interview(CompanyOpportunityCandidate item) {
    final interview = item.interview!;
    return _section('المقابلة', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _line('الحالة', controller.statusLabel(interview.status)),
      _line('النوع', controller.meetingTypeLabel(interview.meetingType)),
      _line('الموعد', controller.formatDate(interview.scheduledAt)),
      if (interview.meetingLink?.isNotEmpty == true) _line('الرابط', interview.meetingLink!),
      if (interview.location?.isNotEmpty == true) _line('الموقع', interview.location!),
      if (interview.notes.isNotEmpty) _line('ملاحظات', interview.notes),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        if (interview.meetingLink?.isNotEmpty == true) OutlinedButton.icon(onPressed: () => _openUrl(interview.meetingLink!, 'رابط المقابلة'), icon: const Icon(Icons.open_in_new_rounded), label: const Text('فتح رابط المقابلة')),
        if (interview.canReschedule) OutlinedButton.icon(onPressed: () => controller.openInterviewForm(reschedule: true), icon: const Icon(Icons.edit_calendar_outlined), label: const Text('إعادة الجدولة')),
        if (interview.canComplete) FilledButton.icon(onPressed: controller.isActing.value ? null : controller.completeInterview, icon: const Icon(Icons.check_rounded), label: const Text('إكمال')),
        if (interview.canCancel) TextButton.icon(onPressed: controller.isActing.value ? null : controller.cancelInterview, icon: const Icon(Icons.cancel_outlined, color: Colors.red), label: const Text('إلغاء', style: TextStyle(color: Colors.red))),
      ]),
    ]));
  }

  Widget _section(String title, Widget child) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Card(elevation: 0, color: AppColors.cardWhite, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 10), child]))));
  Widget _line(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 75, child: Text(label, style: const TextStyle(color: AppColors.textGrey))), Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700)))]));

  Future<void> _openUrl(String value, String label) async {
    final uri = Uri.tryParse(value);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar('تعذر الفتح', '$label غير صالح');
    }
  }
}

class _Error extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _Error({required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(message), if (onRetry != null) TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة'))]));
}
