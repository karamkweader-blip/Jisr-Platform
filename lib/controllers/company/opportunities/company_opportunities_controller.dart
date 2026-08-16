import 'dart:async';

import 'package:get/get.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_feed_item.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/company/opportunities/company_opportunity_service.dart';
import 'package:jisr_platform/services/company/tasks/company_task_service.dart';

enum CompanyOpportunityTypeFilter { all, task, internship, job }

enum CompanyOpportunityStatusFilter {
  all,
  draft,
  published,
  inProgress,
  closed,
  cancelled,
}

extension CompanyOpportunityTypeFilterX on CompanyOpportunityTypeFilter {
  String get label => switch (this) {
        CompanyOpportunityTypeFilter.all => 'الكل',
        CompanyOpportunityTypeFilter.task => 'المهام',
        CompanyOpportunityTypeFilter.internship => 'التدريبات',
        CompanyOpportunityTypeFilter.job => 'الوظائف',
      };
}

extension CompanyOpportunityStatusFilterX on CompanyOpportunityStatusFilter {
  String get label => switch (this) {
        CompanyOpportunityStatusFilter.all => 'الكل',
        CompanyOpportunityStatusFilter.draft => 'مسودة',
        CompanyOpportunityStatusFilter.published => 'منشورة',
        CompanyOpportunityStatusFilter.inProgress => 'قيد التنفيذ',
        CompanyOpportunityStatusFilter.closed => 'مغلقة',
        CompanyOpportunityStatusFilter.cancelled => 'ملغاة',
      };

  String? get apiValue => switch (this) {
        CompanyOpportunityStatusFilter.all => null,
        CompanyOpportunityStatusFilter.draft => 'draft',
        CompanyOpportunityStatusFilter.published => 'published',
        CompanyOpportunityStatusFilter.inProgress => 'in_progress',
        CompanyOpportunityStatusFilter.closed => 'closed',
        CompanyOpportunityStatusFilter.cancelled => 'cancelled',
      };
}

class CompanyOpportunitiesController extends GetxController {
  final CompanyOpportunityService _opportunityService;
  final CompanyTaskService _taskService;

  CompanyOpportunitiesController(this._opportunityService, this._taskService);

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedType = CompanyOpportunityTypeFilter.all.obs;
  final selectedStatus = CompanyOpportunityStatusFilter.all.obs;
  final searchQuery = ''.obs;
  final tasks = <CompanyTaskModel>[].obs;
  final opportunities = <CompanyOpportunityModel>[].obs;

  Timer? _debounce;
  int _requestSequence = 0;

  List<CompanyOpportunityStatusFilter> get availableStatuses {
    if (selectedType.value == CompanyOpportunityTypeFilter.internship ||
        selectedType.value == CompanyOpportunityTypeFilter.job) {
      return CompanyOpportunityStatusFilter.values
          .where((status) => status != CompanyOpportunityStatusFilter.inProgress)
          .toList();
    }
    return CompanyOpportunityStatusFilter.values;
  }

  List<CompanyOpportunityFeedItem> get visibleItems {
    final query = searchQuery.value.trim().toLowerCase();
    final status = selectedStatus.value.apiValue;
    final items = <CompanyOpportunityFeedItem>[];

    if (selectedType.value == CompanyOpportunityTypeFilter.all ||
        selectedType.value == CompanyOpportunityTypeFilter.task) {
      items.addAll(tasks.map(CompanyOpportunityFeedItem.fromTask));
    }
    if (selectedType.value != CompanyOpportunityTypeFilter.task) {
      final type = selectedType.value == CompanyOpportunityTypeFilter.job
          ? 'job'
          : selectedType.value == CompanyOpportunityTypeFilter.internship
              ? 'internship'
              : null;
      items.addAll(
        opportunities
            .where((item) => type == null || item.type == type)
            .map(CompanyOpportunityFeedItem.fromOpportunity),
      );
    }

    return items.where((item) {
      final matchesStatus = status == null || item.status == status;
      final matchesQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.meta.toLowerCase().contains(query);
      return matchesStatus && matchesQuery;
    }).toList()
      ..sort((a, b) {
        final first = a.deadline ?? DateTime.fromMillisecondsSinceEpoch(0);
        final second = b.deadline ?? DateTime.fromMillisecondsSinceEpoch(0);
        return second.compareTo(first);
      });
  }

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

  void updateSearch(String value) {
    searchQuery.value = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), fetchItems);
  }

  Future<void> selectType(CompanyOpportunityTypeFilter value) async {
    selectedType.value = value;
    if (!availableStatuses.contains(selectedStatus.value)) {
      selectedStatus.value = CompanyOpportunityStatusFilter.all;
    }
    await fetchItems();
  }

  Future<void> selectStatus(CompanyOpportunityStatusFilter value) async {
    selectedStatus.value = value;
    await fetchItems();
  }

  Future<void> fetchItems() async {
    final request = ++_requestSequence;
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final type = selectedType.value;
      final loadTasks = type == CompanyOpportunityTypeFilter.all ||
          type == CompanyOpportunityTypeFilter.task;
      final loadOpportunities = type != CompanyOpportunityTypeFilter.task;
      final taskStatus = selectedStatus.value.apiValue;
      final opportunityStatus =
          selectedStatus.value == CompanyOpportunityStatusFilter.inProgress
              ? null
              : selectedStatus.value.apiValue;

      final results = await Future.wait<dynamic>([
        if (loadTasks) _taskService.getCompanyTasks(status: taskStatus),
        if (loadOpportunities)
          _opportunityService.getOpportunities(
            search: searchQuery.value,
            status: opportunityStatus,
          ),
      ]);
      if (request != _requestSequence) return;

      var index = 0;
      if (loadTasks) tasks.assignAll(results[index++] as List<CompanyTaskModel>);
      if (loadOpportunities) {
        opportunities.assignAll(results[index] as List<CompanyOpportunityModel>);
      }
    } catch (error) {
      if (request == _requestSequence) {
        errorMessage.value = _clean(error);
      }
    } finally {
      if (request == _requestSequence) isLoading.value = false;
    }
  }

  Future<void> createTask() async {
    final changed = await Get.toNamed(Routes.createCompanyTask);
    if (changed == true) await fetchItems();
  }

  Future<void> createOpportunity([String? type]) async {
    final changed = await Get.toNamed(
      Routes.companyOpportunityForm,
      arguments: {
        if (type == 'job' || type == 'internship') 'type': type,
      },
    );
    if (changed == true) await fetchItems();
  }

  Future<void> openItem(CompanyOpportunityFeedItem item) async {
    final changed = await Get.toNamed(
      item.kind == CompanyFeedKind.task
          ? Routes.companyTaskDetails
          : Routes.companyOpportunityDetails,
      arguments: item.kind == CompanyFeedKind.task
          ? {'taskId': item.id}
          : {'opportunityId': item.id},
    );
    if (changed == true) await fetchItems();
  }

  String _clean(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
