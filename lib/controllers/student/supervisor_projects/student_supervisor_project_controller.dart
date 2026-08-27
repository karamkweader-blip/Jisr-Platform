import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/supervisor_projects/student_supervisor_project_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/student/supervisor_projects/student_supervisor_project_service.dart';

class StudentSupervisorProjectController extends GetxController {
  final StudentSupervisorProjectService _service =
      StudentSupervisorProjectService();
  final AuthService _authService = AuthService();

  final TextEditingController searchController = TextEditingController();
  final TextEditingController applyMessageController = TextEditingController();

  final RxList<StudentSupervisorProjectModel> projects =
      <StudentSupervisorProjectModel>[].obs;
  final Rxn<StudentSupervisorProjectModel> selectedProject =
      Rxn<StudentSupervisorProjectModel>();
  final RxList<StudentSupervisorProjectApplicationItem> pendingApplications =
      <StudentSupervisorProjectApplicationItem>[].obs;
  final RxList<StudentSupervisorProjectApplicationItem> acceptedApplications =
      <StudentSupervisorProjectApplicationItem>[].obs;
  final RxList<StudentSupervisorProjectApplicationItem> rejectedApplications =
      <StudentSupervisorProjectApplicationItem>[].obs;

  final RxBool isLoadingProjects = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isLoadingDetails = false.obs;
  final RxBool isApplying = false.obs;
  final RxBool isLoadingApplications = false.obs;
  final RxString selectedLevel = ''.obs;
  final RxString listError = ''.obs;
  final RxString detailError = ''.obs;
  final RxString applicationsError = ''.obs;
  final RxString messageError = ''.obs;
  final Rx<StudentSupervisorProjectsPagination> pagination =
      const StudentSupervisorProjectsPagination.empty().obs;

  Timer? _searchTimer;
  int _listRequestVersion = 0;
  int _detailRequestVersion = 0;
  bool _initialLoadStarted = false;

  List<StudentSupervisorProjectApplicationItem> get allApplications =>
      <StudentSupervisorProjectApplicationItem>[
        ...pendingApplications,
        ...acceptedApplications,
        ...rejectedApplications,
      ];

  bool get hasMoreProjects =>
      pagination.value.currentPage < pagination.value.lastPage;

  Future<void> fetchHomeData() async {
    if (_initialLoadStarted) return;
    _initialLoadStarted = true;
    await Future.wait(<Future<void>>[
      fetchProjects(),
      fetchApplications(silent: true),
    ]);
  }

