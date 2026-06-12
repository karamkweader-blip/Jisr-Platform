import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/company_profile_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/views/company/profile/widgets/profile_shared_widgets.dart';
import 'package:jisr_platform/views/company/profile/widgets/profile_widgets.dart';


class CompanyProfileView extends GetView<CompanyProfileController> {
  const CompanyProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            );
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return ProfileErrorState(
              message: controller.errorMessage.value,
              onRetry: controller.fetchProfile,
            );
          }

          final profile = controller.profile.value;

          if (profile == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            );
          }

          final user = profile.primaryUser;

          return RefreshIndicator(
            onRefresh: controller.fetchProfile,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                28,
              ),
              children: [
                PageTitle(
                  onEditPressed: controller.goToEditProfile,
                ),

                const SizedBox(height: 18),

                CompanyIdentityCard(
                  profile: profile,
                  user: user,
                  verificationLabel: user == null
                      ? 'غير موثّق'
                      : controller.verificationLabel(
                          user.verificationStatus,
                        ),
                ),

                const SizedBox(height: 18),

                ProfileSectionCard(
                  title: 'معلومات الشركة',
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    8,
                  ),
                  children: [
                    InfoTile(
                      icon: Icons.business_center_outlined,
                      label: 'مجال العمل',
                      value: profile.industry,
                    ),
                    InfoTile(
                      icon: Icons.location_on_outlined,
                      label: 'الموقع',
                      value: profile.location,
                    ),
                    InfoTile(
                      icon: Icons.language_rounded,
                      label: 'الموقع الإلكتروني',
                      value: profile.website,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                if (user != null)
                  ProfileSectionCard(
                    title: 'معلومات الحساب',
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      8,
                    ),
                    children: [
                      InfoTile(
                        icon: Icons.email_outlined,
                        label: 'البريد الإلكتروني',
                        value: user.email,
                      ),
                      InfoTile(
                        icon: Icons.verified_user_outlined,
                        label: 'حالة التوثيق',
                        value: controller.verificationLabel(
                          user.verificationStatus,
                        ),
                      ),
                      InfoTile(
                        icon: Icons.circle_outlined,
                        label: 'حالة الحساب',
                        value: user.isActive
                            ? 'نشط'
                            : 'غير نشط',
                      ),
                    ],
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}