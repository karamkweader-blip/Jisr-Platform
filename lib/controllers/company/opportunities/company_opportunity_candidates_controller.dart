import 'package:get/get.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_candidate_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/company/opportunities/company_opportunity_candidate_service.dart';

class CompanyOpportunityCandidatesController extends GetxController {
  final CompanyOpportunityCandidateService _service;

  CompanyOpportunityCandidatesController(this._service);

  final candidates = <CompanyOpportunityCandidate>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  late final int opportunityId;
  late final String opportunityTitle;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    opportunityId = args is Map
        ? int.tryParse(args['opportunityId']?.toString() ?? '') ?? 0
        : 0;
    opportunityTitle = args is Map ? args['title']?.toString() ?? 'الفرصة' : 'الفرصة';
    if (opportunityId <= 0) {
      errorMessage.value = 'معرف الفرصة غير صالح';
    } else {
      fetchCandidates();
    }
  }

  Future<void> fetchCandidates() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      candidates.assignAll(await _service.getCandidates(opportunityId));
    } catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openCandidate(CompanyOpportunityCandidate candidate) async {
    final changed = await Get.toNamed(
      Routes.companyOpportunityCandidateDetails,
      arguments: {
        'opportunityId': opportunityId,
        'applicationId': candidate.applicationId,
      },
    );
    if (changed == true) await fetchCandidates();
  }
}
