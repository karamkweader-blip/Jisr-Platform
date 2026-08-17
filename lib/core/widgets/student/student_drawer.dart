import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/auth_actions_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/views/student/complaints/complaint_entry_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentDrawer extends StatefulWidget {
  const StudentDrawer({super.key});

  @override
  State<StudentDrawer> createState() => _StudentDrawerState();
}

class _StudentDrawerState extends State<StudentDrawer> {
  static const _languageKey = 'student_language';
  static const _appearanceKey = 'student_appearance';

  String _language = 'ar';
  String _appearance = 'light';

  AuthActionsController get _authController {
    if (Get.isRegistered<AuthActionsController>()) {
      return Get.find<AuthActionsController>();
    }
    return Get.put(AuthActionsController(), permanent: true);
  }

  bool get _isDark => _appearance == 'dark';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    final savedLanguage = preferences.getString(_languageKey) ?? 'ar';
    final savedAppearance = preferences.getString(_appearanceKey) ?? 'light';

    Get.updateLocale(Locale(savedLanguage));
    Get.changeThemeMode(
      savedAppearance == 'dark' ? ThemeMode.dark : ThemeMode.light,
    );

    if (!mounted) return;
    setState(() {
      _language = savedLanguage;
      _appearance = savedAppearance;
    });
  }

  Future<void> _changeLanguage(String value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageKey, value);
    Get.updateLocale(Locale(value));
    if (mounted) setState(() => _language = value);
  }

  Future<void> _changeAppearance(String value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_appearanceKey, value);
    Get.changeThemeMode(value == 'dark' ? ThemeMode.dark : ThemeMode.light);
    if (mounted) setState(() => _appearance = value);
  }

  void _openRoute(String route) {
    Navigator.of(context).pop();
    if (Get.currentRoute == route) return;
    Future<void>.delayed(
      const Duration(milliseconds: 160),
      () => Get.toNamed(route),
    );
  }

  void _openComplaints() {
    Navigator.of(context).pop();
    Future<void>.delayed(const Duration(milliseconds: 160), () {
      final rootContext = Get.context;
      if (rootContext != null) ComplaintEntrySheet.show(rootContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = _StudentDrawerPalette(_isDark);

    return Drawer(
      width: MediaQuery.of(context).size.width * .84,
      elevation: 18,
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
            _header(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 22),
                children: [
                  _sectionLabel('مساحتك', palette),
                  _menuTile(
                    palette,
                    Icons.description_outlined,
                    'السيرة الذاتية',
                    'رفع السيرة وتحليلها',
                    () => _openRoute(Routes.cvUpload),
                  ),
                  _menuTile(
                    palette,
                    Icons.work_history_rounded,
                    'البورتفوليو',
                    'مشاريعك وإنجازاتك',
                    () => _openRoute(Routes.studentPortfolio),
                  ),
                  _menuTile(
                    palette,
                    Icons.fact_check_outlined,
                    'تقديمات الفرص',
                    'تابع حالة طلباتك',
                    () => _openRoute(Routes.studentOpportunityApplications),
                  ),
                  _menuTile(
                    palette,
                    Icons.assignment_turned_in_outlined,
                    'تقديمات التاسكات',
                    'المقبولة وقيد المراجعة',
                    () => _openRoute(Routes.studentTaskApplications),
                  ),
                  _menuTile(
                    palette,
                    Icons.assignment_ind_outlined,
                    'مهامي المسندة',
                    'مهام المشرف والتسليمات',
                    () => _openRoute(Routes.studentAssignedTasks),
                  ),
                  _menuTile(
                    palette,
                    Icons.event_available_outlined,
                    'مقابلاتي',
                    'المواعيد والتفاصيل',
                    () => _openRoute(Routes.studentInterviews),
                  ),
                  const SizedBox(height: 14),
                  _sectionLabel('التطوير والمجتمع', palette),
                  _menuTile(
                    palette,
                    Icons.groups_outlined,
                    'المجتمع التقني',
                    'أسئلة ونقاشات الطلاب',
                    () => _openRoute(Routes.studentCommunityPosts),
                  ),
                  _menuTile(
                    palette,
                    Icons.stars_outlined,
                    'نقاطي',
                    'تابع تقدمك وإنجازاتك',
                    () => _openRoute(Routes.studentPoints),
                  ),
                  _menuTile(
                    palette,
                    Icons.analytics_outlined,
                    'تحليل سوق العمل',
                    'المهارات والاتجاهات المطلوبة',
                    () => _openRoute(Routes.studentMarketAnalysis),
                  ),
                  _menuTile(
                    palette,
                    Icons.school_outlined,
                    'الإرشاد المهني',
                    'اكتشف المرشدين ومسارك',
                    () => _openRoute(Routes.studentMentors),
                  ),
                  _menuTile(
                    palette,
                    Icons.report_problem_outlined,
                    'الشكاوى',
                    'أرسل شكوى من السياق الصحيح',
                    _openComplaints,
                  ),
                  const SizedBox(height: 14),
                  _sectionLabel('الإعدادات', palette),
                  _menuTile(
                    palette,
                    Icons.language_rounded,
                    'اللغة',
                    _language == 'ar' ? 'العربية' : 'English',
                    () => _showLanguageSheet(palette),
                    trailing: _badge(_language == 'ar' ? 'AR' : 'EN'),
                  ),
                  _menuTile(
                    palette,
                    _isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    'المظهر',
                    _isDark ? 'الوضع الداكن' : 'الوضع الفاتح',
                    () => _showAppearanceSheet(palette),
                  ),
                  const SizedBox(height: 18),
                  Obx(
                    () => _logoutButton(
                      palette,
                      loading: _authController.isLoading.value,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.person_rounded, color: AppColors.primaryBlue, size: 31),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مساحة الطالب',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text(
                  'كل أدواتك المهنية في مكان واحد',
                  style: TextStyle(color: Colors.white70, fontSize: 10.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, _StudentDrawerPalette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 7, 5, 8),
      child: Text(
        text,
        style: TextStyle(
          color: palette.muted,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _menuTile(
    _StudentDrawerPalette palette,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: palette.card,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(_isDark ? .18 : .07)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(_isDark ? .22 : .08),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: AppColors.primaryBlue, size: 21),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: palette.text, fontSize: 13, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: palette.muted, fontSize: 9.5)),
                    ],
                  ),
                ),
                trailing ?? const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.actionYellow, size: 13),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.actionYellow.withOpacity(.13),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.actionYellow, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _logoutButton(_StudentDrawerPalette palette, {required bool loading}) {
    return OutlinedButton.icon(
      onPressed: loading ? null : _authController.logout,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        side: const BorderSide(color: Color(0xFFD84A4A)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      ),
      icon: loading
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.logout_rounded, color: Color(0xFFD84A4A)),
      label: const Text('تسجيل الخروج', style: TextStyle(color: Color(0xFFD84A4A), fontWeight: FontWeight.w800)),
    );
  }

  void _showLanguageSheet(_StudentDrawerPalette palette) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: palette.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _ChoiceSheet(
        title: 'اختر اللغة',
        selected: _language,
        choices: const {'ar': 'العربية', 'en': 'English'},
        onSelected: (value) {
          Navigator.pop(context);
          _changeLanguage(value);
        },
      ),
    );
  }

  void _showAppearanceSheet(_StudentDrawerPalette palette) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: palette.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _ChoiceSheet(
        title: 'اختر المظهر',
        selected: _appearance,
        choices: const {'light': 'الوضع الفاتح', 'dark': 'الوضع الداكن'},
        onSelected: (value) {
          Navigator.pop(context);
          _changeAppearance(value);
        },
      ),
    );
  }
}

class _ChoiceSheet extends StatelessWidget {
  final String title;
  final String selected;
  final Map<String, String> choices;
  final ValueChanged<String> onSelected;

  const _ChoiceSheet({required this.title, required this.selected, required this.choices, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(color: AppColors.primaryBlue, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              ...choices.entries.map(
                (entry) => RadioListTile<String>(
                  value: entry.key,
                  groupValue: selected,
                  activeColor: AppColors.actionYellow,
                  title: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w700)),
                  onChanged: (value) {
                    if (value != null) onSelected(value);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentDrawerPalette {
  final bool dark;

  const _StudentDrawerPalette(this.dark);

  Color get background => dark ? const Color(0xFF0D1722) : AppColors.background;
  Color get card => dark ? const Color(0xFF162332) : Colors.white;
  Color get text => dark ? const Color(0xFFEAF2FA) : AppColors.textDark;
  Color get muted => dark ? const Color(0xFF91A4B8) : AppColors.textGrey;
}
