import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/company/mentor/company_mentor_constants.dart';
import 'package:jisr_platform/models/company/mentor/company_mentor_nomination_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/mentor/company_mentor_nomination_service.dart';

class CompanyMentorNominationFormController extends GetxController {
  final CompanyMentorNominationService _service;
  final AuthService _authService;

  CompanyMentorNominationFormController(
    this._service,
    this._authService,
  );

  static const int _maxCvBytes = 5 * 1024 * 1024;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController professionalTitleController =
      TextEditingController();

  final TextEditingController expertiseController =
      TextEditingController();

  final TextEditingController bioController =
      TextEditingController();

  final TextEditingController linkedinController =
      TextEditingController();

  final TextEditingController portfolioController =
      TextEditingController();

  final TextEditingController whatsappController =
      TextEditingController();

  final RxString selectedSpecialization = ''.obs;

  final RxSet<String> selectedMentoringTopics =
      <String>{}.obs;

  final Rxn<PlatformFile> selectedCv =
      Rxn<PlatformFile>();

  final RxBool isSubmitting = false.obs;

  final RxMap<String, String> fieldErrors =
      <String, String>{}.obs;

  Future<void> pickCv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>[
        'pdf',
        'docx',
      ],
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.first;
    final extension = file.extension?.toLowerCase();

