import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/company/mentor/company_mentor_constants.dart';
import 'package:jisr_platform/models/company/mentor/company_mentor_nomination_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/mentor/company_mentor_nomination_service.dart';

class CompanyMentorNominationsController
    extends GetxController {
  final CompanyMentorNominationService _service;
  final AuthService _authService;

  CompanyMentorNominationsController(
    this._service,
    this._authService,
  );

  static const int _perPage = 20;

  final RxList<CompanyMentorNominationModel>
      nominations =
      <CompanyMentorNominationModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedStatus = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalNominations = 0.obs;

  int _requestNumber = 0;

  bool get hasMore =>
      currentPage.value < lastPage.value;

  @override
  void onReady() {
    super.onReady();
    fetchNominations();
  }

  Future<void> selectStatus(String status) async {
    if (status.isNotEmpty &&
        !CompanyMentorNominationStatuses.values
            .contains(status)) {
      return;
    }

    if (selectedStatus.value == status) {
      return;
    }

    selectedStatus.value = status;
    currentPage.value = 1;
    lastPage.value = 1;

    await fetchNominations();
  }

  Future<void> fetchNominations({
    bool loadMore = false,
  }) async {
    if (loadMore &&
        (isLoadingMore.value || !hasMore)) {
      return;
    }

    final requestNumber = ++_requestNumber;
    final requestedStatus = selectedStatus.value;

    final requestedPage = loadMore
        ? currentPage.value + 1
        : 1;

    try {
      if (loadMore) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
        errorMessage.value = '';
      }

      final response =
          await _service.getNominations(
        status: requestedStatus.isEmpty
            ? null
            : requestedStatus,
        page: requestedPage,
        perPage: _perPage,
      );

      if (requestNumber != _requestNumber ||
          requestedStatus !=
              selectedStatus.value) {
        return;
      }

      if (loadMore) {
        final existingIds = nominations
            .map((item) => item.id)
            .toSet();

        nominations.addAll(
          response.nominations.where(
            (item) =>
                !existingIds.contains(item.id),
          ),
        );
      } else {
        nominations.assignAll(
          response.nominations,
        );
      }

      currentPage.value =
          response.pagination.currentPage;

      lastPage.value =
          response.pagination.lastPage;

      totalNominations.value =
          response.pagination.total;

      errorMessage.value = '';
    } on CompanyMentorApiException catch (error) {
      if (await _recoverAuthentication(error)) {
        return;
      }

      if (requestNumber != _requestNumber) {
        return;
      }

      if (error.statusCode == 422 &&
          error.hasError('status')) {
        selectedStatus.value = '';
      }

      if (!loadMore) {
        errorMessage.value = error.message;
      }

      if (loadMore || error.statusCode == 403) {
        JisrSnackbar.show(
          title: error.statusCode == 403
              ? 'لا يمكن الوصول'
              : 'تعذر تحميل المزيد',
          message: error.message,
          type: JisrSnackbarType.error,
        );
      }
    } catch (error) {
      if (requestNumber != _requestNumber) {
        return;
      }

      final message = _cleanError(error);

      if (loadMore) {
        JisrSnackbar.show(
          title: 'تعذر تحميل المزيد',
          message: message,
          type: JisrSnackbarType.error,
        );
      } else {
        errorMessage.value = message;
      }
    } finally {
      if (requestNumber == _requestNumber) {
        isLoading.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> openNominationForm() async {
    final result = await Get.toNamed(
      Routes.companyMentorNominationForm,
    );

    if (result is! CompanyMentorNominationModel) {
      return;
    }

    final created = result;

    selectedStatus.value = '';

    final existingIndex =
        nominations.indexWhere(
      (nomination) =>
          nomination.id == created.id,
    );

    if (existingIndex >= 0) {
      nominations[existingIndex] = created;
    } else {
      nominations.insert(0, created);
      totalNominations.value++;
    }

    errorMessage.value = '';

    JisrSnackbar.show(
      title: 'تم إرسال الترشيح',
      message:
          'أُرسل ترشيح الموظف وأصبح الآن قيد مراجعة الإدارة',
      type: JisrSnackbarType.success,
    );

    await fetchNominations();
  }

  String dateTimeText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'غير محدد';
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      return value.replaceFirst('T', ' ');
    }

    final local = parsed.toLocal();

    final day =
        local.day.toString().padLeft(2, '0');

    final month =
        local.month.toString().padLeft(2, '0');

    final hour =
        local.hour.toString().padLeft(2, '0');

    final minute =
        local.minute.toString().padLeft(2, '0');

    return '${local.year}-$month-$day  $hour:$minute';
  }

  Future<bool> _recoverAuthentication(
    CompanyMentorApiException error,
  ) async {
    if (error.statusCode != 401) {
      return false;
    }

    await _authService.removeAuthData();
    Get.offAllNamed(Routes.login);

    return true;
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('TimeoutException: ', '');
  }
}