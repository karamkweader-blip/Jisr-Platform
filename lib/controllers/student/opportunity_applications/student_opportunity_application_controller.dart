import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/opportunity_applications/student_opportunity_application_model.dart';
import 'package:jisr_platform/services/student/opportunity_applications/student_opportunity_application_service.dart';

enum OpportunityApplicationFilter { all, pending, withdrawn }

class StudentOpportunityApplicationController extends GetxController {
  final StudentOpportunityApplicationService _service =
      StudentOpportunityApplicationService();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingDetails = false.obs;
  final RxBool isWithdrawing = false.obs;

  final Rx<OpportunityApplicationFilter> selectedFilter =
      OpportunityApplicationFilter.all.obs;

  final RxList<StudentOpportunityApplicationModel> applications =
      <StudentOpportunityApplicationModel>[].obs;

  final Rxn<StudentOpportunityApplicationModel> selectedApplication =
      Rxn<StudentOpportunityApplicationModel>();

  @override
  void onReady() {
    super.onReady();
    fetchApplications();
  }

  List<StudentOpportunityApplicationModel> get filteredApplications {
    switch (selectedFilter.value) {
      case OpportunityApplicationFilter.all:
        return applications;
      case OpportunityApplicationFilter.pending:
        return applications
            .where((item) => item.status == 'pending')
            .toList();
      case OpportunityApplicationFilter.withdrawn:
        return applications
            .where((item) => item.status == 'withdrawn')
            .toList();
    }
  }

  int get pendingCount {
    return applications.where((item) => item.status == 'pending').length;
  }

  int get withdrawnCount {
    return applications.where((item) => item.status == 'withdrawn').length;
  }

  String get currentFilterTitle {
    switch (selectedFilter.value) {
      case OpportunityApplicationFilter.all:
        return 'كل تقديمات فرص العمل';
      case OpportunityApplicationFilter.pending:
        return 'الطلبات قيد المراجعة';
      case OpportunityApplicationFilter.withdrawn:
        return 'الطلبات المسحوبة';
    }
  }

  void selectFilter(OpportunityApplicationFilter filter) {
    selectedFilter.value = filter;
  }

  Future<void> fetchApplications() async {
    try {
      isLoading.value = true;

      final response = await _service.getApplications();
      applications.assignAll(response.data);
    } catch (e) {
      _showError('فشل جلب التقديمات', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshApplications() async {
    await fetchApplications();
  }

  Future<void> fetchApplicationDetails(int applicationId) async {
    try {
      isLoadingDetails.value = true;
      selectedApplication.value = null;

      final response = await _service.getApplicationDetails(applicationId);
      selectedApplication.value = response.data;
    } catch (e) {
      _showError('فشل جلب التفاصيل', e);
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<void> withdrawApplication(int applicationId) async {
    try {
      isWithdrawing.value = true;

      final response = await _service.withdrawApplication(applicationId);
      selectedApplication.value = response.data;

      final index = applications.indexWhere((item) => item.id == applicationId);
      if (index != -1) {
        applications[index] = response.data;
      }

      JisrSnackbar.show(
        title: 'تم سحب الطلب',
        message: response.message.isEmpty
            ? 'تم سحب طلب التقديم بنجاح'
            : response.message,
        type: JisrSnackbarType.success,
      );
    } catch (e) {
      _showError('فشل سحب الطلب', e);
    } finally {
      isWithdrawing.value = false;
    }
  }

  String opportunityTypeLabel(String type) {
    switch (type) {
      case 'job':
        return 'وظيفة';
      case 'internship':
        return 'تدريب';
      default:
        return type.isEmpty ? 'فرصة' : type;
    }
  }

  String statusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد المراجعة';
      case 'withdrawn':
        return 'مسحوب';
      case 'accepted':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return status.isEmpty ? 'غير محدد' : status;
    }
  }

  String displayStatusText(String status) {
    switch (status) {
      case 'pending_review':
        return 'بانتظار المراجعة';
      case 'withdrawn':
        return 'مسحوب';
      default:
        return statusText(status);
    }
  }

  String dateOnly(String? value) {
    if (value == null || value.isEmpty || value == 'null') return 'غير محدد';
    return value.split('T').first.split(' ').first;
  }

  String companyName(StudentAppliedOpportunityCompanyModel company) {
    if (company.name != 'شركة غير محددة') return company.name;
    return company.industry.isEmpty ? company.name : company.industry;
  }

  void _showError(String title, Object error) {
    JisrSnackbar.show(
      title: title,
      message: error.toString().replaceFirst('Exception: ', ''),
      type: JisrSnackbarType.error,
    );
  }
}
