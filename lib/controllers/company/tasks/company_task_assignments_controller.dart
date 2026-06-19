import 'package:get/get.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/company/tasks/company_task_assignments_service.dart';

class CompanyTaskAssignmentsController extends GetxController {
  final CompanyTaskAssignmentsService _assignmentsService;

  CompanyTaskAssignmentsController(this._assignmentsService);

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString selectedStatus = 'all'.obs;

  final RxList<CompanyTaskAssignmentModel> assignments =
      <CompanyTaskAssignmentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAssignments();
  }

  List<CompanyTaskAssignmentModel> get visibleAssignments {
    final filteredAssignments = assignments.where((assignment) {
      if (selectedStatus.value == 'all') {
        return true;
      }

      return assignment.status == selectedStatus.value;
    }).toList();

    filteredAssignments.sort((first, second) {
      final firstPriority = _statusPriority(first.status);
      final secondPriority = _statusPriority(second.status);

      if (firstPriority != secondPriority) {
        return firstPriority.compareTo(secondPriority);
      }

      final firstDeadline =
          first.task.deadline?.millisecondsSinceEpoch ?? 9999999999999;

      final secondDeadline =
          second.task.deadline?.millisecondsSinceEpoch ?? 9999999999999;

      return firstDeadline.compareTo(secondDeadline);
    });

    return filteredAssignments;
  }

  Future<void> fetchAssignments({
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }

      errorMessage.value = '';

      final result = await _assignmentsService.getTaskAssignments();
      assignments.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  Future<void> refreshAssignments() async {
    await fetchAssignments(showLoading: false);
  }

  void selectStatus(String status) {
    selectedStatus.value = status;
  }

  int countForStatus(String status) {
    if (status == 'all') {
      return assignments.length;
    }

    return assignments.where((assignment) {
      return assignment.status == status;
    }).length;
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

  String deadlineHint(DateTime? deadline) {
    if (deadline == null) {
      return 'لا يوجد موعد نهائي';
    }

    final difference = deadline.toLocal().difference(DateTime.now());

    if (difference.isNegative) {
      return 'انتهى الموعد';
    }

    if (difference.inDays == 0) {
      return 'ينتهي اليوم';
    }

    if (difference.inDays == 1) {
      return 'ينتهي غدًا';
    }

    return 'ينتهي خلال ${difference.inDays} أيام';
  }

  int _statusPriority(String status) {
    switch (status) {
      case 'submitted':
        return 0;
      case 'working':
        return 1;
      case 'completed':
        return 2;
      default:
        return 3;
    }
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
  
  Future<void> goToAssignmentWorkspace(
  CompanyTaskAssignmentModel assignment,
) async {
  await Get.toNamed(
    Routes.companyTaskAssignmentWorkspace,
    arguments: {
      'assignmentId': assignment.assignmentId,
      'studentName': assignment.student.name,
      'studentEmail': assignment.student.email,
      'studentProfilePictureUrl': assignment.student.profilePictureUrl,
    },
  );

  await refreshAssignments();
}
}