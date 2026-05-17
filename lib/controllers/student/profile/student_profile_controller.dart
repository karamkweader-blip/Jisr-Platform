import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/profile/student_profile_model.dart';
import 'package:jisr_platform/services/student/profile/student_profile_service.dart';

class StudentProfileController extends GetxController {
  final StudentProfileService _service = StudentProfileService();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  final Rxn<StudentProfileModel> profile = Rxn<StudentProfileModel>();
  final Rxn<File> selectedImage = Rxn<File>();

  final ImagePicker _picker = ImagePicker();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();
  final universityController = TextEditingController();
  final majorController = TextEditingController();
  final graduationYearController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;

      final response = await _service.getProfile();

      profile.value = response.data;

      _fillControllers(response.data);
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

  void _fillControllers(StudentProfileModel data) {
    nameController.text = data.user.name;
    emailController.text = data.user.email;
    bioController.text = data.user.bio ?? '';
    universityController.text = data.university ?? '';
    majorController.text = data.major ?? '';
    graduationYearController.text = data.graduationYear ?? '';
    phoneController.text = data.phone ?? '';
  }

  Future<void> pickProfileImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  Future<void> saveProfile() async {
    try {
      isSaving.value = true;

      final response = await _service.updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        bio: bioController.text.trim(),
        university: universityController.text.trim(),
        major: majorController.text.trim(),
        graduationYear: graduationYearController.text.trim(),
        phone: phoneController.text.trim(),
        profileImage: selectedImage.value,
      );

      profile.value = response.data;

      _fillControllers(response.data);

      selectedImage.value = null;

      JisrSnackbar.show(
        title: 'تم الحفظ',
        message: 'تم تحديث الملف الشخصي بنجاح',
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

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
    universityController.dispose();
    majorController.dispose();
    graduationYearController.dispose();
    phoneController.dispose();

    super.onClose();
  }
}
