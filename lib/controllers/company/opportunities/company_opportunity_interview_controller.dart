import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_interview_model.dart';
import 'package:jisr_platform/services/company/opportunities/company_opportunity_interview_service.dart';

class CompanyOpportunityInterviewController extends GetxController {
  final CompanyOpportunityInterviewService _service;

  CompanyOpportunityInterviewController(this._service);

  final formKey = GlobalKey<FormState>();
  final linkController = TextEditingController();
  final locationController = TextEditingController();
  final notesController = TextEditingController();
  final meetingType = 'online'.obs;
  final scheduledAt = Rxn<DateTime>();
  final isSubmitting = false.obs;
  late final int opportunityId;
  late final int applicationId;
  int? interviewId;

  bool get isReschedule => interviewId != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    opportunityId = args is Map
        ? int.tryParse(args['opportunityId']?.toString() ?? '') ?? 0
        : 0;
    applicationId = args is Map
        ? int.tryParse(args['applicationId']?.toString() ?? '') ?? 0
        : 0;
    final raw = args is Map ? args['interview'] : null;
    if (args is Map && args['mode'] == 'reschedule' && raw is Map) {
      final interview = CompanyOpportunityInterview.fromJson(
        Map<String, dynamic>.from(raw),
      );
      interviewId = interview.id;
      meetingType.value = const {'online', 'onsite', 'phone'}.contains(interview.meetingType)
          ? interview.meetingType
          : 'online';
      scheduledAt.value = interview.scheduledAt?.toLocal();
      linkController.text = interview.meetingLink ?? '';
      locationController.text = interview.location ?? '';
      notesController.text = interview.notes;
    }
  }

  @override
  void onClose() {
    linkController.dispose();
    locationController.dispose();
    notesController.dispose();
    super.onClose();
  }

  void setMeetingType(String value) {
    if (!const {'online', 'onsite', 'phone'}.contains(value)) return;
    meetingType.value = value;
  }

  Future<void> pickSchedule(BuildContext context) async {
    final now = DateTime.now();
    final initial = scheduledAt.value ?? now.add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 3),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;
    scheduledAt.value = DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String? validateLink(String? value) {
    if (meetingType.value != 'online') return null;
    final link = value?.trim() ?? '';
    if (link.isEmpty) return 'رابط الاجتماع مطلوب للمقابلة الأونلاين';
    final uri = Uri.tryParse(link);
    if (uri == null || !uri.hasScheme || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      return 'أدخل رابطًا صحيحًا يبدأ بـ http أو https';
    }
    return null;
  }

  String? validateLocation(String? value) {
    if (meetingType.value == 'onsite' && (value?.trim().isEmpty ?? true)) {
      return 'الموقع مطلوب للمقابلة الحضورية';
    }
    return null;
  }

  Future<void> submit() async {
    if (isSubmitting.value || formKey.currentState?.validate() != true) return;
    final date = scheduledAt.value;
    if (date == null || date.isBefore(DateTime.now())) {
      Get.snackbar('موعد غير صالح', 'اختر تاريخًا ووقتًا قادمين');
      return;
    }
    if (opportunityId <= 0 || applicationId <= 0) {
      Get.snackbar('خطأ', 'بيانات المقابلة غير صالحة');
      return;
    }
    final request = SaveOpportunityInterviewRequest(
      meetingType: meetingType.value,
      meetingLink: meetingType.value == 'online' ? linkController.text : null,
      location: meetingType.value == 'onsite' ? locationController.text : null,
      notes: notesController.text,
      scheduledAt: date.toUtc().toIso8601String(),
    );
    try {
      isSubmitting.value = true;
      if (isReschedule) {
        await _service.reschedule(
          opportunityId: opportunityId,
          interviewId: interviewId!,
          request: request,
        );
      } else {
        await _service.schedule(
          opportunityId: opportunityId,
          applicationId: applicationId,
          request: request,
        );
      }
      Get.back(result: true);
      Get.snackbar(
        'تم الحفظ',
        isReschedule
            ? 'تمت إعادة جدولة المقابلة'
            : 'تمت جدولة المقابلة وفتح محادثتها',
      );
    } catch (error) {
      Get.snackbar(
        'تعذر الحفظ',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  String get formattedSchedule {
    final value = scheduledAt.value;
    if (value == null) return 'اختر التاريخ والوقت';
    return '${value.year}/${value.month}/${value.day}  ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
}
