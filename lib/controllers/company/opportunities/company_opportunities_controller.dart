import 'dart:async';

import 'package:get/get.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_feed_item.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/company/opportunities/company_opportunity_service.dart';
import 'package:jisr_platform/services/company/tasks/company_task_service.dart';

enum CompanyOpportunityTypeFilter {
  all,
  task,
  internship,
  job,
}

enum CompanyOpportunityStatusFilter {
  all,
  draft,
  published,
  inProgress,
  closed,
  cancelled,
}

extension CompanyOpportunityTypeFilterX
    on CompanyOpportunityTypeFilter {
  String get label {
    switch (this) {
      case CompanyOpportunityTypeFilter.all:
        return 'الكل';

      case CompanyOpportunityTypeFilter.task:
        return 'المهام';

      case CompanyOpportunityTypeFilter.internship:
        return 'التدريبات';

      case CompanyOpportunityTypeFilter.job:
        return 'الوظائف';
    }
  }
}

extension CompanyOpportunityStatusFilterX
    on CompanyOpportunityStatusFilter {
  String get label {
    switch (this) {
      case CompanyOpportunityStatusFilter.all:
        return 'الكل';

      case CompanyOpportunityStatusFilter.draft:
        return 'مسودة';

      case CompanyOpportunityStatusFilter.published:
        return 'منشورة';

      case CompanyOpportunityStatusFilter.inProgress:
        return 'قيد التنفيذ';

      case CompanyOpportunityStatusFilter.closed:
        return 'مغلقة';

      case CompanyOpportunityStatusFilter.cancelled:
        return 'ملغاة';
    }
  }

  String? get apiValue {
    switch (this) {
      case CompanyOpportunityStatusFilter.all:
        return null;

      case CompanyOpportunityStatusFilter.draft:
        return 'draft';

      case CompanyOpportunityStatusFilter.published:
        return 'published';

      case CompanyOpportunityStatusFilter.inProgress:
        return 'in_progress';

      case CompanyOpportunityStatusFilter.closed:
        return 'closed';

      case CompanyOpportunityStatusFilter.cancelled:
        return 'cancelled';
    }
  }
}

class CompanyOpportunitiesController extends GetxController {
  final CompanyOpportunityService _opportunityService;
  final CompanyTaskService _taskService;

  CompanyOpportunitiesController(
    this._opportunityService,
    this._taskService,
  );

  final RxBool isLoading = false.obs;

  final RxString errorMessage = ''.obs;

  final Rx<CompanyOpportunityTypeFilter> selectedType =
      CompanyOpportunityTypeFilter.all.obs;

  final Rx<CompanyOpportunityStatusFilter> selectedStatus =
      CompanyOpportunityStatusFilter.all.obs;

  final RxString searchQuery = ''.obs;

  final RxList<CompanyTaskModel> tasks =
      <CompanyTaskModel>[].obs;

  final RxList<CompanyOpportunityModel> opportunities =
      <CompanyOpportunityModel>[].obs;

  Timer? _debounce;

  int _requestSequence = 0;

  @override
  void onInit() {
    super.onInit();

    fetchItems();
  }

  @override
  void onClose() {
    _debounce?.cancel();

    super.onClose();
  }

  List<CompanyOpportunityStatusFilter> get availableStatuses {
    if (selectedType.value ==
            CompanyOpportunityTypeFilter.internship ||
        selectedType.value == CompanyOpportunityTypeFilter.job) {
      return CompanyOpportunityStatusFilter.values
          .where(
            (status) =>
                status != CompanyOpportunityStatusFilter.inProgress,
          )
          .toList();
    }

    return CompanyOpportunityStatusFilter.values;
  }

  List<CompanyOpportunityFeedItem> get visibleItems {
    final query = searchQuery.value.trim().toLowerCase();

    final selectedApiStatus = selectedStatus.value.apiValue;

    final List<CompanyOpportunityFeedItem> items = [];

    if (selectedType.value == CompanyOpportunityTypeFilter.all ||
        selectedType.value == CompanyOpportunityTypeFilter.task) {
      items.addAll(
        tasks.map(
          CompanyOpportunityFeedItem.fromTask,
        ),
      );
    }

    if (selectedType.value != CompanyOpportunityTypeFilter.task) {
      String? selectedOpportunityType;

      if (selectedType.value == CompanyOpportunityTypeFilter.job) {
        selectedOpportunityType = 'job';
      } else if (selectedType.value ==
          CompanyOpportunityTypeFilter.internship) {
        selectedOpportunityType = 'internship';
      }

      items.addAll(
        opportunities
            .where(
              (opportunity) =>
                  selectedOpportunityType == null ||
                  opportunity.type == selectedOpportunityType,
            )
            .map(
              CompanyOpportunityFeedItem.fromOpportunity,
            ),
      );
    }

    final filteredItems = items.where(
      (item) {
        final matchesStatus = selectedApiStatus == null ||
            item.status == selectedApiStatus;

        final matchesSearch = query.isEmpty ||
            item.title.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query) ||
            item.meta.toLowerCase().contains(query);

        return matchesStatus && matchesSearch;
      },
    ).toList();

