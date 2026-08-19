import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/notifications/notifications_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/routes/app_routes.dart';

class NotificationBellButton
    extends GetView<NotificationsController> {
  const NotificationBellButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness ==
        Brightness.dark;

    return Tooltip(
      message: 'الإشعارات',
      child: SizedBox(
        width: 38,
        height: 38,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Material(
                color: isDarkMode
                    ? const Color(0xFF17283A)
                    : AppColors.cardWhite,
                borderRadius:
                    BorderRadius.circular(13),
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(13),
                  onTap: () {
                    Get.toNamed(
                      Routes.notifications,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(13),
                      border: Border.all(
                        color: AppColors.primaryBlue
                            .withOpacity(
                          isDarkMode
                              ? 0.24
                              : 0.08,
                        ),
                      ),
                    ),
                    child: const Icon(
                      Icons
                          .notifications_none_rounded,
                      color:
                          AppColors.primaryBlue,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),

            Obx(() {
              final count =
                  controller.unreadCount.value;

              if (count <= 0) {
                return const SizedBox.shrink();
              }

              return PositionedDirectional(
                top: -6,
                end: -6,
                child: Container(
                  constraints:
                      const BoxConstraints(
                    minWidth: 19,
                    minHeight: 19,
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 5,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed,
                    borderRadius:
                        BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.cardWhite,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    count > 99
                        ? '99+'
                        : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight:
                          FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}