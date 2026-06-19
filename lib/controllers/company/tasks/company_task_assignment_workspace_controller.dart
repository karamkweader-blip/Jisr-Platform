import 'package:get/get.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_details_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_progress_model.dart';
import 'package:jisr_platform/services/company/tasks/company_task_assignments_service.dart';
enum AssignmentWorkspaceTab {
  overview,
  progress,
}
class CompanyTaskAssignmentWorkspaceController extends GetxController {
  final CompanyTaskAssignmentsService _assignmentsService;

  CompanyTaskAssignmentWorkspaceController(this._assignmentsService);

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final Rxn<CompanyTaskAssignmentDetailsModel> assignmentDetails =
      Rxn<CompanyTaskAssignmentDetailsModel>();

  int assignmentId = 0;

  String studentName = 'الطالب';
  String studentEmail = '';
  String? studentProfilePictureUrl;
final Rx<AssignmentWorkspaceTab> selectedTab =
    AssignmentWorkspaceTab.overview.obs;

final RxBool isProgressLoading = false.obs;
final RxString progressErrorMessage = ''.obs;

final Rxn<CompanyTaskAssignmentProgressModel> assignmentProgress =
    Rxn<CompanyTaskAssignmentProgressModel>();
  @override
  void onInit() {
    super.onInit();

    _readArguments();

    if (assignmentId <= 0) {
      errorMessage.value = 'معرف التكليف غير صالح';
      return;
    }

    fetchAssignmentDetails();
  }

  void _readArguments() {
    final arguments = Get.arguments;

    if (arguments is! Map) {
      return;
    }

    assignmentId = _toInt(arguments['assignmentId']);

    studentName = _readText(
      arguments['studentName'],
      fallback: 'الطالب',
    );

    studentEmail = _readText(arguments['studentEmail']);

    studentProfilePictureUrl = _nullableText(
      arguments['studentProfilePictureUrl'],
    );
  }

  Future<void> fetchAssignmentDetails({
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }

      errorMessage.value = '';

      final result = await _assignmentsService.getTaskAssignmentDetails(
        assignmentId,
      );

      assignmentDetails.value = result;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

Future<void> changeTab(AssignmentWorkspaceTab tab) async {
  selectedTab.value = tab;

  if (tab == AssignmentWorkspaceTab.progress) {
    await fetchAssignmentProgress();
  }
}

Future<void> fetchAssignmentProgress({
  bool showLoading = true,
  bool forceRefresh = false,
}) async {
  if (!forceRefresh && assignmentProgress.value != null) {
    return;
  }

  try {
    if (showLoading) {
      isProgressLoading.value = true;
    }

    progressErrorMessage.value = '';

    final result = await _assignmentsService.getTaskAssignmentProgress(
      assignmentId,
    );

    assignmentProgress.value = result;
  } catch (e) {
    progressErrorMessage.value =
        e.toString().replaceFirst('Exception: ', '');
  } finally {
    if (showLoading) {
      isProgressLoading.value = false;
    }
  }
}

Future<void> refreshWorkspace() async {
  await Future.wait([
    fetchAssignmentDetails(showLoading: false),
    if (selectedTab.value == AssignmentWorkspaceTab.progress)
      fetchAssignmentProgress(
        showLoading: false,
        forceRefresh: true,
      ),
  ]);
}

String formatDateTime(DateTime? date) {
  if (date == null) {
    return 'غير محدد';
  }

  final localDate = date.toLocal();

  return '${formatDate(localDate)} - '
      '${_twoDigits(localDate.hour)}:${_twoDigits(localDate.minute)}';
}
  Future<void> refreshAssignmentDetails() async {
    await fetchAssignmentDetails(showLoading: false);
  }

  String assignmentStatusLabel(String status) {
    switch (status) {
      case 'working':
        return 'قيد التنفيذ';
      case 'submitted':
        return 'بانتظار المراجعة';
      case 'completed':
        return 'مكتملة';
      default:
        return status.isEmpty ? 'غير محددة' : status;
    }
  }

  String difficultyLabel(String difficultyLevel) {
    switch (difficultyLevel) {
      case 'beginner':
        return 'مبتدئ';
      case 'intermediate':
        return 'متوسط';
      case 'advanced':
        return 'متقدم';
      default:
        return difficultyLevel.isEmpty ? 'غير محدد' : difficultyLevel;
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'غير محدد';
    }

    final localDate = date.toLocal();

    return '${localDate.year}/${_twoDigits(localDate.month)}/${_twoDigits(localDate.day)}';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _readText(
    dynamic value, {
    String fallback = '',
  }) {
    final text = value?.toString().trim() ?? '';

    return text.isEmpty ? fallback : text;
  }

  String? _nullableText(dynamic value) {
    final text = value?.toString().trim() ?? '';

    return text.isEmpty ? null : text;
  }
}