    filteredItems.sort(
      (first, second) {
        final firstDeadline = first.deadline ??
            DateTime.fromMillisecondsSinceEpoch(0);

        final secondDeadline = second.deadline ??
            DateTime.fromMillisecondsSinceEpoch(0);

        return secondDeadline.compareTo(
          firstDeadline,
        );
      },
    );

    return filteredItems;
  }

  void updateSearch(String value) {
    searchQuery.value = value;

    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 450),
      () {
        fetchItems();
      },
    );
  }

  Future<void> selectType(
    CompanyOpportunityTypeFilter value,
  ) async {
    selectedType.value = value;

    if (!availableStatuses.contains(selectedStatus.value)) {
      selectedStatus.value =
          CompanyOpportunityStatusFilter.all;
    }

    await fetchItems();
  }

  Future<void> selectStatus(
    CompanyOpportunityStatusFilter value,
  ) async {
    selectedStatus.value = value;

    await fetchItems();
  }

  /// يستخدم عند فتح تبويب الفرص من كاردات الصفحة الرئيسية.
  ///
  /// مثال:
  /// المتقدمون الجدد -> Opportunities -> Tasks
  void applyHomePreset({
    required CompanyOpportunityTypeFilter type,
    CompanyOpportunityStatusFilter status =
        CompanyOpportunityStatusFilter.all,
  }) {
    _debounce?.cancel();

    searchQuery.value = '';

    selectedType.value = type;

    if (availableStatuses.contains(status)) {
      selectedStatus.value = status;
    } else {
      selectedStatus.value =
          CompanyOpportunityStatusFilter.all;
    }

    errorMessage.value = '';
  }

  Future<void> fetchItems() async {
    final currentRequest = ++_requestSequence;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final currentType = selectedType.value;

      final bool shouldLoadTasks =
          currentType == CompanyOpportunityTypeFilter.all ||
              currentType == CompanyOpportunityTypeFilter.task;

      final bool shouldLoadOpportunities =
          currentType != CompanyOpportunityTypeFilter.task;

      final String? taskStatus = selectedStatus.value.apiValue;

      final String? opportunityStatus =
          selectedStatus.value ==
                  CompanyOpportunityStatusFilter.inProgress
              ? null
              : selectedStatus.value.apiValue;

      final List<Future<dynamic>> requests = [];

      if (shouldLoadTasks) {
        requests.add(
          _taskService.getCompanyTasks(
            status: taskStatus,
          ),
        );
      }

      if (shouldLoadOpportunities) {
        requests.add(
          _opportunityService.getOpportunities(
            search: searchQuery.value,
            status: opportunityStatus,
          ),
        );
      }

      final results = await Future.wait<dynamic>(
        requests,
      );

      if (currentRequest != _requestSequence) {
        return;
      }

      int resultIndex = 0;

      if (shouldLoadTasks) {
        final taskResults =
            results[resultIndex] as List<CompanyTaskModel>;

        tasks.assignAll(taskResults);

        resultIndex++;
      }

      if (shouldLoadOpportunities) {
        final opportunityResults =
            results[resultIndex] as List<CompanyOpportunityModel>;

        opportunities.assignAll(
          opportunityResults,
        );
      }
    } catch (error) {
      if (currentRequest == _requestSequence) {
        errorMessage.value = _cleanError(error);
      }
    } finally {
      if (currentRequest == _requestSequence) {
        isLoading.value = false;
      }
    }
  }

  Future<void> createTask() async {
    final changed = await Get.toNamed(
      Routes.createCompanyTask,
    );

    if (changed == true) {
      await fetchItems();
    }
  }

  Future<void> createOpportunity([
    String? type,
  ]) async {
    final changed = await Get.toNamed(
      Routes.companyOpportunityForm,
      arguments: {
        if (type == 'job' || type == 'internship')
          'type': type,
      },
    );

    if (changed == true) {
      await fetchItems();
    }
  }

  Future<void> openItem(
    CompanyOpportunityFeedItem item,
  ) async {
    final changed = await Get.toNamed(
      item.kind == CompanyFeedKind.task
          ? Routes.companyTaskDetails
          : Routes.companyOpportunityDetails,
      arguments: item.kind == CompanyFeedKind.task
          ? {
              'taskId': item.id,
            }
          : {
              'opportunityId': item.id,
            },
    );

    if (changed == true) {
      await fetchItems();
    }
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );
  }

  Future<void> showPublishedTasks() async {
  selectedType.value =
      CompanyOpportunityTypeFilter.task;

  selectedStatus.value =
      CompanyOpportunityStatusFilter.published;

  searchQuery.value = '';

  await fetchItems();
}
}