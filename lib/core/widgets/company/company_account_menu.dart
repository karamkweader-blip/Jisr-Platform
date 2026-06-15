import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/auth/auth_actions_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

enum _CompanyMenuAction {
  logout,
}

class CompanyAccountMenu extends StatelessWidget {
  final AuthActionsController controller;

  const CompanyAccountMenu({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_CompanyMenuAction>(
      tooltip: 'إعدادات الحساب',
      color: Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      icon: const Icon(
        Icons.settings_rounded,
        color: AppColors.primaryBlue,
      ),
      onSelected: (value) {
        if (value == _CompanyMenuAction.logout) {
          _showLogoutDialog();
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem<_CompanyMenuAction>(
            value: _CompanyMenuAction.logout,
            child: Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }

  void _showLogoutDialog() {
    final logoutAllSessions = false.obs;

    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
          contentPadding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
          actionsPadding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
          title: const Text(
            'تأكيد تسجيل الخروج',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'هل تريد تسجيل الخروج من حساب الشركة؟',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(.08),
                    ),
                  ),
                  child: CheckboxListTile(
                    value: logoutAllSessions.value,
                    onChanged: controller.isLoading.value
                        ? null
                        : (value) {
                            logoutAllSessions.value = value ?? false;
                          },
                    activeColor: AppColors.primaryBlue,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    title: const Text(
                      'تسجيل الخروج من جميع الجلسات',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: const Text(
                      'فعّلها إذا أردت إنهاء الجلسة من كل الأجهزة.',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Obx(
              () => TextButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => Get.back(),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        await controller.companyLogout(
                          logoutAllSessions: logoutAllSessions.value,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'تأكيد',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}