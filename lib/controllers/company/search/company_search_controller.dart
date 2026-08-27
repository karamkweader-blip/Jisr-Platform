import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/models/company/students/company_student_model.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/company/students/company_student_service.dart';

class CompanySearchController extends GetxController {
  final CompanyStudentService _studentService;

  CompanySearchController(this._studentService);

  static const int _perPage = 10;

  final TextEditingController nameController = TextEditingController();

  final RxList<CompanyStudentModel> students =
      <CompanyStudentModel>[].obs;

  final RxList<CompanyStudentFilterSkill> skills =
      <CompanyStudentFilterSkill>[].obs;

  final Rxn<CompanyStudentFilterSkill> selectedSkill =
      Rxn<CompanyStudentFilterSkill>();

  final RxString searchName = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxString skillsErrorMessage = ''.obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isLoadingSkills = false.obs;

  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalStudents = 0.obs;

  Timer? _searchDebounce;
  int _studentsRequestSequence = 0;
  bool _isInitialized = false;

  bool get hasMore {
    return currentPage.value < lastPage.value;
  }

  bool get hasActiveFilters {
    return searchName.value.trim().isNotEmpty ||
        selectedSkill.value != null;
  }

  String get selectedSkillLabel {
    return selectedSkill.value?.name ?? 'كل المهارات';
  }

  Future<void> ensureInitialized() async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;

    // عند فتح تبويب البحث نحمل المهارات فقط.
    // لا نجلب الطلاب قبل أن يكتب المستخدم اسمًا
    // أو يختار مهارة.
    await fetchSkills();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    nameController.dispose();
    super.onClose();
  }

  void onNameChanged(String value) {
    _searchDebounce?.cancel();

    // إلغاء اعتماد أي طلب سابق.
    _studentsRequestSequence++;

    final normalizedName = value.trim();

    // إذا أصبح الاسم فارغًا ولا توجد مهارة مختارة،
    // نمسح النتائج دون استدعاء API الطلاب.
    if (normalizedName.isEmpty &&
        selectedSkill.value == null) {
      searchName.value = '';
      _clearStudentResults();
      return;
    }

    _searchDebounce = Timer(
      const Duration(milliseconds: 450),
      () {
        searchName.value = normalizedName;
        fetchStudents();
      },
    );
  }

  Future<void> clearName() async {
    _searchDebounce?.cancel();

    nameController.clear();
    searchName.value = '';

    // إذا لم تكن هناك مهارة مختارة فلا يوجد بحث.
    if (selectedSkill.value == null) {
      _clearStudentResults();
      return;
    }

    // إذا توجد مهارة نعيد البحث باستخدام المهارة فقط.
    await fetchStudents();
  }

  Future<void> selectSkill(
    CompanyStudentFilterSkill? skill,
  ) async {
    if (selectedSkill.value?.id == skill?.id) {
      return;
    }

    _searchDebounce?.cancel();

    searchName.value = nameController.text.trim();
    selectedSkill.value = skill;

    // إذا أزال المستخدم المهارة والاسم فارغ،
    // نمسح النتائج دون استدعاء API.
    if (!hasActiveFilters) {
      _clearStudentResults();
      return;
    }

    await fetchStudents();
  }

  Future<void> clearFilters() async {
    _searchDebounce?.cancel();

    nameController.clear();
    searchName.value = '';
    selectedSkill.value = null;

    _clearStudentResults();
  }

  Future<void> refresh() async {
    final requests = <Future<void>>[
      fetchSkills(
        showLoading: skills.isEmpty,
      ),
    ];

    // لا نحدّث الطلاب إذا لم يبدأ المستخدم بحثًا.
    if (hasActiveFilters) {
      requests.add(fetchStudents());
    }

    await Future.wait<void>(requests);
  }

  Future<void> fetchStudents({
    bool loadMore = false,
  }) async {
    // حماية إضافية تمنع جلب جميع الطلاب
    // عندما لا يوجد اسم ولا مهارة.
    if (!hasActiveFilters) {
      _clearStudentResults();
      return;
    }

    if (loadMore &&
        (!hasMore ||
            isLoading.value ||
            isLoadingMore.value)) {
      return;
    }

    final requestSequence = ++_studentsRequestSequence;

    final requestedPage = loadMore
        ? currentPage.value + 1
        : 1;

    try {
      if (loadMore) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
        errorMessage.value = '';
      }

      final result = await _studentService.getStudents(
        name: searchName.value,
        skillId: selectedSkill.value?.id,
        page: requestedPage,
        perPage: _perPage,
      );

      // تجاهل نتيجة أي طلب قديم وصل بعد طلب أحدث.
      if (requestSequence != _studentsRequestSequence) {
        return;
      }

      if (loadMore) {
        final knownIds = students
            .map((student) => student.id)
            .toSet();

        students.addAll(
          result.students.where(
            (student) => knownIds.add(student.id),
          ),
        );
      } else {
        students.assignAll(result.students);
      }

      currentPage.value =
          result.pagination.currentPage;

      lastPage.value =
          result.pagination.lastPage;

      totalStudents.value =
          result.pagination.total;
    } catch (error) {
      if (requestSequence ==
          _studentsRequestSequence) {
        errorMessage.value = _cleanError(error);
      }
    } finally {
      if (requestSequence ==
          _studentsRequestSequence) {
        isLoading.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> fetchSkills({
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        isLoadingSkills.value = true;
      }

      skillsErrorMessage.value = '';

      skills.assignAll(
        await _studentService.getAvailableSkills(),
      );
    } catch (error) {
      skillsErrorMessage.value =
          _cleanError(error);
    } finally {
      isLoadingSkills.value = false;
    }
  }

  void openStudent(
    CompanyStudentModel student,
  ) {
    Get.toNamed(
      Routes.companyStudentDetails,
      arguments: <String, dynamic>{
        'studentId': student.id,
      },
    );
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '');
  }

  void _clearStudentResults() {
    // إلغاء اعتماد أي طلب ما زال قيد التنفيذ.
    _studentsRequestSequence++;

    students.clear();
    errorMessage.value = '';

    isLoading.value = false;
    isLoadingMore.value = false;

    currentPage.value = 1;
    lastPage.value = 1;
    totalStudents.value = 0;
  }
}