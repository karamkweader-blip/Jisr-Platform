import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/mentor/student_mentor_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/student/mentor/student_mentor_service.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentMentorController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final StudentMentorService _service = StudentMentorService();

  late final TabController tabController;
  late final Worker _searchWorker;

  final GlobalKey<FormState> applicationFormKey = GlobalKey<FormState>();
  final TextEditingController professionalTitleController =
      TextEditingController();
  final TextEditingController expertiseController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController linkedinController = TextEditingController();
  final TextEditingController portfolioController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final RxBool isApplicationLoading = true.obs;
  final RxBool isSubmittingApplication = false.obs;
  final RxString applicationLoadError = ''.obs;
  final Rxn<MentorApplicationModel> myApplication =
      Rxn<MentorApplicationModel>();
  final RxString selectedApplicationSpecialization = ''.obs;
  final RxSet<String> selectedMentoringTopics = <String>{}.obs;
  final Rxn<PlatformFile> selectedCv = Rxn<PlatformFile>();

  final RxBool isMentorsLoading = false.obs;
  final RxBool isLoadingMoreMentors = false.obs;
  final RxBool mentorsRequestSucceeded = false.obs;
  final RxString mentorsLoadError = ''.obs;
  final RxList<StudentMentorModel> mentors = <StudentMentorModel>[].obs;
  final Rxn<MentorRecommendationContextModel> recommendationContext =
      Rxn<MentorRecommendationContextModel>();
  final RxString searchQuery = ''.obs;
  final RxString selectedMentorSpecialization = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalMentors = 0.obs;

  final RxBool isMentorDetailsLoading = false.obs;
  final RxBool isOpeningExternalLink = false.obs;
  final RxString mentorDetailsError = ''.obs;
  final Rxn<StudentMentorModel> selectedMentor = Rxn<StudentMentorModel>();

  static const int _perPage = 20;
  static const int _maxCvBytes = 5 * 1024 * 1024;
  int _listRequestNumber = 0;
  int _lastMentorProfileId = 0;
  bool _hasRequestedMentors = false;

  bool get hasMoreMentors => currentPage.value < lastPage.value;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(_handleTabChanged);
    _searchWorker = debounce<String>(
      searchQuery,
      (_) {
        if (_hasRequestedMentors) fetchMentors();
      },
      time: const Duration(milliseconds: 400),
    );
  }

  @override
  void onReady() {
    super.onReady();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    await loadMyApplication();
  }

  void _handleTabChanged() {
    if (tabController.index != 1 || _hasRequestedMentors) return;
    _hasRequestedMentors = true;
    fetchMentors();
  }

  Future<void> loadMyApplication({bool showError = false}) async {
    try {
      isApplicationLoading.value = true;
      applicationLoadError.value = '';
      myApplication.value = await _service.getMyApplication();
    } on MentorApiException catch (error) {
      if (_recoverAuthentication(error)) return;
      applicationLoadError.value = error.message;
      if (showError) {
        JisrSnackbar.show(
          title: error.statusCode == 403
              ? 'غير مصرح'
              : 'تعذر تحميل طلب الإرشاد',
          message: error.message,
          type: JisrSnackbarType.error,
        );
      }
    } catch (error) {
      final message = _cleanError(error);
      applicationLoadError.value = message;
      if (showError) {
        JisrSnackbar.show(
          title: 'تعذر تحميل طلب الإرشاد',
          message: message,
          type: JisrSnackbarType.error,
        );
      }
    } finally {
      isApplicationLoading.value = false;
    }
  }

  Future<void> pickCv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['pdf', 'docx'],
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final extension = file.extension?.toLowerCase();
    if (extension != 'pdf' && extension != 'docx') {
      JisrSnackbar.show(
        title: 'صيغة الملف غير مدعومة',
        message: 'يجب اختيار ملف PDF أو DOCX',
        type: JisrSnackbarType.warning,
      );
      return;
    }
    if (file.size > _maxCvBytes) {
      JisrSnackbar.show(
        title: 'حجم الملف كبير',
        message: 'يجب ألا يزيد حجم السيرة الذاتية عن 5 MB',
        type: JisrSnackbarType.warning,
      );
      return;
    }
    if (file.path == null || file.path!.isEmpty) {
      JisrSnackbar.show(
        title: 'تعذر قراءة الملف',
        message: 'يرجى اختيار السيرة الذاتية من جديد',
        type: JisrSnackbarType.error,
      );
      return;
    }
    selectedCv.value = file;
  }

  void removeCv() => selectedCv.value = null;

  void toggleMentoringTopic(String topic) {
    if (!MentorTopics.values.contains(topic)) return;
    if (selectedMentoringTopics.contains(topic)) {
      selectedMentoringTopics.remove(topic);
    } else {
      selectedMentoringTopics.add(topic);
    }
  }

  Future<void> submitApplication() async {
    if (isSubmittingApplication.value) return;
    if (myApplication.value != null) {
      JisrSnackbar.show(
        title: 'يوجد طلب مسبق',
        message: 'لا يمكن إرسال طلب مرشد جديد',
        type: JisrSnackbarType.warning,
      );
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(applicationFormKey.currentState?.validate() ?? false)) {
      JisrSnackbar.show(
        title: 'تحقق من البيانات',
        message: 'أكمل الحقول المطلوبة وصحح البيانات المبيّنة ثم أرسل الطلب',
        type: JisrSnackbarType.warning,
      );
      return;
    }
    if (selectedMentoringTopics.isEmpty) {
      JisrSnackbar.show(
        title: 'اختر مواضيع الإرشاد',
        message: 'يجب اختيار موضوع إرشاد واحد على الأقل',
        type: JisrSnackbarType.warning,
      );
      return;
    }
    final cv = selectedCv.value;
    if (cv == null || cv.path == null) {
      JisrSnackbar.show(
        title: 'السيرة الذاتية مطلوبة',
        message: 'اختر ملف PDF أو DOCX بحجم لا يتجاوز 5 MB',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    try {
      isSubmittingApplication.value = true;
      final application = await _service.submitApplication(
        specialization: selectedApplicationSpecialization.value,
        professionalTitle: professionalTitleController.text.trim(),
        expertise: expertiseController.text.trim(),
        bio: bioController.text.trim(),
        linkedinUrl: linkedinController.text.trim(),
        githubOrPortfolioUrl: portfolioController.text.trim(),
        whatsappNumber: whatsappController.text.trim(),
        cvPath: cv.path!,
        mentoringTopics: selectedMentoringTopics.toList(),
      );

      myApplication.value = application;
      clearApplicationForm();
      JisrSnackbar.show(
        title: 'تم إرسال الطلب',
        message: 'تم إرسال طلب الانضمام كمرشد وهو الآن قيد المراجعة',
        type: JisrSnackbarType.success,
      );
      await loadMyApplication();
    } on MentorApiException catch (error) {
      if (_recoverAuthentication(error)) return;
      if (error.statusCode == 422 && error.hasError('application')) {
        await loadMyApplication();
        JisrSnackbar.show(
          title: 'يوجد طلب مسبق',
          message: error.message,
          type: JisrSnackbarType.warning,
        );
        return;
      }
      JisrSnackbar.show(
        title: error.statusCode == 403 ? 'غير مصرح' : 'تعذر إرسال الطلب',
        message: error.message,
        type: JisrSnackbarType.error,
      );
    } catch (error) {
      JisrSnackbar.show(
        title: 'تعذر إرسال الطلب',
        message: _cleanError(error),
        type: JisrSnackbarType.error,
      );
    } finally {
      isSubmittingApplication.value = false;
    }
  }

  void clearApplicationForm() {
    professionalTitleController.clear();
    expertiseController.clear();
    bioController.clear();
    linkedinController.clear();
    portfolioController.clear();
    whatsappController.clear();
    selectedApplicationSpecialization.value = '';
    selectedMentoringTopics.clear();
    selectedCv.value = null;
  }

  Future<void> fetchMentors({bool loadMore = false}) async {
    _hasRequestedMentors = true;
    if (loadMore && (isLoadingMoreMentors.value || !hasMoreMentors)) return;
    final requestNumber = ++_listRequestNumber;
    final requestedSearch = searchQuery.value.trim();
    final requestedSpecialization = selectedMentorSpecialization.value;

    try {
      if (loadMore) {
        isLoadingMoreMentors.value = true;
      } else {
        isMentorsLoading.value = true;
        mentorsRequestSucceeded.value = false;
        mentorsLoadError.value = '';
      }

      final response = await _service.getMentors(
        search: requestedSearch.isEmpty ? null : requestedSearch,
        specialization: requestedSpecialization.isEmpty
            ? null
            : requestedSpecialization,
        page: loadMore ? currentPage.value + 1 : 1,
        perPage: _perPage,
      );

      if (requestNumber != _listRequestNumber ||
          requestedSearch != searchQuery.value.trim() ||
          requestedSpecialization != selectedMentorSpecialization.value) {
        return;
      }

      if (loadMore) {
        final existingIds = mentors.map((mentor) => mentor.id).toSet();
        mentors.addAll(
          response.mentors.where(
            (mentor) => !existingIds.contains(mentor.id),
          ),
        );
      } else {
        mentors.assignAll(response.mentors);
      }
      recommendationContext.value = response.recommendationContext;
      currentPage.value = response.pagination.currentPage;
      lastPage.value = response.pagination.lastPage;
      totalMentors.value = response.pagination.total;
      mentorsRequestSucceeded.value = true;
    } on MentorApiException catch (error) {
      if (_recoverAuthentication(error)) return;
      if (requestNumber != _listRequestNumber) return;
      mentorsLoadError.value = error.message;
      if (!loadMore) mentorsRequestSucceeded.value = false;
      if (!loadMore && error.statusCode == 403) {
        mentors.clear();
        recommendationContext.value = null;
      }
      if (error.statusCode == 422) {
        searchController.clear();
        searchQuery.value = '';
        selectedMentorSpecialization.value = '';
      }
      JisrSnackbar.show(
        title: error.statusCode == 403 ? 'غير مصرح' : 'تعذر تحميل المرشدين',
        message: error.message,
        type: JisrSnackbarType.error,
      );
    } catch (error) {
      if (requestNumber != _listRequestNumber) return;
      mentorsLoadError.value = _cleanError(error);
      if (!loadMore) mentorsRequestSucceeded.value = false;
      JisrSnackbar.show(
        title: 'تعذر تحميل المرشدين',
        message: mentorsLoadError.value,
        type: JisrSnackbarType.error,
      );
    } finally {
      if (requestNumber == _listRequestNumber) {
        if (loadMore) {
          isLoadingMoreMentors.value = false;
        } else {
          isMentorsLoading.value = false;
        }
      }
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    currentPage.value = 1;
    lastPage.value = 1;
  }

  Future<void> selectMentorSpecialization(String? value) async {
    selectedMentorSpecialization.value = value ?? '';
    currentPage.value = 1;
    lastPage.value = 1;
    await fetchMentors();
  }

  Future<void> openMentorDetails(int mentorProfileId) async {
    if (mentorProfileId <= 0) return;
    _lastMentorProfileId = mentorProfileId;
    selectedMentor.value = null;
    mentorDetailsError.value = '';
    Get.toNamed(Routes.studentMentorDetails);
    await fetchMentorDetails(mentorProfileId);
  }

  Future<void> retryMentorDetails() async {
    if (_lastMentorProfileId > 0) {
      await fetchMentorDetails(_lastMentorProfileId);
    }
  }

  Future<void> fetchMentorDetails(int mentorProfileId) async {
    try {
      isMentorDetailsLoading.value = true;
      mentorDetailsError.value = '';
      selectedMentor.value = await _service.getMentorDetails(mentorProfileId);
    } on MentorApiException catch (error) {
      if (_recoverAuthentication(error)) return;
      if (error.statusCode == 404) {
        if (Get.currentRoute == Routes.studentMentorDetails) Get.back();
        await fetchMentors();
        JisrSnackbar.show(
          title: 'المرشد غير متاح',
          message: 'لم يعد هذا المرشد متاحاً، تم تحديث القائمة',
          type: JisrSnackbarType.warning,
        );
        return;
      }
      mentorDetailsError.value = error.message;
    } catch (error) {
      mentorDetailsError.value = _cleanError(error);
    } finally {
      isMentorDetailsLoading.value = false;
    }
  }

  Future<void> openExternal(Uri uri) async {
    if (isOpeningExternalLink.value) return;
    try {
      isOpeningExternalLink.value = true;
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      ).timeout(
        const Duration(seconds: 6),
        onTimeout: () => false,
      );
      if (opened) return;
      JisrSnackbar.show(
        title: 'تعذر فتح الرابط',
        message: 'تعذر فتح معلومات التواصل على هذا الجهاز',
        type: JisrSnackbarType.error,
      );
    } catch (_) {
      JisrSnackbar.show(
        title: 'تعذر فتح الرابط',
        message: 'الرابط غير صالح أو لا يوجد تطبيق مناسب لفتحه',
        type: JisrSnackbarType.error,
      );
    } finally {
      isOpeningExternalLink.value = false;
    }
  }

  Future<void> openWebLink(String value) async {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      JisrSnackbar.show(
        title: 'تعذر فتح الرابط',
        message: 'الرابط الذي أعاده الخادم غير صالح',
        type: JisrSnackbarType.error,
      );
      return;
    }
    await openExternal(uri);
  }

  Future<void> openEmail(String email) async {
    if (email.trim().isEmpty) return;
    await openExternal(Uri(scheme: 'mailto', path: email.trim()));
  }

  Future<void> openWhatsapp(String number) async {
    final digits = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return;
    await openExternal(Uri.parse('https://wa.me/$digits'));
  }

  String? requiredText(String? value, String field, int maxLength) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$field مطلوب';
    if (text.length > maxLength) return 'الحد الأقصى $maxLength حرف';
    return null;
  }

  String? specializationValidator(String? value) {
    if (value == null || !MentorSpecializations.values.contains(value)) {
      return 'التخصص مطلوب';
    }
    return null;
  }

  String? urlValidator(String? value, String field) {
    final requiredError = requiredText(value, field, 2048);
    if (requiredError != null) return requiredError;
    final uri = Uri.tryParse(value!.trim());
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return 'أدخل رابطاً صحيحاً يبدأ بـ http أو https';
    }
    return null;
  }

  String dateTimeText(String? value) {
    if (value == null || value.isEmpty) return 'غير محدد';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value.replaceFirst('T', ' ');
    final local = parsed.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  bool _recoverAuthentication(MentorApiException error) {
    if (error.statusCode != 401) return false;
    Get.offAllNamed(Routes.login);
    return true;
  }

  @override
  void onClose() {
    _searchWorker.dispose();
    tabController.removeListener(_handleTabChanged);
    tabController.dispose();
    professionalTitleController.dispose();
    expertiseController.dispose();
    bioController.dispose();
    linkedinController.dispose();
    portfolioController.dispose();
    whatsappController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
