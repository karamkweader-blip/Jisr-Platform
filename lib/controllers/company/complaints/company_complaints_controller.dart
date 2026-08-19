import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/company/complaints/company_complaint_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/complaints/company_complaint_service.dart';

class CompanyComplaintsController
    extends GetxController {
  final CompanyComplaintService _service;
  final AuthService _authService;

  CompanyComplaintsController(
    this._service,
    this._authService,
  );

  static const int _perPage = 20;

  final RxList<CompanyComplaintModel>
      complaints = <CompanyComplaintModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedStatus = ''.obs;
  final RxString selectedContextType = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalComplaints = 0.obs;

  int _requestNumber = 0;

  bool get hasMore {
    return currentPage.value < lastPage.value;
  }

  @override
  void onReady() {
    super.onReady();
    fetchComplaints();
  }

  Future<void> selectStatus(
    String status,
  ) async {
    if (status.isNotEmpty &&
        !CompanyComplaintStatuses.values
            .contains(status)) {
      return;
    }

    if (selectedStatus.value == status) {
      return;
    }

    selectedStatus.value = status;
    complaints.clear();
    totalComplaints.value = 0;
    _resetPagination();

    await fetchComplaints();
  }

  Future<void> selectContextType(
    String contextType,
  ) async {
    if (contextType.isNotEmpty &&
        !CompanyComplaintContextTypes.values
            .contains(contextType)) {
      return;
    }

    if (selectedContextType.value ==
        contextType) {
      return;
    }

    selectedContextType.value = contextType;
    complaints.clear();
    totalComplaints.value = 0;
    _resetPagination();

    await fetchComplaints();
  }

  Future<void> clearFilters() async {
    if (selectedStatus.value.isEmpty &&
        selectedContextType.value.isEmpty) {
      return;
    }

    selectedStatus.value = '';
    selectedContextType.value = '';
    complaints.clear();
    totalComplaints.value = 0;
    _resetPagination();

    await fetchComplaints();
  }

  Future<void> fetchComplaints({
    bool loadMore = false,
    bool showLoading = true,
  }) async {
    if (loadMore &&
        (isLoading.value ||
            isLoadingMore.value ||
            !hasMore)) {
      return;
    }

    final requestNumber = ++_requestNumber;

    final requestedStatus =
        selectedStatus.value;

    final requestedContextType =
        selectedContextType.value;

    final requestedPage = loadMore
        ? currentPage.value + 1
        : 1;

    try {
      if (loadMore) {
        isLoadingMore.value = true;
      } else if (showLoading) {
        isLoading.value = true;
        errorMessage.value = '';
      }

      final response =
          await _service.getMyComplaints(
        status: requestedStatus.isEmpty
            ? null
            : requestedStatus,
        contextType:
            requestedContextType.isEmpty
                ? null
                : requestedContextType,
        page: requestedPage,
        perPage: _perPage,
      );

      if (!_isCurrentRequest(
        requestNumber: requestNumber,
        status: requestedStatus,
        contextType: requestedContextType,
      )) {
        return;
      }

      if (loadMore) {
        final existingIds = complaints
            .map((item) => item.id)
            .toSet();

        complaints.addAll(
          response.complaints.where(
            (complaint) => !existingIds
                .contains(complaint.id),
          ),
        );
      } else {
        complaints.assignAll(
          response.complaints,
        );
      }

      currentPage.value =
          response.pagination.currentPage;

      lastPage.value =
          response.pagination.lastPage;

      totalComplaints.value =
          response.pagination.total;

      errorMessage.value = '';
    } on CompanyComplaintApiException catch (error) {
      if (await _recoverAuthentication(error)) {
        return;
      }

      if (requestNumber != _requestNumber) {
        return;
      }

      if (!loadMore) {
        errorMessage.value = error.message;
      }

      if (loadMore ||
          !showLoading ||
          error.statusCode == 403 ||
          error.statusCode == 429) {
        JisrSnackbar.show(
          title: _errorTitle(
            error.statusCode,
            loadMore: loadMore,
          ),
          message: error.message,
          type: error.statusCode == 429
              ? JisrSnackbarType.warning
              : JisrSnackbarType.error,
        );
      }
    } catch (error) {
      if (requestNumber != _requestNumber) {
        return;
      }

      final message = _cleanError(error);

      if (loadMore || !showLoading) {
        JisrSnackbar.show(
          title: loadMore
              ? 'تعذر تحميل المزيد'
              : 'تعذر تحديث الشكاوى',
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

  Future<void> refreshComplaints() {
    return fetchComplaints(
      showLoading: false,
    );
  }

  String statusLabel(String status) {
    return CompanyComplaintStatuses.label(
      status,
    );
  }

  String contextLabel(String contextType) {
    return CompanyComplaintContextTypes.label(
      contextType,
    );
  }

  String dateTimeText(DateTime? value) {
    if (value == null) {
      return 'غير محدد';
    }

    final local = value.toLocal();

    final day = _twoDigits(local.day);
    final month = _twoDigits(local.month);
    final hour = _twoDigits(local.hour);
    final minute = _twoDigits(local.minute);

    return '${local.year}-$month-$day  '
        '$hour:$minute';
  }

  void _resetPagination() {
    currentPage.value = 1;
    lastPage.value = 1;
  }

  bool _isCurrentRequest({
    required int requestNumber,
    required String status,
    required String contextType,
  }) {
    return requestNumber ==
            _requestNumber &&
        status == selectedStatus.value &&
        contextType ==
            selectedContextType.value;
  }

  Future<bool> _recoverAuthentication(
    CompanyComplaintApiException error,
  ) async {
    if (error.statusCode != 401) {
      return false;
    }

    await _authService.removeAuthData();

    Get.offAllNamed(Routes.login);

    return true;
  }

  String _errorTitle(
    int statusCode, {
    required bool loadMore,
  }) {
    if (loadMore) {
      return 'تعذر تحميل المزيد';
    }

    if (statusCode == 403) {
      return 'لا يمكن الوصول';
    }

    if (statusCode == 429) {
      return 'محاولات متكررة';
    }

    return 'تعذر جلب الشكاوى';
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

  String _twoDigits(int value) {
    return value
        .toString()
        .padLeft(2, '0');
  }
}