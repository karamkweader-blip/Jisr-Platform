import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/opportunities/student_opportunity_model.dart';
import 'package:jisr_platform/services/student/opportunities/student_opportunity_service.dart';

class StudentOpportunityController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final StudentOpportunityService _service = StudentOpportunityService();

  late final TabController tabController;
  final TextEditingController coverLetterController = TextEditingController();

  final RxBool isLoadingRecommended = false.obs;
  final RxBool isLoadingExplore = false.obs;
  final RxBool isLoadingDetails = false.obs;
  final RxBool isApplying = false.obs;

  final RxList<StudentOpportunityModel> recommendedOpportunities =
      <StudentOpportunityModel>[].obs;
  final RxList<StudentOpportunityModel> exploreOpportunities =
      <StudentOpportunityModel>[].obs;
  final Rxn<StudentOpportunityDetailsModel> selectedOpportunity =
      Rxn<StudentOpportunityDetailsModel>();

  bool get isLoading =>
      isLoadingRecommended.value && isLoadingExplore.value;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
  }

  Future<void> fetchInitialOpportunities() async {
    await Future.wait([
      fetchRecommendedOpportunities(),
      fetchExploreOpportunities(),
    ]);
  }

  Future<void> fetchRecommendedOpportunities() async {
    try {
      isLoadingRecommended.value = true;

      final response = await _service.recommendedOpportunities();
      recommendedOpportunities.assignAll(response.data);
    } catch (e) {
      recommendedOpportunities.clear();
      debugPrint('RECOMMENDED OPPORTUNITIES ERROR: $e');
    } finally {
      isLoadingRecommended.value = false;
    }
  }

  Future<void> fetchExploreOpportunities() async {
    try {
      isLoadingExplore.value = true;

      final response = await _service.exploreOpportunities();
      exploreOpportunities.assignAll(response.data);
    } catch (e) {
      exploreOpportunities.clear();
      debugPrint('EXPLORE OPPORTUNITIES ERROR: $e');
    } finally {
      isLoadingExplore.value = false;
    }
  }

  Future<void> refreshOpportunities() async {
    await Future.wait([
      fetchRecommendedOpportunities(),
      fetchExploreOpportunities(),
    ]);
  }

  Future<void> fetchOpportunityDetails(int opportunityId) async {
    try {
      isLoadingDetails.value = true;
      selectedOpportunity.value = null;

      final response = await _service.opportunityDetails(opportunityId);
      selectedOpportunity.value = response.data;
    } catch (e) {
      JisrSnackbar.show(
        title: 'خطأ',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<bool> applyToOpportunity(int opportunityId) async {
    final opportunity = selectedOpportunity.value;

    if (opportunity?.alreadyApplied == true) {
      JisrSnackbar.show(
        title: 'تم التقديم مسبقاً',
        message: 'يوجد طلب تقديم سابق لهذه الفرصة',
        type: JisrSnackbarType.warning,
      );
      return false;
    }

    if (opportunity != null && !opportunity.canApply) {
      JisrSnackbar.show(
        title: 'لا يمكن التقديم',
        message: opportunity.cannotApplyReason ?? 'هذه الفرصة غير متاحة للتقديم',
        type: JisrSnackbarType.warning,
      );
      return false;
    }

    try {
      isApplying.value = true;

      final coverLetter = coverLetterController.text.trim().isEmpty
          ? 'I am interested in this opportunity'
          : coverLetterController.text.trim();

      final response = await _service.applyToOpportunity(
        opportunityId,
        coverLetter: coverLetter,
      );

      coverLetterController.clear();

      await fetchOpportunityDetails(opportunityId);
      await refreshOpportunities();

      JisrSnackbar.show(
        title: 'تم التقديم',
        message: response.message.isEmpty
            ? 'تم إرسال طلب التقديم بنجاح'
            : response.message,
        type: JisrSnackbarType.success,
      );
      return true;
    } catch (e) {
      JisrSnackbar.show(
        title: 'فشل التقديم',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
      return false;
    } finally {
      isApplying.value = false;
    }
  }

  String dateOnly(String? value) {
    if (value == null || value.isEmpty || value == 'null') return 'غير محدد';
    return value.split('T').first.split(' ').first;
  }

  String deadlineText(String? value) {
    if (value == null || value.isEmpty || value == 'null') return 'غير محدد';

    final normalized = value.replaceFirst(' ', 'T');
    final deadline = DateTime.tryParse(normalized);
    if (deadline == null) return dateOnly(value);

    final days = deadline.difference(DateTime.now()).inDays;

    if (days < 0) return 'منتهية';
    if (days == 0) return 'تنتهي اليوم';
    if (days == 1) return 'باقي يوم واحد';
    return 'باقي $days يوم';
  }

  String salaryRange(StudentOpportunityModel opportunity) {
    final min = opportunity.salaryMin.trim();
    final max = opportunity.salaryMax.trim();

    if (min.isEmpty && max.isEmpty) return 'غير محدد';
    if (min.isNotEmpty && max.isNotEmpty) return '$min - $max';
    if (min.isNotEmpty) return 'من $min';
    return 'حتى $max';
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

  String matchLabel(String label) {
    switch (label) {
      case 'strong_match':
        return 'تطابق قوي';
      case 'partial_match':
        return 'تطابق جزئي';
      case 'weak_match':
        return 'تطابق ضعيف';
      default:
        return label.isEmpty ? 'تطابق' : label;
    }
  }

  String companyName(StudentOpportunityCompanyModel company) {
    if (company.name != 'شركة غير محددة') return company.name;
    return company.industry.isEmpty ? company.name : company.industry;
  }

  @override
  void onClose() {
    tabController.dispose();
    coverLetterController.dispose();
    super.onClose();
  }
}
