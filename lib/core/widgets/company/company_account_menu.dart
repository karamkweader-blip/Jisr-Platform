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
    final colorScheme =
        Theme.of(context).colorScheme;

    return PopupMenuButton<_CompanyMenuAction>(
      tooltip: 'إعدادات الحساب',
      color: colorScheme.surface,
      elevation: 10,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colorScheme.outlineVariant,
        ),
      ),
      icon: const Icon(
        Icons.settings_rounded,
        color: AppColors.primaryBlue,
      ),
      onSelected: (value) {
        if (value == _CompanyMenuAction.logout) {
          _showLogoutDialog(context);
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem<_CompanyMenuAction>(
            value: _CompanyMenuAction.logout,
            child: Row(
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: AppColors.dangerRed,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    color: colorScheme.onSurface,
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

  void _showLogoutDialog(BuildContext context) {
    final logoutAllSessions = false.obs;
    final colorScheme =
        Theme.of(context).colorScheme;

    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: colorScheme.outlineVariant,
            ),
          ),
          titlePadding: const EdgeInsets.fromLTRB(
            22,
            22,
            22,
            8,
          ),
          contentPadding:
              const EdgeInsets.fromLTRB(
                22,
                10,
                22,
                0,
              ),
          actionsPadding:
              const EdgeInsets.fromLTRB(
                14,
                6,
                14,
                14,
              ),
          title: Text(
            'تأكيد تسجيل الخروج',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'هل تريد تسجيل الخروج من حساب الشركة؟',
                  style: TextStyle(
                    color: colorScheme
                        .onSurfaceVariant,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme
                        .surfaceContainer,
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme
                          .outlineVariant,
                    ),
                  ),
                  child: CheckboxListTile(
                    value:
                        logoutAllSessions.value,
                    onChanged:
                        controller.isLoading.value
                        ? null
                        : (value) {
                            logoutAllSessions
                                    .value =
                                value ?? false;
                          },
                    activeColor:
                        AppColors.primaryBlue,
                    controlAffinity:
                        ListTileControlAffinity
                            .leading,
                    contentPadding:
                        const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                    title: Text(
                      'تسجيل الخروج من جميع الجلسات',
                      style: TextStyle(
                        color:
                            colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      'فعّلها إذا أردت إنهاء الجلسة من كل الأجهزة.',
                      style: TextStyle(
                        color: colorScheme
                            .onSurfaceVariant,
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
                onPressed:
                    controller.isLoading.value
                    ? null
                    : Get.back,
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    color: colorScheme
                        .onSurfaceVariant,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ),
            Obx(
              () => ElevatedButton(
                onPressed:
                    controller.isLoading.value
                    ? null
                    : () async {
                        await controller
                            .companyLogout(
                              logoutAllSessions:
                                  logoutAllSessions
                                      .value,
                            );
                      },
                child:
                    controller.isLoading.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                      )
                    : const Text(
                        'تأكيد',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w800,
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