import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/notifications/notifications_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/notifications/app_notification_model.dart';

class NotificationsView
    extends GetView<NotificationsController> {
  const NotificationsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor:
              Theme.of(context)
                  .scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            'الإشعارات',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            Obx(() {
              if (controller
                  .notifications.isEmpty) {
                return const SizedBox(
                  width: 48,
                );
              }

              return IconButton(
                tooltip: 'تعليم الكل كمقروء',
                onPressed: () {
                  controller.markAllAsRead();
                },
                icon: const Icon(
                  Icons.done_all_rounded,
                  color: AppColors.primaryBlue,
                ),
              );
            }),
          ],
        ),
        body: _NotificationPageLifecycle(
          onOpen:
              controller
                  .onNotificationCenterOpened,
          child: Obx(() {
            if (controller.isLoading.value &&
                controller
                    .notifications.isEmpty) {
              return const Center(
                child:
                    CircularProgressIndicator(
                  color:
                      AppColors.primaryBlue,
                ),
              );
            }

            final error =
                controller.errorMessage.value;

            if (error != null &&
                controller
                    .notifications.isEmpty) {
              return _NotificationsErrorState(
                message: error,
                onRetry: controller.retry,
              );
            }

            if (controller
                .notifications.isEmpty) {
              return const _EmptyNotificationsState();
            }

            return RefreshIndicator(
              color: AppColors.primaryBlue,
              onRefresh: () {
                return controller
                    .loadNotifications(
                  refresh: true,
                );
              },
              child: ListView.separated(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  28,
                ),
                itemCount: controller
                    .notifications.length,
                separatorBuilder:
                    (context, index) {
                  return const SizedBox(
                    height: 10,
                  );
                },
                itemBuilder:
                    (context, index) {
                  final notification =
                      controller
                          .notifications[index];

                  return _NotificationCard(
                    notification:
                        notification,
                    onTap: () {
                      controller.markAsRead(
                        notification,
                      );
                    },
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NotificationPageLifecycle
    extends StatefulWidget {
  final Future<void> Function() onOpen;
  final Widget child;

  const _NotificationPageLifecycle({
    required this.onOpen,
    required this.child,
  });

  @override
  State<_NotificationPageLifecycle>
      createState() {
    return _NotificationPageLifecycleState();
  }
}

class _NotificationPageLifecycleState
    extends State<_NotificationPageLifecycle> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      widget.onOpen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _NotificationCard
    extends StatelessWidget {
  final AppNotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness ==
        Brightness.dark;

    /*
     * الإشعارات التي عمرها أقل من ساعة
     * تظهر بخلفية رمادية خفيفة.
     */
    final recentColor = isDarkMode
        ? const Color(0xFF1C2D3D)
        : const Color(0xFFF0F3F6);

    final cardColor =
        notification.isRecent
            ? recentColor
            : isDarkMode
                ? const Color(0xFF162332)
                : AppColors.cardWhite;

    return Material(
      color: cardColor,
      borderRadius:
          BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(20),
        child: Container(
          padding:
              const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.primaryBlue
                      .withOpacity(0.06)
                  : AppColors.primaryBlue
                      .withOpacity(0.22),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(
                  isDarkMode
                      ? 0.10
                      : 0.025,
                ),
                blurRadius: 14,
                offset:
                    const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _NotificationIcon(
                type: notification.type,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white
                                  : AppColors
                                      .textDark,
                              fontSize: 14.5,
                              fontWeight:
                                  FontWeight
                                      .w900,
                              height: 1.4,
                            ),
                          ),
                        ),

                        if (!notification
                            .isRead) ...[
                          const SizedBox(
                            width: 8,
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            margin:
                                const EdgeInsets
                                    .only(
                              top: 6,
                            ),
                            decoration:
                                const BoxDecoration(
                              color: AppColors
                                  .dangerRed,
                              shape:
                                  BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      notification.body,
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white70
                            : AppColors
                                .textGrey,
                        fontSize: 12.5,
                        height: 1.55,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        Icon(
                          Icons
                              .schedule_rounded,
                          size: 13,
                          color: AppColors
                              .primaryBlue
                              .withOpacity(
                            0.72,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          _formatRelativeTime(
                            notification
                                .createdAt,
                          ),
                          style: TextStyle(
                            color: AppColors
                                .primaryBlue
                                .withOpacity(
                              0.75,
                            ),
                            fontSize: 10.5,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        if (notification
                                .actor !=
                            null) ...[
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 3,
                            height: 3,
                            decoration:
                                BoxDecoration(
                              color: AppColors
                                  .textGrey
                                  .withOpacity(
                                0.5,
                              ),
                              shape:
                                  BoxShape.circle,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Text(
                              notification
                                  .actor!.name,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                color:
                                    AppColors
                                        .textGrey,
                                fontSize: 10.5,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(
    DateTime date,
  ) {
    final difference =
        DateTime.now().toUtc().difference(
      date.toUtc(),
    );

    if (difference.isNegative ||
        difference.inSeconds < 60) {
      return 'الآن';
    }

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    }

    if (difference.inHours < 24) {
      final hours = difference.inHours;

      if (hours == 1) {
        return 'منذ ساعة';
      }

      if (hours == 2) {
        return 'منذ ساعتين';
      }

      return 'منذ $hours ساعات';
    }

    if (difference.inDays < 7) {
      final days = difference.inDays;

      if (days == 1) {
        return 'منذ يوم';
      }

      if (days == 2) {
        return 'منذ يومين';
      }

      return 'منذ $days أيام';
    }

    return '${date.day}/${date.month}/${date.year}';
  }
}

class _NotificationIcon
    extends StatelessWidget {
  final String type;

  const _NotificationIcon({
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _resolveIcon();
    final color = _resolveColor();

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: Icon(
        icon,
        color: color,
        size: 23,
      ),
    );
  }

  IconData _resolveIcon() {
    final normalizedType =
        type.toLowerCase();

    if (normalizedType.contains(
      'accepted',
    )) {
      return Icons
          .check_circle_outline_rounded;
    }

    if (normalizedType.contains(
      'rejected',
    )) {
      return Icons.cancel_outlined;
    }

    if (normalizedType.contains(
          'message',
        ) ||
        normalizedType.contains(
          'conversation',
        )) {
      return Icons
          .chat_bubble_outline_rounded;
    }

    if (normalizedType.contains(
      'task',
    )) {
      return Icons.task_alt_rounded;
    }

    if (normalizedType.contains(
      'opportunity',
    )) {
      return Icons.work_outline_rounded;
    }

    if (normalizedType.contains(
      'interview',
    )) {
      return Icons
          .event_available_outlined;
    }

    return Icons
        .notifications_active_outlined;
  }

  Color _resolveColor() {
    final normalizedType =
        type.toLowerCase();

    if (normalizedType.contains(
      'accepted',
    )) {
      return AppColors.successGreen;
    }

    if (normalizedType.contains(
      'rejected',
    )) {
      return AppColors.dangerRed;
    }

    return AppColors.primaryBlue;
  }
}

class _EmptyNotificationsState
    extends StatelessWidget {
  const _EmptyNotificationsState();

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness ==
        Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.all(32),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppColors
                    .primaryBlue
                    .withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .notifications_none_rounded,
                size: 48,
                color:
                    AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'لا توجد إشعارات حاليًا',
              style: TextStyle(
                color: isDarkMode
                    ? Colors.white
                    : AppColors.textDark,
                fontSize: 17,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'ستظهر هنا آخر التحديثات المهمة في حسابك.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    AppColors.textGrey,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsErrorState
    extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _NotificationsErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness ==
        Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.all(28),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppColors
                    .dangerRed
                    .withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 44,
                color:
                    AppColors.dangerRed,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'تعذر تحميل الإشعارات',
              style: TextStyle(
                color: isDarkMode
                    ? Colors.white
                    : AppColors.textDark,
                fontSize: 17,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                color:
                    AppColors.textGrey,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primaryBlue,
                foregroundColor:
                    Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
              ),
              onPressed: () {
                onRetry();
              },
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}