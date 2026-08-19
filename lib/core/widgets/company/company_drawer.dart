import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/company_drawer_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class CompanyDrawer extends GetView<CompanyDrawerController> {
  const CompanyDrawer({super.key});

  static const Color _danger = Color(0xFFD84A4A);

  static const String _description =
      'منصة جسور تربط الطلاب بسوق العمل عبر تحليل المهارات، '
      'تحديد الفجوات المهنية، واقتراح المهام والتدريبات وفرص العمل '
      'المناسبة. كما تساعد الشركات على الوصول إلى المرشحين الأنسب '
      'اعتمادًا على المهارات والأداء العملي.';

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final palette = _DrawerPalette(controller.isDarkMode);
      final user = controller.profileController.profile.value?.primaryUser;

      final name = user?.name.trim().isNotEmpty == true
          ? user!.name.trim()
          : 'حساب الشركة';

      final email = user?.email.trim().isNotEmpty == true
          ? user!.email.trim()
          : 'بيانات الحساب غير متاحة';

      return Drawer(
        width: MediaQuery.of(context).size.width * 0.80,
        elevation: 16,
        backgroundColor: palette.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(
                name: name,
                email: email,
                imageUrl: user?.profilePictureUrl,
                verified: user?.isVerified == true,
                verificationLabel:
                    controller.profileController.verificationLabel(
                  user?.verificationStatus ?? '',
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    14,
                    14,
                    14,
                    20,
                  ),
                  children: [
                    _menuTile(
                      palette: palette,
                      icon: Icons.business_outlined,
                      title: 'الملف التعريفي للشركة',
                      subtitle: 'عرض بيانات الشركة وتعديلها',
                      onTap: () {
                        Navigator.of(context).pop();
                        controller.openProfile();
                      },
                    ),
                    const SizedBox(height: 9),
                    _menuTile(
                      palette: palette,
                      icon: Icons.query_stats_rounded,
                      title: 'تحليل سوق العمل',
                      subtitle: 'اكتشف المهارات والاتجاهات المطلوبة',
                      onTap: () async {
                        final rootContext = await _closeDrawer(context);

                        if (rootContext == null) {
                          return;
                        }

                        Get.toNamed(Routes.companyMarketAnalysis);
                      },
                    ),
                    const SizedBox(height: 9),
                    _menuTile(
                      palette: palette,
                      icon: Icons.volunteer_activism_rounded,
                      title: 'ترشيحات المرشدين',
                      subtitle: 'رشّح موظفًا وتابع حالة الترشيح',
                      onTap: () async {
                        final rootContext = await _closeDrawer(context);

                        if (rootContext == null) {
                          return;
                        }

                        Get.toNamed(Routes.companyMentorNominations);
                      },
                    ),
                    const SizedBox(height: 9),
_menuTile(
  palette: palette,
  icon: Icons.support_agent_rounded,
  title: 'شكاواي',
  subtitle: 'تابع الشكاوى ونتائج مراجعتها',
  onTap: () async {
    final rootContext =
        await _closeDrawer(context);

    if (rootContext == null) {
      return;
    }

    Get.toNamed(Routes.companyComplaints);
  },
),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 5,
                      ),
                      child: Text(
                        'الإعدادات',
                        style: TextStyle(
                          color: palette.mutedText,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _menuTile(
                      palette: palette,
                      icon: Icons.translate_rounded,
                      title: 'اللغة',
                      subtitle: controller.languageLabel,
                      onTap: () {
                        _showLanguageSheet(context);
                      },
                    ),
                    const SizedBox(height: 9),
                    _menuTile(
                      palette: palette,
                      icon: controller.isDarkMode
                          ? Icons.brightness_2_rounded
                          : Icons.wb_sunny_rounded,
                      title: 'المظهر',
                      subtitle: controller.appearanceLabel,
                      onTap: () {
                        _showAppearanceSheet(context);
                      },
                    ),
                    const SizedBox(height: 9),
                    _menuTile(
                      palette: palette,
                      icon: Icons.info_outline_rounded,
                      title: 'حول جسور',
                      subtitle: 'عن المنصة والتواصل',
                      onTap: () {
                        _showAboutSheet(context);
                      },
                    ),
                    const SizedBox(height: 18),
                    _clockCard(palette),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: palette.mutedText,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'جسور · الإصدار '
                          '${CompanyDrawerController.appVersion}',
                          style: TextStyle(
                            color: palette.mutedText,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _logoutButton(
                      dark: controller.isDarkMode,
                      loading: controller.authController.isLoading.value,
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader({
    required String name,
    required String email,
    required String? imageUrl,
    required bool verified,
    required String verificationLabel,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        18,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -52,
            left: -34,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.055),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'حساب الشركة',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  _avatar(
                    name,
                    imageUrl,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10.5,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                verified
                                    ? Icons.verified_user_rounded
                                    : Icons.access_time_rounded,
                                color: verified
                                    ? const Color(0xFFBFE8D1)
                                    : const Color(0xFFFFE0A2),
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  verificationLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatar(
    String name,
    String? imageUrl,
  ) {
    final hasImage = imageUrl?.trim().isNotEmpty == true;

    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    final initials = parts.isEmpty
        ? 'ش'
        : parts.length == 1
            ? parts.first[0]
            : '${parts.first[0]}${parts.last[0]}';

    Widget fallback() {
      return ColoredBox(
        color: Colors.white,
        child: Center(
          child: Text(
            initials,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.65),
        ),
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return fallback();
                },
              )
            : fallback(),
      ),
    );
  }

  Widget _menuTile({
    required _DrawerPalette palette,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: palette.border,
            ),
          ),
          child: ListTile(
            minLeadingWidth: 40,
            horizontalTitleGap: 9,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.09),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ),
            title: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.text,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.mutedText,
                fontSize: 10,
              ),
            ),
            trailing: Container(
              width: 31,
              height: 31,
              decoration: BoxDecoration(
                color: AppColors.actionYellow.withOpacity(
                  palette.dark ? 0.16 : 0.10,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.actionYellow.withOpacity(
                    palette.dark ? 0.22 : 0.16,
                  ),
                ),
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.actionYellow,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _clockCard(
    _DrawerPalette palette,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.065),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.09),
        ),
      ),
      child: Row(
        children: [
          _squareIcon(
            Icons.schedule_rounded,
            size: 42,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.formattedTime,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  controller.formattedDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 9.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.09),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _logoutButton({
    required bool dark,
    required bool loading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _danger,
          backgroundColor: _danger.withOpacity(
            dark ? 0.08 : 0.045,
          ),
          side: BorderSide(
            color: _danger.withOpacity(0.25),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: loading
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _danger,
                ),
              )
            : const Icon(
                Icons.logout_rounded,
                size: 19,
              ),
        label: Text(
          loading ? 'جارٍ تسجيل الخروج...' : 'تسجيل الخروج',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Future<void> _showLanguageSheet(
    BuildContext context,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Obx(() {
          final palette = _DrawerPalette(
            controller.isDarkMode,
          );

          return _sheet(
            context: sheetContext,
            palette: palette,
            icon: Icons.language_rounded,
            title: 'اختيار اللغة',
            subtitle: 'اختر لغة واجهة منصة جسور',
            child: Column(
              children: [
                _choiceTile(
                  palette: palette,
                  badge: 'AR',
                  title: 'العربية',
                  subtitle: 'واجهة عربية من اليمين إلى اليسار',
                  selected: controller.languageCode.value == 'ar',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    controller.changeLanguage('ar');
                  },
                ),
                const SizedBox(height: 10),
                _choiceTile(
                  palette: palette,
                  badge: 'EN',
                  title: 'English',
                  subtitle: 'English interface from left to right',
                  selected: controller.languageCode.value == 'en',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    controller.changeLanguage('en');
                  },
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _showAppearanceSheet(
    BuildContext context,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Obx(() {
          final palette = _DrawerPalette(
            controller.isDarkMode,
          );

          return _sheet(
            context: sheetContext,
            palette: palette,
            icon: Icons.color_lens_outlined,
            title: 'اختيار المظهر',
            subtitle: 'اختر الوضع الأكثر راحة لعينيك',
            child: Row(
              children: [
                Expanded(
                  child: _themeChoice(
                    palette: palette,
                    sun: true,
                    title: 'نهاري',
                    subtitle: 'واضح ومشرق',
                    selected: controller.appearance.value == 'light',
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      controller.changeAppearance('light');
                    },
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: _themeChoice(
                    palette: palette,
                    sun: false,
                    title: 'داكن',
                    subtitle: 'هادئ في الليل',
                    selected: controller.appearance.value == 'dark',
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      controller.changeAppearance('dark');
                    },
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _showAboutSheet(
    BuildContext context,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Obx(() {
          final palette = _DrawerPalette(
            controller.isDarkMode,
          );

          return _sheet(
            context: sheetContext,
            palette: palette,
            icon: Icons.info_outline_rounded,
            title: 'حول جسور',
            subtitle: 'منصة أقرب للطلاب والشركات',
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.065),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(0.10),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.hub_outlined,
                              color: Colors.white,
                              size: 23,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              'منصة جسور',
                              style: TextStyle(
                                color: palette.text,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          _badge(
                            'v${CompanyDrawerController.appVersion}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      Text(
                        _description,
                        style: TextStyle(
                          color: palette.mutedText,
                          fontSize: 12.5,
                          height: 1.75,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: palette.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: palette.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _squareIcon(
                            Icons.code_rounded,
                            color: AppColors.actionYellow,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'التواصل مع المطور',
                                  style: TextStyle(
                                    color: palette.text,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  CompanyDrawerController.contactEmail,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(
                                    color: palette.mutedText,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: controller.openContactEmail,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          icon: const Icon(
                            Icons.email_outlined,
                            size: 19,
                          ),
                          label: const Text(
                            'إرسال بريد إلكتروني',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _sheet({
    required BuildContext context,
    required _DrawerPalette palette,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            18,
            10,
            18,
            math.max(
              MediaQuery.of(context).padding.bottom,
              18.0,
            ),
          ),
          decoration: BoxDecoration(
            color: palette.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: palette.border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _squareIcon(
                      icon,
                      size: 48,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: palette.text,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: palette.mutedText,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _choiceTile({
    required _DrawerPalette palette,
    required String badge,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return _selectable(
      palette: palette,
      selected: selected,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryBlue
                  : AppColors.primaryBlue.withOpacity(0.09),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          _checkCircle(
            selected,
            palette,
          ),
        ],
      ),
    );
  }

  Widget _themeChoice({
    required _DrawerPalette palette,
    required bool sun,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final color =
        sun ? AppColors.actionYellow : AppColors.primaryBlue;

    return _selectable(
      palette: palette,
      selected: selected,
      onTap: onTap,
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0,
              end: 1,
            ),
            duration: const Duration(milliseconds: 850),
            curve: Curves.easeOutBack,
            builder: (_, value, child) {
              return Transform.rotate(
                angle: sun ? value * 0.16 : (value - 1) * 0.12,
                child: Transform.scale(
                  scale: value,
                  child: child,
                ),
              );
            },
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: color.withOpacity(0.11),
                shape: BoxShape.circle,
              ),
              child: Icon(
                sun
                    ? Icons.wb_sunny_rounded
                    : Icons.brightness_2_rounded,
                color: color,
                size: 29,
              ),
            ),
          ),
          const SizedBox(height: 11),
          Text(
            title,
            style: TextStyle(
              color: palette.text,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 9),
          _checkCircle(
            selected,
            palette,
          ),
        ],
      ),
    );
  }

  Widget _selectable({
    required _DrawerPalette palette,
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Material(
      color: selected
          ? AppColors.primaryBlue.withOpacity(0.075)
          : palette.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 230),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? AppColors.primaryBlue
                  : palette.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _checkCircle(
    bool selected,
    _DrawerPalette palette,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 23,
      height: 23,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primaryBlue
            : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? AppColors.primaryBlue
              : palette.border,
        ),
      ),
      child: selected
          ? const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 15,
            )
          : null,
    );
  }

  Widget _squareIcon(
    IconData icon, {
    Color color = AppColors.primaryBlue,
    double size = 44,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: color,
        size: size * 0.5,
      ),
    );
  }

  Future<void> _showLogoutDialog(
    BuildContext context,
  ) async {
    final rootContext = await _closeDrawer(context);

    if (rootContext == null) {
      return;
    }

    var allSessions = false;

    final palette = _DrawerPalette(
      controller.isDarkMode,
    );

    final confirmed = await showDialog<bool>(
      context: rootContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                backgroundColor: palette.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _danger.withOpacity(0.11),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: _danger,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'هل تريد تسجيل الخروج من حساب الشركة؟',
                      style: TextStyle(
                        color: palette.mutedText,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Material(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () {
                          setDialogState(() {
                            allSessions = !allSessions;
                          });
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: palette.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: allSessions,
                                activeColor: AppColors.primaryBlue,
                                onChanged: (value) {
                                  setDialogState(() {
                                    allSessions = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  'إنهاء الجلسات على جميع الأجهزة',
                                  style: TextStyle(
                                    color: palette.text,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(false);
                    },
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                        color: palette.mutedText,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: _danger,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (confirmed == true) {
      await controller.logout(
        logoutAllSessions: allSessions,
      );
    }
  }

  Future<BuildContext?> _closeDrawer(
    BuildContext context,
  ) async {
    final rootNavigator = Navigator.of(
      context,
      rootNavigator: true,
    );

    Navigator.of(context).pop();

    await Future<void>.delayed(
      const Duration(milliseconds: 260),
    );

    return rootNavigator.mounted
        ? rootNavigator.context
        : null;
  }
}

class _DrawerPalette {
  final bool dark;

  const _DrawerPalette(this.dark);

  Color get background {
    return dark
        ? const Color(0xFF0E1822)
        : AppColors.cardWhite;
  }

  Color get card {
    return dark
        ? const Color(0xFF162430)
        : AppColors.background;
  }

  Color get text {
    return dark
        ? const Color(0xFFF3F7FA)
        : AppColors.textDark;
  }

  Color get mutedText {
    return dark
        ? const Color(0xFFA9BAC7)
        : AppColors.textGrey;
  }

  Color get border {
    return dark
        ? const Color(0xFF263A49)
        : const Color(0xFFE4EBF1);
  }
}