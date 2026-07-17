import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_details_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_progress_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_assignment_submission_model.dart';
import 'package:jisr_platform/models/company/tasks/company_task_submission_review_model.dart';
import 'package:jisr_platform/services/company/tasks/company_task_assignments_service.dart';

enum AssignmentWorkspaceTab {
  overview,
  progress,
  submission,
  evaluation,
}

class CompanyTaskAssignmentWorkspaceController extends GetxController {
  final CompanyTaskAssignmentsService _assignmentsService;

  CompanyTaskAssignmentWorkspaceController(this._assignmentsService);

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final Rxn<CompanyTaskAssignmentDetailsModel> assignmentDetails =
      Rxn<CompanyTaskAssignmentDetailsModel>();

  final Rx<AssignmentWorkspaceTab> selectedTab =
      AssignmentWorkspaceTab.overview.obs;

  final RxBool isProgressLoading = false.obs;
  final RxString progressErrorMessage = ''.obs;
  final Rxn<CompanyTaskAssignmentProgressModel> assignmentProgress =
      Rxn<CompanyTaskAssignmentProgressModel>();

  final RxBool isSubmissionLoading = false.obs;
  final RxString submissionErrorMessage = ''.obs;
  final Rxn<CompanyTaskAssignmentSubmissionModel> assignmentSubmission =
      Rxn<CompanyTaskAssignmentSubmissionModel>();

  final RxBool isReviewLoading = false.obs;
  final RxBool isSubmittingReview = false.obs;
  final RxString reviewErrorMessage = ''.obs;
  final Rxn<CompanyTaskSubmissionReviewModel> submissionReview =
      Rxn<CompanyTaskSubmissionReviewModel>();

  final reviewFormKey = GlobalKey<FormState>();

  final qualityScoreController = TextEditingController();
  final commitmentScoreController = TextEditingController();
  final communicationScoreController = TextEditingController();
  final feedbackController = TextEditingController();

  final RxString selectedFinalDecision = ''.obs;

  int assignmentId = 0;

  String studentName = 'الطالب';
  String studentEmail = '';
  String? studentProfilePictureUrl;

  bool _hasLoadedSubmission = false;
  bool _hasLoadedReview = false;

  @override
  void onInit() {
    super.onInit();

    _readArguments();

    if (assignmentId <= 0) {
      errorMessage.value = 'معرف التكليف غير صالح';
      return;
    }

fetchAssignmentDetails().then((_) {
  final initialTab = selectedTab.value;

  if (initialTab != AssignmentWorkspaceTab.overview) {
    changeTab(initialTab);
  }
});  }

