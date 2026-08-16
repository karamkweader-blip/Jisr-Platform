import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/company/opportunities/company_opportunity_service.dart';

class CompanyOpportunityDetailsController extends GetxController {
  final CompanyOpportunityService _service;

  CompanyOpportunityDetailsController(this._service);

  final isLoading = false.obs;
  final isChangingStatus = false.obs;
  final errorMessage = ''.obs;
  final opportunity = Rxn<CompanyOpportunityModel>();
  final changed = false.obs;
  late final int opportunityId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    opportunityId = args is Map
        ? int.tryParse(args['opportunityId']?.toString() ?? '') ?? 0
        : 0;
    if (opportunityId <= 0) {
      errorMessage.value = 'معرف الفرصة غير صالح';
    } else {
      fetchDetails();
    }
  }

  Future<void> fetchDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      opportunity.value = await _service.getOpportunity(opportunityId);
    } catch (error) {
      errorMessage.value = _clean(error);
    } finally {
      isLoading.value = false;
    }
  }

  void close() => Get.back(result: changed.value);

  Future<void> edit() async {
    final current = opportunity.value;
    if (current == null || !current.canEdit) return;
    final result = await Get.toNamed(
      Routes.companyOpportunityForm,
      arguments: {
        'mode': 'edit',
        'opportunityId': opportunityId,
        'opportunity': current.toJson(),
      },
    );
    if (result == true) {
      changed.value = true;
      await fetchDetails();
    }
  }

  Future<void> publish() => _confirmAndRun(
        title: 'نشر الفرصة',
        message: 'بعد النشر سيتمكن الطلاب من التقديم على هذه الفرصة.',
        success: 'تم نشر الفرصة بنجاح',
        action: () => _service.publishOpportunity(opportunityId),
      );

  Future<void> closeOpportunity() => _confirmAndRun(
        title: 'إغلاق الفرصة',
        message: 'سيتم إيقاف استقبال طلبات جديدة.',
        success: 'تم إغلاق الفرصة بنجاح',
        action: () => _service.closeOpportunity(opportunityId),
      );

  Future<void> cancel() => _confirmAndRun(
        title: 'إلغاء الفرصة',
        message: 'هل أنت متأكد من إلغاء هذه الفرصة؟',
        success: 'تم إلغاء الفرصة بنجاح',
        action: () => _service.cancelOpportunity(opportunityId),
        destructive: true,
      );

  Future<void> _confirmAndRun({
    required String title,
    required String message,
    required String success,
    required Future<CompanyOpportunityModel> Function() action,
    bool destructive = false,
  }) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('تراجع')),
          ElevatedButton(
            style: destructive
                ? ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white)
                : null,
            onPressed: () => Get.back(result: true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      isChangingStatus.value = true;
      opportunity.value = await action();
      changed.value = true;
      Get.snackbar('تم', success, snackPosition: SnackPosition.BOTTOM);
    } catch (error) {
      Get.snackbar('تعذر التنفيذ', _clean(error), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isChangingStatus.value = false;
    }
  }

  void openCandidates() {
    final current = opportunity.value;
    if (current == null || current.isDraft) {
      Get.snackbar('تنبيه', 'يجب نشر الفرصة أولًا لمراجعة المرشحين');
      return;
    }
    Get.toNamed(
      Routes.companyOpportunityCandidates,
      arguments: {'opportunityId': opportunityId, 'title': current.title},
    );
  }

  String typeLabel(String value) => value == 'job' ? 'وظيفة' : 'تدريب';

  String statusLabel(String value) => switch (value) {
        'draft' => 'مسودة',
        'published' => 'منشورة',
        'closed' => 'مغلقة',
        'cancelled' => 'ملغاة',
        _ => value,
      };

  String formatDate(DateTime? value) {
    if (value == null) return 'غير محدد';
    final date = value.toLocal();
    return '${date.year}/${date.month}/${date.day}';
  }

  String salaryRange(CompanyOpportunityModel item) {
    if (item.salaryMin == null && item.salaryMax == null) return 'غير محدد';
    return '${item.salaryMin?.toStringAsFixed(0) ?? '-'} - ${item.salaryMax?.toStringAsFixed(0) ?? '-'}';
  }

  String _clean(Object error) => error.toString().replaceFirst('Exception: ', '');
}
