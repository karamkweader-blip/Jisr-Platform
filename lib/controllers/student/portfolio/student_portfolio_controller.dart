import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/portfolio/student_portfolio_model.dart';
import 'package:jisr_platform/services/student/portfolio/student_portfolio_service.dart';

class StudentPortfolioController extends GetxController {
  final StudentPortfolioService _service = StudentPortfolioService();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingDetails = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;

  final RxList<PortfolioProjectModel> projects = <PortfolioProjectModel>[].obs;
  final Rxn<PortfolioProjectModel> selectedProject =
      Rxn<PortfolioProjectModel>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final projectUrlController = TextEditingController();
  final completionDateController = TextEditingController();
  final gradeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    try {
      isLoading.value = true;
      final response = await _service.getProjects();
      projects.assignAll(response.data);
    } catch (e) {
      JisrSnackbar.show(
        title: 'خطأ',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProjectDetails(int projectId) async {
    try {
      isLoadingDetails.value = true;
      final response = await _service.getProjectDetails(projectId);
      selectedProject.value = response.data;
      _fillForm(response.data);
    } catch (e) {
      JisrSnackbar.show(
        title: 'خطأ',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    } finally {
      isLoadingDetails.value = false;
    }
  }

  void prepareAdd() {
    selectedProject.value = null;
    clearForm();
  }

  void prepareEdit(PortfolioProjectModel project) {
    selectedProject.value = project;
    _fillForm(project);
  }

  void _fillForm(PortfolioProjectModel project) {
    titleController.text = project.title;
    descriptionController.text = project.description;
    projectUrlController.text = project.projectUrl;
    completionDateController.text = _dateOnly(project.completionDate);
    gradeController.text = project.grade?.toString() ?? '';
  }

  String _dateOnly(String? value) {
    if (value == null || value.isEmpty) return '';
    return value.split('T').first;
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    projectUrlController.clear();
    completionDateController.clear();
    gradeController.clear();
  }

  Future<void> saveProject() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final projectUrl = projectUrlController.text.trim();

    if (title.isEmpty || description.isEmpty || projectUrl.isEmpty) {
      JisrSnackbar.show(
        title: 'حقول ناقصة',
        message: 'العنوان والوصف والرابط مطلوبة',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    if (!projectUrl.startsWith('http://') &&
        !projectUrl.startsWith('https://')) {
      JisrSnackbar.show(
        title: 'رابط غير صحيح',
        message: 'يجب أن يبدأ رابط المشروع بـ https:// أو http://',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    try {
      isSaving.value = true;

      final current = selectedProject.value;
      late PortfolioProjectModel savedProject;

      if (current == null) {
        final response = await _service.addProject(
          title: title,
          description: description,
          projectUrl: projectUrl,
          completionDate: completionDateController.text.trim(),
          grade: gradeController.text.trim(),
        );

        savedProject = response.data;
        projects.insert(0, savedProject);
      } else {
        final response = await _service.updateProject(
          projectId: current.id,
          title: title,
          description: description,
          projectUrl: projectUrl,
          completionDate: completionDateController.text.trim(),
          grade: gradeController.text.trim(),
        );

        savedProject = response.data;

        final index = projects.indexWhere((item) => item.id == savedProject.id);

        if (index != -1) {
          projects[index] = savedProject;
          projects.refresh();
        }

        selectedProject.value = savedProject;
        selectedProject.refresh();
      }

      Get.back();

      JisrSnackbar.show(
        title: 'تم الحفظ',
        message: current == null ? 'تمت إضافة المشروع' : 'تم تعديل المشروع',
        type: JisrSnackbarType.success,
      );
    } catch (e) {
      JisrSnackbar.show(
        title: 'فشل الحفظ',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteSelectedProject() async {
    final project = selectedProject.value;
    if (project == null) return;

    try {
      isDeleting.value = true;

      await _service.deleteProject(project.id);

      projects.removeWhere((item) => item.id == project.id);
      selectedProject.value = null;

      Get.back();
      Get.back();

      JisrSnackbar.show(
        title: 'تم الحذف',
        message: 'تم حذف المشروع من البورتفوليو',
        type: JisrSnackbarType.success,
      );
    } catch (e) {
      JisrSnackbar.show(
        title: 'فشل الحذف',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    } finally {
      isDeleting.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    projectUrlController.dispose();
    completionDateController.dispose();
    gradeController.dispose();
    super.onClose();
  }
}
