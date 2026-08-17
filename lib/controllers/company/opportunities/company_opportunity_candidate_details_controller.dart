import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_candidate_model.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_interview_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/company/opportunities/company_opportunity_candidate_service.dart';
import 'package:jisr_platform/services/company/opportunities/company_opportunity_interview_service.dart';

class CompanyOpportunityCandidateDetailsController extends GetxController {
  final CompanyOpportunityCandidateService _candidateService;
  final CompanyOpportunityInterviewService _interviewService;

  CompanyOpportunityCandidateDetailsController(
    this._candidateService,
    this._interviewService,
  );

  final candidate = Rxn<CompanyOpportunityCandidate>();
  final isLoading = false.obs;
  final isActing = false.obs;
  final errorMessage = ''.obs;
  final changed = false.obs;
  late final int opportunityId;
  late final int applicationId;

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
    if (opportunityId <= 0 || applicationId <= 0) {
      errorMessage.value = 'بيانات المرشح غير صالحة';
    } else {
      fetchCandidate();
    }
  }

  Future<void> fetchCandidate() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      candidate.value = await _candidateService.getCandidate(
        opportunityId,
        applicationId,
      );
    } catch (error) {
      errorMessage.value = _clean(error);
    } finally {
      isLoading.value = false;
    }
  }

  void close() => Get.back(result: changed.value);

  Future<void> openInterviewForm({bool reschedule = false}) async {
    final current = candidate.value;
    if (current == null) return;
    final interview = current.interview;
    final result = await Get.toNamed(
      Routes.companyOpportunityInterview,
      arguments: {
        'opportunityId': opportunityId,
        'applicationId': applicationId,
        'mode': reschedule ? 'reschedule' : 'schedule',
        if (interview != null) 'interview': _interviewArguments(interview),
      },
    );
    if (result == true) {
      changed.value = true;
      await fetchCandidate();
    }
  }

  Future<void> cancelInterview() => _interviewAction(
        'إلغاء المقابلة',
        (interview) => _interviewService.cancel(
          opportunityId: opportunityId,
          interviewId: interview.id,
        ),
      );

  Future<void> completeInterview() => _interviewAction(
        'إكمال المقابلة',
        (interview) => _interviewService.complete(
          opportunityId: opportunityId,
          interviewId: interview.id,
        ),
      );

  Future<void> _interviewAction(
    String title,
    Future<CompanyOpportunityInterview> Function(CompanyOpportunityInterview) action,
  ) async {
    final interview = candidate.value?.interview;
    if (interview == null || isActing.value) return;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: const Text('هل تريد متابعة هذا الإجراء؟'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('تراجع')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('تأكيد')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      isActing.value = true;
      await action(interview);
      changed.value = true;
      await fetchCandidate();
      Get.snackbar('تم', 'تم تحديث حالة المقابلة بنجاح');
    } catch (error) {
      Get.snackbar('تعذر التنفيذ', _clean(error));
    } finally {
      isActing.value = false;
    }
  }

  Map<String, dynamic> _interviewArguments(CompanyOpportunityInterview value) {
    return {
      'id': value.id,
      'scheduled_at': value.scheduledAt?.toIso8601String(),
      'meeting_type': value.meetingType,
      'meeting_link': value.meetingLink,
      'location': value.location,
      'status': value.status,
      'notes': value.notes,
      'actions': {
        'can_reschedule': value.actions.canReschedule,
        'can_cancel': value.actions.canCancel,
        'can_complete': value.actions.canComplete,
      },
    };
  }

  String meetingTypeLabel(String type) => switch (type) {
        'online' => 'أونلاين',
        'onsite' => 'حضوري',
        'phone' => 'هاتف',
        _ => type,
      };

  String statusLabel(String value) => switch (value) {
        'scheduled' => 'مجدولة',
        'rescheduled' => 'أعيدت جدولتها',
        'cancelled' => 'ملغاة',
        'completed' => 'مكتملة',
        _ => value,
      };

  String formatDate(DateTime? value) {
    if (value == null) return 'غير محدد';
    final local = value.toLocal();
    return '${local.year}/${local.month}/${local.day}  ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  String _clean(Object error) => error.toString().replaceFirst('Exception: ', '');
}