    if (extension != 'pdf' && extension != 'docx') {
      JisrSnackbar.show(
        title: 'صيغة الملف غير مدعومة',
        message:
            'اختر ملف سيرة ذاتية بصيغة PDF أو DOCX',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    if (file.size > _maxCvBytes) {
      JisrSnackbar.show(
        title: 'حجم الملف كبير',
        message:
            'يجب ألا يزيد حجم السيرة الذاتية عن 5 MB',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    if (file.path == null ||
        file.path!.trim().isEmpty) {
      JisrSnackbar.show(
        title: 'تعذر قراءة الملف',
        message:
            'يرجى اختيار ملف السيرة الذاتية من جديد',
        type: JisrSnackbarType.error,
      );
      return;
    }

    selectedCv.value = file;
    clearFieldError('cv');
  }

  void removeCv() {
    selectedCv.value = null;
    clearFieldError('cv');
  }

  void selectSpecialization(String? value) {
    selectedSpecialization.value = value ?? '';
    clearFieldError('specialization');
  }

  void toggleMentoringTopic(String topic) {
    if (!CompanyMentorTopics.values.contains(topic)) {
      return;
    }

    if (selectedMentoringTopics.contains(topic)) {
      selectedMentoringTopics.remove(topic);
    } else {
      selectedMentoringTopics.add(topic);
    }

    clearFieldError('mentoring_topics');
  }

  void clearFieldError(String key) {
    if (fieldErrors.remove(key) != null) {
      formKey.currentState?.validate();
    }
  }

  String? requiredText(
    String key,
    String? value,
    String label,
    int maxLength,
  ) {
    final backendError = fieldErrors[key];

    if (backendError != null) {
      return backendError;
    }

    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return '$label مطلوب';
    }

    if (text.length > maxLength) {
      return 'الحد الأقصى $maxLength حرف';
    }

    return null;
  }

  String? emailValidator(String? value) {
    final requiredError = requiredText(
      'email',
      value,
      'البريد الإلكتروني',
      254,
    );

    if (requiredError != null) {
      return requiredError;
    }

    if (!GetUtils.isEmail(value!.trim())) {
      return 'أدخل بريدًا إلكترونيًا صحيحًا';
    }

    return null;
  }

  String? urlValidator(
    String key,
    String? value,
    String label,
  ) {
    final requiredError = requiredText(
      key,
      value,
      label,
      2048,
    );

    if (requiredError != null) {
      return requiredError;
    }

    final uri = Uri.tryParse(value!.trim());

    if (uri == null ||
        (uri.scheme != 'http' &&
            uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return 'أدخل رابطًا صحيحًا يبدأ بـ http أو https';
    }

    return null;
  }

  String? specializationValidator(String? value) {
    final backendError =
        fieldErrors['specialization'];

    if (backendError != null) {
      return backendError;
    }

    if (value == null ||
        !CompanyMentorSpecializations.values
            .contains(value)) {
      return 'التخصص مطلوب';
    }

    return null;
  }

  Future<void> submit() async {
    if (isSubmitting.value) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    fieldErrors.clear();

    final isFormValid =
        formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      _showValidationWarning();
      return;
    }

    if (selectedMentoringTopics.isEmpty) {
      fieldErrors['mentoring_topics'] =
          'اختر موضوع إرشاد واحدًا على الأقل';

      _showValidationWarning();
      return;
    }

    final cv = selectedCv.value;

    if (cv == null ||
        cv.path == null ||
        cv.path!.trim().isEmpty) {
      fieldErrors['cv'] =
          'ملف السيرة الذاتية مطلوب';

      _showValidationWarning();
      return;
    }

    final nomination =
        CompanyMentorNominationRequest(
      fullName: fullNameController.text.trim(),
      email:
          emailController.text.trim().toLowerCase(),
      whatsappNumber:
          whatsappController.text.trim(),
      specialization:
          selectedSpecialization.value,
      professionalTitle:
          professionalTitleController.text.trim(),
      expertise:
          expertiseController.text.trim(),
      bio: bioController.text.trim(),
      linkedinUrl:
          linkedinController.text.trim(),
      githubOrPortfolioUrl:
          portfolioController.text.trim(),
      mentoringTopics:
          selectedMentoringTopics.toList(
        growable: false,
      ),
    );

    try {
      isSubmitting.value = true;

      final createdNomination =
          await _service.submitNomination(
        nomination: nomination,
        cvPath: cv.path!,
      );

      _clearTemporaryState();

      Get.back(
        result: createdNomination,
      );
    } on CompanyMentorApiException catch (error) {
      if (await _recoverAuthentication(error)) {
        return;
      }

      if (error.statusCode == 422) {
        _applyBackendErrors(error);

        JisrSnackbar.show(
          title: error.hasError('email')
              ? 'تعذر ترشيح هذا البريد'
              : 'تحقق من بيانات الترشيح',
          message: error.message,
          type: JisrSnackbarType.warning,
        );

        return;
      }

      JisrSnackbar.show(
        title: error.statusCode == 403
            ? 'لا يمكن إرسال الترشيح'
            : 'تعذر إرسال الترشيح',
        message: error.message,
        type: JisrSnackbarType.error,
      );
    } catch (error) {
      JisrSnackbar.show(
        title: 'تعذر إرسال الترشيح',
        message: _cleanError(error),
        type: JisrSnackbarType.error,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _applyBackendErrors(
    CompanyMentorApiException error,
  ) {
    final normalizedErrors = <String, String>{};

    for (final key in error.errors.keys) {
      final message = error.fieldMessage(key);

      if (message == null) {
        continue;
      }

      final normalizedKey =
          key.startsWith('mentoring_topics.')
              ? 'mentoring_topics'
              : key;

      normalizedErrors.putIfAbsent(
        normalizedKey,
        () => message,
      );
    }

    fieldErrors.assignAll(normalizedErrors);
    formKey.currentState?.validate();
  }

  void _showValidationWarning() {
    JisrSnackbar.show(
      title: 'تحقق من البيانات',
      message:
          'أكمل الحقول المطلوبة وصحح البيانات المبيّنة',
      type: JisrSnackbarType.warning,
    );
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

  void _clearTemporaryState() {
    selectedCv.value = null;
    selectedMentoringTopics.clear();
    fieldErrors.clear();
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('TimeoutException: ', '');
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    professionalTitleController.dispose();
    expertiseController.dispose();
    bioController.dispose();
    linkedinController.dispose();
    portfolioController.dispose();
    whatsappController.dispose();

    super.onClose();
  }
}