  Future<void> fetchProjects({
    bool loadMore = false,
    bool silent = false,
  }) async {
    if (loadMore && (isLoadingMore.value || !hasMoreProjects)) return;

    final requestVersion = ++_listRequestVersion;
    final page = loadMore ? pagination.value.currentPage + 1 : 1;
    try {
      listError.value = '';
      if (loadMore) {
        isLoadingMore.value = true;
      } else if (!silent) {
        isLoadingProjects.value = true;
      }

      final response = await _service.getProjects(
        search: searchController.text,
        level: selectedLevel.value.isEmpty ? null : selectedLevel.value,
        page: page,
        perPage: 15,
      );
      if (requestVersion != _listRequestVersion) return;

      if (loadMore) {
        final ids = projects.map((project) => project.id).toSet();
        projects.addAll(
          response.projects.where((project) => !ids.contains(project.id)),
        );
      } else {
        projects.assignAll(response.projects);
      }
      pagination.value = response.pagination;
    } on StudentSupervisorProjectApiException catch (error) {
      if (requestVersion != _listRequestVersion) return;
      listError.value = error.message;
      if (!loadMore) projects.clear();
      await _handleAccessError(error);
    } catch (error) {
      if (requestVersion != _listRequestVersion) return;
      listError.value = _cleanError(error);
      if (!loadMore) projects.clear();
    } finally {
      if (requestVersion == _listRequestVersion) {
        isLoadingProjects.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  void onSearchChanged(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 450), fetchProjects);
  }

  Future<void> selectLevel(String value) async {
    if (selectedLevel.value == value) return;
    selectedLevel.value = value;
    await fetchProjects();
  }

  Future<void> refreshProjects() => fetchProjects();

  Future<void> openProject(int projectTemplateId) async {
    if (projectTemplateId <= 0) {
      detailError.value = 'لم يرسل الخادم معرّف مشروع صالح';
      return;
    }

    final requestVersion = ++_detailRequestVersion;
    try {
      isLoadingDetails.value = true;
      detailError.value = '';
      final response = await _service.getProjectDetails(projectTemplateId);
      if (requestVersion != _detailRequestVersion) return;
      selectedProject.value = response.project;
      _replaceProjectCard(response.project);
    } on StudentSupervisorProjectApiException catch (error) {
      if (requestVersion != _detailRequestVersion) return;
      detailError.value = error.message;
      selectedProject.value = null;
      if (error.statusCode == 404) {
        JisrSnackbar.show(
          title: 'المشروع لم يعد متاحاً',
          message: error.message,
          type: JisrSnackbarType.warning,
        );
        await fetchProjects(silent: true);
        if (Get.currentRoute == Routes.studentSupervisorProjectDetails) {
          Get.back();
        }
      } else {
        await _handleAccessError(error);
      }
    } catch (error) {
      if (requestVersion != _detailRequestVersion) return;
      detailError.value = _cleanError(error);
      selectedProject.value = null;
    } finally {
      if (requestVersion == _detailRequestVersion) {
        isLoadingDetails.value = false;
      }
    }
  }

  void prepareApplyForm() {
    applyMessageController.clear();
    messageError.value = '';
  }

  void onApplyMessageChanged(String value) {
    if (messageError.value.isNotEmpty && value.trim().length <= 1000) {
      messageError.value = '';
    }
  }

  Future<bool> applyToSelectedProject() async {
    final project = selectedProject.value;
    if (project == null || !project.actions.canApply || isApplying.value) {
      return false;
    }

    final message = applyMessageController.text.trim();
    if (message.length > 1000) {
      messageError.value = 'رسالة التقديم يجب ألا تتجاوز 1000 حرف';
      return false;
    }

    try {
      isApplying.value = true;
      messageError.value = '';
      final response = await _service.apply(
        projectTemplateId: project.id,
        message: message.isEmpty ? null : message,
      );

      await Future.wait(<Future<void>>[
        openProject(project.id),
        fetchApplications(silent: true),
      ]);
      applyMessageController.clear();
      JisrSnackbar.show(
        title: 'تم التقديم',
        message: response.message.isEmpty
            ? 'تم إرسال طلب التقديم بنجاح'
            : response.message,
        type: JisrSnackbarType.success,
      );
      return true;
    } on StudentSupervisorProjectApiException catch (error) {
      if (error.statusCode == 422) {
        messageError.value = error.fieldErrors['message'] ?? '';
        await Future.wait(<Future<void>>[
          openProject(project.id),
          fetchApplications(silent: true),
        ]);
      } else {
        await _handleAccessError(error);
      }
      JisrSnackbar.show(
        title: error.statusCode == 422 ? 'تعذر التقديم' : 'فشل التقديم',
        message: error.message,
        type: JisrSnackbarType.error,
      );
      return false;
    } catch (error) {
      JisrSnackbar.show(
        title: 'فشل التقديم',
        message: _cleanError(error),
        type: JisrSnackbarType.error,
      );
      return false;
    } finally {
      isApplying.value = false;
    }
  }

  Future<void> fetchApplications({bool silent = false}) async {
    try {
      applicationsError.value = '';
      if (!silent) isLoadingApplications.value = true;
      final response = await _service.getApplications();
      pendingApplications.assignAll(response.pending);
      acceptedApplications.assignAll(response.accepted);
      rejectedApplications.assignAll(response.rejected);
    } on StudentSupervisorProjectApiException catch (error) {
      applicationsError.value = error.message;
      await _handleAccessError(error);
    } catch (error) {
      applicationsError.value = _cleanError(error);
    } finally {
      isLoadingApplications.value = false;
    }
  }

  void openAcceptedAssignment({
    required int? projectAssignmentId,
    required String projectTitle,
  }) {
    if (projectAssignmentId == null || projectAssignmentId <= 0) {
      JisrSnackbar.show(
        title: 'المشروع غير جاهز بعد',
        message: 'لم يرسل الخادم project_assignment_id لهذا المشروع المقبول',
        type: JisrSnackbarType.warning,
      );
      fetchApplications(silent: true);
      return;
    }

    Get.toNamed(
      Routes.studentAssignedTasks,
      arguments: <String, dynamic>{
        'projectAssignmentId': projectAssignmentId,
        'projectTitle': projectTitle,
      },
    );
  }

  String levelText(String level) {
    switch (level) {
      case 'Beginner':
        return 'مبتدئ';
      case 'Intermediate':
        return 'متوسط';
      case 'Advanced':
        return 'متقدم';
      default:
        return level.isEmpty ? 'غير محدد' : level;
    }
  }

  String applicationStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد المراجعة';
      case 'accepted':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'withdrawn':
        return 'مسحوب';
      default:
        return status.isEmpty ? 'لم يتم التقديم' : status;
    }
  }

  String applyStateText(StudentSupervisorProjectModel project) {
    final application = project.application;
    if (application != null) {
      return applicationStatusText(application.status);
    }
    switch (project.actions.applyBlockReason) {
      case 'capacity_reached':
        return 'اكتمل العدد';
      case 'already_applied':
        return 'تم التقديم مسبقاً';
      default:
        return project.actions.canApply ? 'متاح للتقديم' : 'غير متاح';
    }
  }

  void _replaceProjectCard(StudentSupervisorProjectModel project) {
    final index = projects.indexWhere((item) => item.id == project.id);
    if (index >= 0) projects[index] = project;
  }

  Future<void> _handleAccessError(
    StudentSupervisorProjectApiException error,
  ) async {
    if (error.statusCode == 401) {
      await _authService.removeAuthData();
      Get.offAllNamed(Routes.login);
    }
  }

  String _cleanError(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  @override
  void onClose() {
    _searchTimer?.cancel();
    searchController.dispose();
    applyMessageController.dispose();
    super.onClose();
  }
}
