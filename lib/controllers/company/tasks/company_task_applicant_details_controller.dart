import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/models/company/tasks/company_task_applicant_details_model.dart';
import 'package:jisr_platform/services/company/tasks/company_task_applicant_details_service.dart';

class CompanyTaskApplicantDetailsController extends GetxController {
  final CompanyTaskApplicantDetailsService _detailsService;

  CompanyTaskApplicantDetailsController(this._detailsService);

  final RxBool isLoading = false.obs;
  final RxBool isAccepting = false.obs;
  final RxBool isRejecting = false.obs;

  final RxString errorMessage = ''.obs;
  final Rxn<CompanyTaskApplicantDetailsModel> applicantDetails =
      Rxn<CompanyTaskApplicantDetailsModel>();

  late final int taskId;
  late final int applicationId;
  late final String taskTitle;
  late final String studentName;

final TextEditingController companyNotesController = TextEditingController();

final RxString decisionType = ''.obs;
final RxString notesError = ''.obs;
final RxString decisionMessage = ''.obs;
  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;

    taskId = int.tryParse(args?['taskId']?.toString() ?? '') ?? 0;

    applicationId =
        int.tryParse(args?['applicationId']?.toString() ?? '') ?? 0;

    taskTitle = args?['taskTitle']?.toString() ?? 'المهمة';
    studentName = args?['studentName']?.toString() ?? 'الطالب';

    if (applicationId == 0) {
      errorMessage.value = 'رقم طلب التقديم غير صالح';
      return;
    }

    fetchApplicantDetails();
  }

ApplicantStudentSkillModel? matchedStudentSkill(
  ApplicantRequiredSkillModel requiredSkill,
) {
  final details = applicantDetails.value;
  if (details == null) return null;

  final requiredName = requiredSkill.name.trim().toLowerCase();

  for (final skill in details.student.skills) {
    final studentSkillName = skill.name.trim().toLowerCase();

    if (studentSkillName == requiredName) {
      return skill;
    }
  }

  return null;
}
 Future<void> fetchApplicantDetails({
  bool showFullScreenLoading = true,
}) async {
  try {
    if (showFullScreenLoading) {
      isLoading.value = true;
    }

    errorMessage.value = '';

    final result = await _detailsService.getApplicantDetails(applicationId);
    applicantDetails.value = result;
  } catch (e) {
    errorMessage.value = e.toString().replaceFirst('Exception: ', '');
  } finally {
    if (showFullScreenLoading) {
      isLoading.value = false;
    }
  }
}
  Future<void> refreshApplicantDetails() async {
  await fetchApplicantDetails(showFullScreenLoading: false);
}

 
void startAcceptDecision() {
  final details = applicantDetails.value;
  if (details == null) return;

  if (!details.application.isPending) {
    decisionMessage.value = 'تمت مراجعة هذا الطلب مسبقاً';
    return;
  }

  decisionType.value = 'accept';
  notesError.value = '';
  decisionMessage.value = '';
  companyNotesController.clear();
}

void startRejectDecision() {
  final details = applicantDetails.value;
  if (details == null) return;

  if (!details.application.isPending) {
    decisionMessage.value = 'تمت مراجعة هذا الطلب مسبقاً';
    return;
  }

  decisionType.value = 'reject';
  notesError.value = '';
  decisionMessage.value = '';
  companyNotesController.clear();
}

void cancelDecision() {
  decisionType.value = '';
  notesError.value = '';
  companyNotesController.clear();
}

Future<void> submitDecision() async {
  final notes = companyNotesController.text.trim();

  if (notes.isEmpty) {
    notesError.value = 'يرجى كتابة ملاحظة قبل التأكيد';
    return;
  }

  if (decisionType.value == 'accept') {
    await acceptApplicant(notes);
    return;
  }

  if (decisionType.value == 'reject') {
    await rejectApplicant(notes);
    return;
  }
}

Future<void> acceptApplicant(String companyNotes) async {
  if (isAccepting.value || isRejecting.value) return;

  try {
    isAccepting.value = true;
    notesError.value = '';
    decisionMessage.value = '';

    await _detailsService.acceptApplication(
      applicationId: applicationId,
      companyNotes: companyNotes,
    );

    decisionType.value = '';
    companyNotesController.clear();
    decisionMessage.value = 'تم قبول الطالب بنجاح';

    await fetchApplicantDetails(showFullScreenLoading: false);
  } catch (e) {
    notesError.value = e.toString().replaceFirst('Exception: ', '');
  } finally {
    isAccepting.value = false;
  }
}

Future<void> rejectApplicant(String companyNotes) async {
  if (isAccepting.value || isRejecting.value) return;

  try {
    isRejecting.value = true;
    notesError.value = '';
    decisionMessage.value = '';

    await _detailsService.rejectApplication(
      applicationId: applicationId,
      companyNotes: companyNotes,
    );

    decisionType.value = '';
    companyNotesController.clear();
    decisionMessage.value = 'تم رفض الطالب بنجاح';

    await fetchApplicantDetails(showFullScreenLoading: false);
  } catch (e) {
    notesError.value = e.toString().replaceFirst('Exception: ', '');
  } finally {
    isRejecting.value = false;
  }
}

 
  String applicationStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'بانتظار المراجعة';
      case 'accepted':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  String difficultyLabel(String level) {
    switch (level) {
      case 'beginner':
        return 'مبتدئ';
      case 'intermediate':
        return 'متوسط';
      case 'advanced':
        return 'متقدم';
      default:
        return level;
    }
  }

  String skillLevelLabel(int level) {
    if (level <= 0) return 'غير محدد';
    return 'مستوى $level';
  }

  String confidenceLabel(double confidence) {
    final percent = (confidence * 100).round();
    return '$percent% ثقة';
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';

    final local = date.toLocal();

    return '${local.year}/${_twoDigits(local.month)}/${_twoDigits(local.day)}';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  @override
void onClose() {
  companyNotesController.dispose();
  super.onClose();
}
}