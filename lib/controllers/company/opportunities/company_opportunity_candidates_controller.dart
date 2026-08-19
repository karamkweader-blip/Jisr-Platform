import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_candidate_model.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_smart_ranking_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/opportunities/company_opportunity_candidate_service.dart';
import 'package:jisr_platform/services/company/opportunities/company_opportunity_matching_service.dart';

enum CompanyOpportunityCandidatesMode {
  smartRanking,
  allApplicants,
}

class CompanyOpportunityCandidatesController
    extends GetxController {
  final CompanyOpportunityCandidateService
      _candidateService;

  final CompanyOpportunityMatchingService
      _matchingService;

  final AuthService _authService;

  CompanyOpportunityCandidatesController(
    this._candidateService,
    this._matchingService,
    this._authService,
  );

  static const int _rankingLimit = 20;

  final RxList<CompanyOpportunityCandidate>
      candidates =
      <CompanyOpportunityCandidate>[].obs;

  final RxList<
          CompanyOpportunityRankedCandidate>
      rankedCandidates =
      <CompanyOpportunityRankedCandidate>[].obs;

  final Rx<CompanyOpportunityRankingMeta>
      rankingMeta =
      CompanyOpportunityRankingMeta.empty.obs;

  final Rx<
          CompanyOpportunityCandidatesMode>
      selectedMode =
      CompanyOpportunityCandidatesMode
          .smartRanking.obs;

  final RxBool isLoading = false.obs;
  final RxBool isRankingLoading = false.obs;

  final RxString errorMessage = ''.obs;
  final RxString rankingErrorMessage = ''.obs;

  late final int opportunityId;
  late final String opportunityTitle;

  bool _allApplicantsLoaded = false;
  bool _smartRankingLoaded = false;

  int _candidatesRequestNumber = 0;
  int _rankingRequestNumber = 0;

  bool get isSmartRankingSelected {
    return selectedMode.value ==
        CompanyOpportunityCandidatesMode
            .smartRanking;
  }

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    opportunityId = args is Map
        ? int.tryParse(
              args['opportunityId']
                      ?.toString() ??
                  '',
            ) ??
            0
        : 0;

    opportunityTitle = args is Map
        ? args['title']?.toString() ??
            'الفرصة'
        : 'الفرصة';

    if (opportunityId <= 0) {
      const message =
          'معرف الفرصة غير صالح';

      errorMessage.value = message;
      rankingErrorMessage.value = message;
      return;
    }

    fetchSmartRanking();
  }

  Future<void> selectMode(
    CompanyOpportunityCandidatesMode mode,
  ) async {
    if (selectedMode.value == mode) {
      return;
    }

    selectedMode.value = mode;

    if (mode ==
        CompanyOpportunityCandidatesMode
            .smartRanking) {
      if (!_smartRankingLoaded &&
          !isRankingLoading.value) {
        await fetchSmartRanking();
      }

      return;
    }

    if (!_allApplicantsLoaded &&
        !isLoading.value) {
      await fetchCandidates();
    }
  }

  Future<void> fetchSmartRanking({
    bool showLoading = true,
  }) async {
    if (opportunityId <= 0) {
      rankingErrorMessage.value =
          'معرف الفرصة غير صالح';
      return;
    }

    final requestNumber =
        ++_rankingRequestNumber;

    try {
      if (showLoading) {
        isRankingLoading.value = true;
      }

      rankingErrorMessage.value = '';

      final response =
          await _matchingService.getTopCandidates(
        opportunityId: opportunityId,
        limit: _rankingLimit,
      );

      if (requestNumber !=
          _rankingRequestNumber) {
        return;
      }

      rankedCandidates.assignAll(
        response.candidates,
      );

      rankingMeta.value = response.meta;
      _smartRankingLoaded = true;
    } on CompanyOpportunityMatchingApiException catch (error) {
      if (await _recoverAuthentication(
        error,
      )) {
        return;
      }

      if (requestNumber !=
          _rankingRequestNumber) {
        return;
      }

      if (error.statusCode == 403 ||
          error.statusCode == 404) {
        rankedCandidates.clear();

        rankingMeta.value =
            CompanyOpportunityRankingMeta
                .empty;

        _smartRankingLoaded = false;

        rankingErrorMessage.value =
            error.message;

        return;
      }

      if (rankedCandidates.isEmpty) {
        rankingErrorMessage.value =
            error.message;
      } else {
        _showError(
          title: 'تعذر تحديث الترتيب',
          message: error.message,
        );
      }
    } catch (error) {
      if (requestNumber !=
          _rankingRequestNumber) {
        return;
      }

      final message = _cleanError(error);

      if (rankedCandidates.isEmpty) {
        rankingErrorMessage.value =
            message;
      } else {
        _showError(
          title: 'تعذر تحديث الترتيب',
          message: message,
        );
      }
    } finally {
      if (requestNumber ==
          _rankingRequestNumber) {
        isRankingLoading.value = false;
      }
    }
  }

  Future<void> fetchCandidates({
    bool showLoading = true,
  }) async {
    if (opportunityId <= 0) {
      errorMessage.value =
          'معرف الفرصة غير صالح';
      return;
    }

    final requestNumber =
        ++_candidatesRequestNumber;

    try {
      if (showLoading) {
        isLoading.value = true;
      }

      errorMessage.value = '';

      final result =
          await _candidateService
              .getCandidates(
        opportunityId,
      );

      if (requestNumber !=
          _candidatesRequestNumber) {
        return;
      }

      candidates.assignAll(result);
      _allApplicantsLoaded = true;
    } catch (error) {
      if (requestNumber !=
          _candidatesRequestNumber) {
        return;
      }

      final message = _cleanError(error);

      if (candidates.isEmpty) {
        errorMessage.value = message;
      } else {
        _showError(
          title:
              'تعذر تحديث المتقدمين',
          message: message,
        );
      }
    } finally {
      if (requestNumber ==
          _candidatesRequestNumber) {
        isLoading.value = false;
      }
    }
  }

  Future<void> refreshSmartRanking() {
    return fetchSmartRanking(
      showLoading: false,
    );
  }

  Future<void> refreshCandidates() {
    return fetchCandidates(
      showLoading: false,
    );
  }

  Future<void> openCandidate(
    CompanyOpportunityCandidate candidate,
  ) {
    return _openCandidateDetails(
      candidate.applicationId,
    );
  }

  Future<void> openRankedCandidate(
    CompanyOpportunityRankedCandidate
        candidate,
  ) {
    return _openCandidateDetails(
      candidate.applicationId,
    );
  }

  Future<void> _openCandidateDetails(
    int applicationId,
  ) async {
    if (applicationId <= 0) {
      _showError(
        title: 'تعذر فتح المرشح',
        message:
            'معرف طلب التقديم غير صالح',
      );
      return;
    }

    final changed = await Get.toNamed(
      Routes
          .companyOpportunityCandidateDetails,
      arguments: <String, dynamic>{
        'opportunityId': opportunityId,
        'applicationId': applicationId,
      },
    );

    if (changed == true) {
      await _refreshLoadedSections();
    }
  }

  Future<void>
      _refreshLoadedSections() async {
    final requests = <Future<void>>[];

    if (_smartRankingLoaded) {
      requests.add(
        fetchSmartRanking(
          showLoading: false,
        ),
      );
    }

    if (_allApplicantsLoaded) {
      requests.add(
        fetchCandidates(
          showLoading: false,
        ),
      );
    }

    if (requests.isNotEmpty) {
      await Future.wait(requests);
    }
  }

  Future<bool> _recoverAuthentication(
    CompanyOpportunityMatchingApiException
        error,
  ) async {
    if (error.statusCode != 401) {
      return false;
    }

    rankedCandidates.clear();
    candidates.clear();

    await _authService.removeAuthData();

    Get.offAllNamed(Routes.login);

    return true;
  }

  void _showError({
    required String title,
    required String message,
  }) {
    JisrSnackbar.show(
      title: title,
      message: message,
      type: JisrSnackbarType.error,
    );
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst(
          'TimeoutException: ',
          '',
        );
  }
}