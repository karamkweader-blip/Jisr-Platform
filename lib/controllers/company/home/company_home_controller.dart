import 'package:get/get.dart';
import 'package:jisr_platform/models/company/company_home_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/company/company_home_service.dart';
import 'package:jisr_platform/services/company/tasks/company_task_assignments_service.dart';

class CompanyHomeController extends GetxController {
 final CompanyHomeService _homeService;
final CompanyTaskAssignmentsService _assignmentsService;

CompanyHomeController(
  this._homeService,
  this._assignmentsService,
);

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<CompanyHomeModel> homeData = Rxn<CompanyHomeModel>();

  @override
  void onInit() {
    super.onInit();
    fetchCompanyHome();
  }

  Future<void> fetchCompanyHome() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _homeService.getCompanyHome();
      homeData.value = result;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onCreateTaskPressed() async {
    final shouldRefresh = await Get.toNamed(
      Routes.createCompanyTask,
    );

    if (shouldRefresh == true) {
      await fetchCompanyHome();
    }
  }

  Future<void> onRequiredActionPressed(CompanyRequiredAction action) async {
//     debugPrint(
//   'HOME REQUIRED ACTION => '
//   'targetType: ${action.targetType}, '
//   'targetId: ${action.targetId}, '
//   'taskId: ${action.taskId}, '
//   'actionLabel: ${action.actionLabel}',
// );
    switch (action.targetType) {
      case 'task_application':
        await _openApplicantDetails(
          applicationId: action.targetId,
        );
        break;

      case 'task_applications':
        await _openTaskApplicants(
          taskId: action.targetId,
        );
        break;

      case 'task':
        await _openTaskDetails(
          taskId: action.targetId,
        );
        break;
case 'task_submission':
  await _openSubmittedTaskWorkspace(action);
  break;
      default:
        _showUnsupportedAction();
    }
  }
Future<void> _openSubmittedTaskWorkspace(
  CompanyRequiredAction action,
) async {
  final assignment = await _findAssignmentForSubmissionAction(action);

  if (assignment == null) {
    Get.snackbar(
      'تنبيه',
      'تعذر تحديد مساحة العمل المرتبطة بهذا التسليم',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  await Get.toNamed(
    Routes.companyTaskAssignmentWorkspace,
    arguments: {
      'assignmentId': assignment.assignmentId,
      'studentName': assignment.student.name,
      'studentEmail': assignment.student.email,
      'studentProfilePictureUrl': assignment.student.profilePictureUrl,
      'initialTab': 'submission',
    },
  );

  await fetchCompanyHome();
}

Future<CompanyTaskAssignmentModel?> _findAssignmentForSubmissionAction(
  CompanyRequiredAction action,
) async {
  final taskId = action.taskId ?? 0;
  final studentUserId = action.studentUserId ?? 0;

  if (taskId <= 0) {
    return null;
  }

  try {
    final assignments = await _assignmentsService.getTaskAssignments();

    final submittedMatch = _firstMatchingAssignment(
      assignments,
      taskId: taskId,
      studentUserId: studentUserId,
      requireSubmitted: true,
    );

    if (submittedMatch != null) {
      return submittedMatch;
    }

    return _firstMatchingAssignment(
      assignments,
      taskId: taskId,
      studentUserId: studentUserId,
      requireSubmitted: false,
    );
  } catch (_) {
    return null;
  }
}

CompanyTaskAssignmentModel? _firstMatchingAssignment(
  List<CompanyTaskAssignmentModel> assignments, {
  required int taskId,
  required int studentUserId,
  required bool requireSubmitted,
}) {
  for (final assignment in assignments) {
    final isSameTask = assignment.task.id == taskId;

    final isSameStudent =
        studentUserId <= 0 || assignment.student.id == studentUserId;

    final isSubmitted = assignment.isSubmitted || assignment.submittedAt != null;

    if (isSameTask &&
        isSameStudent &&
        (!requireSubmitted || isSubmitted)) {
      return assignment;
    }
  }

  return null;
}
  Future<void> onRecentActivityPressed(CompanyRecentActivity activity) async {
    switch (activity.targetType) {
      case 'task_applications':
        await _openTaskApplicants(
          taskId: activity.targetId,
        );
        break;

      case 'task_application':
        await _openApplicantDetails(
          applicationId: activity.targetId,
        );
        break;

      case 'task':
        await _openTaskDetails(
          taskId: activity.targetId,
        );
        break;

      default:
        _showUnsupportedAction();
    }
  }

  Future<void> _openApplicantDetails({
    required int applicationId,
  }) async {
    if (applicationId == 0) {
      Get.snackbar(
        'تنبيه',
        'رقم طلب التقديم غير صالح',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await Get.toNamed(
      Routes.companyTaskApplicantDetails,
      arguments: {
        'applicationId': applicationId,
        'taskId': 0,
        'taskTitle': 'المهمة',
        'studentName': 'الطالب',
      },
    );

    await fetchCompanyHome();
  }

  Future<void> _openTaskApplicants({
    required int taskId,
  }) async {
    if (taskId == 0) {
      Get.snackbar(
        'تنبيه',
        'رقم المهمة غير صالح',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await Get.toNamed(
      Routes.companyTaskApplicants,
      arguments: {
        'taskId': taskId,
        'taskTitle': 'المهمة رقم $taskId',
      },
    );

    await fetchCompanyHome();
  }
  Future<void> _openTaskDetails({
    required int taskId,
  }) async {
    if (taskId == 0) {
      Get.snackbar(
        'تنبيه',
        'رقم المهمة غير صالح',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await Get.toNamed(
      Routes.companyTaskDetails,
      arguments: {
        'taskId': taskId,
      },
    );

    await fetchCompanyHome();
  }

  void _showUnsupportedAction() {
    Get.snackbar(
      'تنبيه',
      'نوع الإجراء غير مدعوم حاليًا',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String resolveActionButtonLabel({
    required String targetType,
    required String fallbackLabel,
  }) {
    switch (targetType) {
      case 'task_application':
        return 'مراجعة الطلب';
      case 'task_applications':
        return 'عرض الطلبات';
      case 'task':
        return 'عرض المهمة';
      case 'task_submission':
      return 'مراجعة التسليم';

    case 'conversation':
      return 'فتح المحادثة';

      default:
        return fallbackLabel.trim().isNotEmpty ? fallbackLabel : 'عرض التفاصيل';
    }
  }
}