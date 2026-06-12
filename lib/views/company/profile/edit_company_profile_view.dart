import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/edit_company_profile_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/validators/app_validators.dart';
import 'package:jisr_platform/views/company/profile/widgets/edit_profile_widgets.dart';
import 'package:jisr_platform/views/company/profile/widgets/profile_shared_widgets.dart';

class EditCompanyProfileView extends GetView<EditCompanyProfileController> {
  const EditCompanyProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          'تعديل ملف الشركة',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            children: [
              const EditHeader(),
              const SizedBox(height: 22),

              ProfileSectionCard(
                title: 'معلومات الحساب',
                subtitle: 'هذه البيانات تظهر كهوية أساسية لحساب الشركة.',
                children: [
                  ProfileInput(
                    controller: controller.nameController,
                    label: 'اسم الشركة',
                    icon: Icons.business_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال اسم الشركة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  ProfileInput(
                    controller: controller.emailController,
                    label: 'البريد الإلكتروني',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: AppValidators.email,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              ProfileSectionCard(
                title: 'معلومات الشركة',
                subtitle: 'ساعد الطلاب على فهم مجال الشركة وموقعها.',
                children: [
                  ProfileInput(
                    controller: controller.industryController,
                    label: 'مجال العمل',
                    icon: Icons.work_outline_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال مجال العمل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  ProfileInput(
                    controller: controller.locationController,
                    label: 'الموقع',
                    icon: Icons.location_on_outlined,
                    validator: AppValidators.location,
                  ),
                  const SizedBox(height: 12),
                  ProfileInput(
                    controller: controller.websiteController,
                    label: 'الموقع الإلكتروني',
                    icon: Icons.language_rounded,
                    keyboardType: TextInputType.url,
                    validator: AppValidators.website,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Obx(
                () => SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.submitChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      disabledBackgroundColor: AppColors.primaryBlue
                          .withOpacity(0.45),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'حفظ التعديلات',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