  @override
  void onClose() {
    qualityScoreController.dispose();
    commitmentScoreController.dispose();
    communicationScoreController.dispose();
    feedbackController.dispose();
    super.onClose();
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
    final initialTab = _readText(arguments['initialTab']);
selectedTab.value = _tabFromArgument(initialTab);
  }
AssignmentWorkspaceTab _tabFromArgument(String value) {
  switch (value) {
    case 'progress':
      return AssignmentWorkspaceTab.progress;

    case 'submission':
      return AssignmentWorkspaceTab.submission;

    case 'evaluation':
      return AssignmentWorkspaceTab.evaluation;

    case 'overview':
    default:
      return AssignmentWorkspaceTab.overview;
  }
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
      errorMessage.value = _cleanError(e);
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  Future<void> refreshAssignmentDetails() async {
    await fetchAssignmentDetails(showLoading: false);
  }

  Future<void> changeTab(AssignmentWorkspaceTab tab) async {
    selectedTab.value = tab;

    switch (tab) {
      case AssignmentWorkspaceTab.overview:
        return;

      case AssignmentWorkspaceTab.progress:
        await fetchAssignmentProgress();
        return;

      case AssignmentWorkspaceTab.submission:
        await fetchTaskAssignmentSubmission();
        return;

      case AssignmentWorkspaceTab.evaluation:
        await _loadEvaluationData();
        return;
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
      progressErrorMessage.value = _cleanError(e);
    } finally {
      if (showLoading) {
        isProgressLoading.value = false;
      }
    }
  }

  Future<void> fetchTaskAssignmentSubmission({
  bool showLoading = true,
  bool forceRefresh = false,
}) async {
  if (!forceRefresh && _hasLoadedSubmission) {
    return;
  }

  try {
    if (showLoading) {
      isSubmissionLoading.value = true;
    }

    submissionErrorMessage.value = '';

    final result = await _assignmentsService.getTaskAssignmentSubmission(
      assignmentId,
    );

    assignmentSubmission.value = result;
    _hasLoadedSubmission = true;

    if (forceRefresh) {
      submissionReview.value = null;
      reviewErrorMessage.value = '';
      _hasLoadedReview = false;
    }
  } catch (e) {
    final rawError = e.toString();
    final cleanMessage = _cleanError(e);

    if (_isMissingSubmissionError(rawError) ||
        _isMissingSubmissionError(cleanMessage)) {
      assignmentSubmission.value = null;
      submissionErrorMessage.value = '';
      _hasLoadedSubmission = true;

      if (forceRefresh) {
        submissionReview.value = null;
        reviewErrorMessage.value = '';
        _hasLoadedReview = false;
      }

      return;
    }

    submissionErrorMessage.value = cleanMessage;
  } finally {
    if (showLoading) {
      isSubmissionLoading.value = false;
    }
  }
}

  Future<void> _loadEvaluationData({
    bool forceRefresh = false,
  }) async {
    await fetchTaskAssignmentSubmission(
      forceRefresh: forceRefresh,
    );

    if (assignmentSubmission.value == null) {
      return;
    }

    await fetchSubmissionReview(
      forceRefresh: forceRefresh,
    );
  }

  Future<void> fetchSubmissionReview({
    bool showLoading = true,
    bool forceRefresh = false,
  }) async {
    final submission = assignmentSubmission.value;

    if (submission == null) {
      return;
    }

    if (!forceRefresh && _hasLoadedReview) {
      return;
    }

    try {
      if (showLoading) {
        isReviewLoading.value = true;
      }

      reviewErrorMessage.value = '';

      final result = await _assignmentsService.getSubmissionReview(
  assignmentId,
      );

      submissionReview.value = result;
      _hasLoadedReview = true;
    } catch (e) {
      reviewErrorMessage.value = _cleanError(e);
    } finally {
      if (showLoading) {
        isReviewLoading.value = false;
      }
    }
  }

  Future<void> submitReview() async {
    final submission = assignmentSubmission.value;

    if (submission == null) {
      _showError('لا يوجد تسليم نهائي يمكن تقييمه');
      return;
    }

    if (!(reviewFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final qualityScore = _parseScore(
      qualityScoreController.text,
    );

    final commitmentScore = _parseScore(
      commitmentScoreController.text,
    );

    final communicationScore = _parseScore(
      communicationScoreController.text,
    );

    if (qualityScore == null ||
        commitmentScore == null ||
        communicationScore == null) {
      _showError('يجب أن تكون جميع الدرجات أرقاماً بين 0 و100');
      return;
    }

    if (selectedFinalDecision.value.trim().isEmpty) {
      _showError('يرجى اختيار القرار النهائي');
      return;
    }

    if (feedbackController.text.trim().isEmpty) {
      _showError('يرجى كتابة ملاحظات التقييم للطالب');
      return;
    }

    final request = CompanyTaskReviewRequest(
      qualityScore: qualityScore,
      commitmentScore: commitmentScore,
      communicationScore: communicationScore,
      finalDecision: selectedFinalDecision.value.trim(),
      feedback: feedbackController.text.trim(),
    );

    try {
      isSubmittingReview.value = true;

      final result = await _assignmentsService.createSubmissionReview(
        submissionId: assignmentId,
        request: request,
      );

      submissionReview.value = result;
      _hasLoadedReview = true;

      await fetchAssignmentDetails(showLoading: false);

      Get.snackbar(
        'تم التقييم',
        'تم حفظ تقييم الطالب بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'تعذر الحفظ',
        _cleanError(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmittingReview.value = false;
    }
  }

  Future<void> refreshWorkspace() async {
    final refreshTasks = <Future<void>>[
      fetchAssignmentDetails(showLoading: false),
    ];

    switch (selectedTab.value) {
      case AssignmentWorkspaceTab.overview:
        break;

      case AssignmentWorkspaceTab.progress:
        refreshTasks.add(
          fetchAssignmentProgress(
            showLoading: false,
            forceRefresh: true,
          ),
        );
        break;

      case AssignmentWorkspaceTab.submission:
        refreshTasks.add(
          fetchTaskAssignmentSubmission(
            showLoading: false,
            forceRefresh: true,
          ),
        );
        break;

      case AssignmentWorkspaceTab.evaluation:
        refreshTasks.add(
          _refreshEvaluationData(),
        );
        break;
    }

    await Future.wait(refreshTasks);
  }

  Future<void> _refreshEvaluationData() async {
    await fetchTaskAssignmentSubmission(
      showLoading: false,
      forceRefresh: true,
    );

    if (assignmentSubmission.value != null) {
      await fetchSubmissionReview(
        showLoading: false,
        forceRefresh: true,
      );
    }
  }

  Future<void> copySubmissionLink(String url) async {
    final normalizedUrl = url.trim();
    final uri = Uri.tryParse(normalizedUrl);

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      Get.snackbar(
        'رابط غير صالح',
        'تعذر قراءة رابط التسليم',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await Clipboard.setData(
      ClipboardData(text: normalizedUrl),
    );

    Get.snackbar(
      'تم نسخ الرابط',
      'تم نسخ رابط التسليم. الصقه في المتصفح لفتحه.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void setFinalDecision(String value) {
    selectedFinalDecision.value = value.trim();
  }

  String assignmentStatusLabel(String status) {
    switch (status) {
      case 'working':
        return 'قيد التنفيذ';
      case 'submitted':
        return 'بانتظار المراجعة';
      case 'reviewed':
        return 'تم التقييم';
      case 'completed':
        return 'مكتملة';
      default:
        return status.isEmpty ? 'غير محددة' : status;
    }
  }

  String submissionStatusLabel(String status) {
    switch (status) {
      case 'submitted':
        return 'تم الإرسال';
      case 'reviewed':
        return 'تم التقييم';
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return status.isEmpty ? 'غير محددة' : status;
    }
  }

  String reviewDecisionLabel(String decision) {
    switch (decision) {
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'needs_revision':
        return 'يحتاج تعديلات';
      default:
        return decision.isEmpty ? 'غير محدد' : decision;
    }
  }

  String submissionTypeLabel(String type) {
    switch (type) {
      case 'github_link':
        return 'رابط GitHub';
      case 'zip_file':
        return 'ملف ZIP';
      case 'demo_link':
        return 'رابط العرض التجريبي';
      case 'mixed':
        return 'تسليم مختلط';
      default:
        return type.isEmpty ? 'غير محدد' : type;
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

  String formatDateTime(DateTime? date) {
    if (date == null) {
      return 'غير محدد';
    }

    final localDate = date.toLocal();

    return '${formatDate(localDate)} - '
        '${_twoDigits(localDate.hour)}:${_twoDigits(localDate.minute)}';
  }

  String? scoreValidator(String? value) {
    final score = _parseScore(value ?? '');

    if (score == null) {
      return 'أدخل رقماً بين 0 و100';
    }

    return null;
  }

  String? feedbackValidator(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'يرجى كتابة ملاحظات التقييم';
    }

    if (text.length < 5) {
      return 'الملاحظات قصيرة جداً';
    }

    return null;
  }

  int? _parseScore(String value) {
    final score = int.tryParse(value.trim());

    if (score == null || score < 0 || score > 100) {
      return null;
    }

    return score;
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

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  String _cleanError(Object error) {
  final rawMessage = error
      .toString()
      .replaceFirst('Exception: ', '')
      .trim();

  return _toUserFriendlyMessage(rawMessage);
}

bool _isMissingSubmissionError(String message) {
  final normalizedMessage = message.toLowerCase();

  return normalizedMessage.contains('no submission') ||
      normalizedMessage.contains('no final submission') ||
      normalizedMessage.contains('final submission') ||
      normalizedMessage.contains('submission not found') ||
      normalizedMessage.contains('not found') ||
      normalizedMessage.contains('لا يوجد تسليم') ||
      normalizedMessage.contains('لا توجد تسليم') ||
      normalizedMessage.contains('لا يوجد تسليم نهائي') ||
      normalizedMessage.contains('لم يرسل الطالب التسليم النهائي') ||
      normalizedMessage.contains('لم يتم إرسال التسليم') ||
      normalizedMessage.contains('غير موجود');
}

String _toUserFriendlyMessage(String rawMessage) {
  final normalizedMessage = rawMessage.toLowerCase();

  if (rawMessage.trim().isEmpty) {
    return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
  }

  if (normalizedMessage.contains('socket') ||
      normalizedMessage.contains('connection') ||
      normalizedMessage.contains('network') ||
      normalizedMessage.contains('failed host lookup')) {
    return 'تعذر الاتصال بالخادم. تأكد من اتصال الإنترنت ثم حاول مرة أخرى.';
  }

  if (normalizedMessage.contains('timeout') ||
      normalizedMessage.contains('انتهت مهلة')) {
    return 'استغرق الاتصال وقتاً أطول من المتوقع. حاول مرة أخرى بعد لحظات.';
  }

  if (normalizedMessage.contains('unauthenticated') ||
      normalizedMessage.contains('unauthorized') ||
      normalizedMessage.contains('401')) {
    return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.';
  }

  if (normalizedMessage.contains('forbidden') ||
      normalizedMessage.contains('403')) {
    return 'لا تملك صلاحية تنفيذ هذا الإجراء.';
  }

  if (normalizedMessage.contains('no submission') ||
      normalizedMessage.contains('no final submission') ||
      normalizedMessage.contains('final submission') ||
      normalizedMessage.contains('لا يوجد') ||
      normalizedMessage.contains('لا توجد')) {
    return 'لم يرسل الطالب التسليم النهائي بعد.';
  }

  if (normalizedMessage.contains('no review') ||
      normalizedMessage.contains('review not found')) {
    return 'لم يتم تقييم هذا التسليم بعد.';
  }

  final arabicMessage = _extractArabicMessage(rawMessage);

  if (arabicMessage.isNotEmpty) {
    return arabicMessage;
  }

  return 'حدث خطأ أثناء تنفيذ العملية. يرجى المحاولة مرة أخرى.';
}

String _extractArabicMessage(String message) {
  final firstPart = message.split('|').first.trim();

  final hasArabicLetters = RegExp(r'[\u0600-\u06FF]').hasMatch(firstPart);

  if (!hasArabicLetters) {
    return '';
  }

  return firstPart;
}
  void _showError(String message) {
    Get.snackbar(
      'تنبيه',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}