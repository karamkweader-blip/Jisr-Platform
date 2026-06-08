import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/company_profile_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/company_profile_model.dart';

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
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return _ProfileErrorState(
              message: controller.errorMessage.value,
              onRetry: controller.fetchProfile,
            );
          }

          final profile = controller.profile.value;

          if (profile == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          final user = profile.primaryUser;

          return RefreshIndicator(
            onRefresh: controller.fetchProfile,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
               _PageTitle(
  onEditPressed: controller.goToEditProfile,
),

                const SizedBox(height: 18),
                _CompanyIdentityCard(
                  profile: profile,
                  user: user,
                  verificationLabel: user == null
                      ? 'غير موثّق'
                      : controller.verificationLabel(user.verificationStatus),
                ),
                const SizedBox(height: 18),
                _InfoSection(
                  title: 'معلومات الشركة',
                  children: [
                    _InfoTile(
                      icon: Icons.business_center_outlined,
                      label: 'مجال العمل',
                      value: profile.industry,
                    ),
                    _InfoTile(
                      icon: Icons.location_on_outlined,
                      label: 'الموقع',
                      value: profile.location,
                    ),
                    _InfoTile(
                      icon: Icons.language_rounded,
                      label: 'الموقع الإلكتروني',
                      value: profile.website,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (user != null)
                  _InfoSection(
                    title: 'معلومات الحساب',
                    children: [
                      _InfoTile(
                        icon: Icons.email_outlined,
                        label: 'البريد الإلكتروني',
                        value: user.email,
                      ),
                      _InfoTile(
                        icon: Icons.verified_user_outlined,
                        label: 'حالة التوثيق',
                        value: controller.verificationLabel(
                          user.verificationStatus,
                        ),
                      ),
                      _InfoTile(
                        icon: Icons.circle_outlined,
                        label: 'حالة الحساب',
                        value: user.isActive ? 'نشط' : 'غير نشط',
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

class _PageTitle extends StatelessWidget {
  final VoidCallback onEditPressed;

  const _PageTitle({
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ملف الشركة',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'معلومات الحساب والبيانات الأساسية للشركة',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onEditPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.10),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.edit_rounded,
                  color: AppColors.primaryBlue,
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(
                  'تعديل',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompanyIdentityCard extends StatelessWidget {
  final CompanyProfileModel profile;
  final CompanyProfileUserModel? user;
  final String verificationLabel;

  const _CompanyIdentityCard({
    required this.profile,
    required this.user,
    required this.verificationLabel,
  });

  @override
  Widget build(BuildContext context) {
    final companyName = user?.name.trim().isNotEmpty == true
        ? user!.name.trim()
        : 'اسم الشركة';

    final profileImage = user?.profilePictureUrl;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _CompanyAvatar(
                imageUrl: profileImage,
                companyName: companyName,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 7,
                      runSpacing: 5,
                      children: [
                        Text(
                          companyName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            height: 1.25,
                          ),
                        ),
                        if (user?.isVerified == true)
                          const Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      profile.industry.isEmpty ? 'مجال العمل غير محدد' : profile.industry,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _HeaderMiniBadge(
                icon: Icons.verified_user_outlined,
                label: verificationLabel,
              ),
              const SizedBox(width: 10),
              _HeaderMiniBadge(
                icon: Icons.location_on_outlined,
                label: profile.location.isEmpty ? 'غير محدد' : profile.location,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompanyAvatar extends StatelessWidget {
  final String? imageUrl;
  final String companyName;

  const _CompanyAvatar({
    required this.imageUrl,
    required this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter = companyName.trim().isEmpty
        ? '؟'
        : companyName.trim().characters.first.toUpperCase();

    return Container(
      height: 66,
      width: 66,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.28),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: imageUrl == null || imageUrl!.isEmpty
            ? Center(
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Center(
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _HeaderMiniBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderMiniBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cleanValue = value.trim().isEmpty ? 'غير محدد' : value.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.075),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cleanValue,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14.2,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.primaryBlue,
                size: 38,
              ),
              const SizedBox(height: 12),
              const Text(
                'تعذر تحميل الملف',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}