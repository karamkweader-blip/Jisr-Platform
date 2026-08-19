import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/notifications/app_notification_model.dart';
import 'package:jisr_platform/services/notifications/notification_api_service.dart';
import 'package:jisr_platform/services/notifications/notification_service.dart';

class NotificationsController extends GetxController {
  final NotificationApiService _apiService;
  final NotificationService _notificationService;

  NotificationsController(
    this._apiService, {
    NotificationService? notificationService,
  }) : _notificationService =
            notificationService ??
            NotificationService.instance;

  final notifications =
      <AppNotificationModel>[].obs;

  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final errorMessage = RxnString();

  StreamSubscription<RemoteMessage>?
      _foregroundSubscription;

  StreamSubscription<RemoteMessage>?
      _openedSubscription;

  bool get hasUnreadNotifications {
    return unreadCount.value > 0;
  }

  @override
  void onInit() {
    super.onInit();

    _foregroundSubscription =
        _notificationService.foregroundMessages.listen(
      _handleForegroundMessage,
    );

    _openedSubscription =
        _notificationService.openedMessages.listen(
      _handleOpenedMessage,
    );

    refreshUnreadCount(
      silent: true,
    );
  }

  Future<void> loadNotifications({
    bool refresh = false,
    bool updateUnreadCount = true,
  }) async {
    try {
      errorMessage.value = null;

      if (refresh) {
        isRefreshing.value = true;
      } else {
        isLoading.value = true;
      }

      final result =
          await _apiService.getNotifications();

      notifications.assignAll(
        result.notifications,
      );

      if (updateUnreadCount) {
        unreadCount.value =
            result.unreadCount;
      }
    } catch (error) {
      errorMessage.value =
          error.toString();
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void>
      onNotificationCenterOpened() async {
    final hadUnreadNotifications =
        unreadCount.value > 0;

    // تصفير العداد بصريًا فور فتح الصفحة.
    unreadCount.value = 0;

    await loadNotifications(
      updateUnreadCount: false,
    );

    // إذا فشل تحميل القائمة، نعيد العدد الحقيقي.
    if (errorMessage.value != null) {
      await refreshUnreadCount(
        silent: true,
      );
      return;
    }

    final listContainsUnread =
        notifications.any(
      (item) => !item.isRead,
    );

    if (notifications.isNotEmpty &&
        (hadUnreadNotifications ||
            listContainsUnread)) {
      await markAllAsRead();
    }
  }

  Future<void> refreshUnreadCount({
    bool silent = false,
  }) async {
    try {
      final count =
          await _apiService.getUnreadCount();

      unreadCount.value = count;
    } catch (error) {
      if (!silent) {
        JisrSnackbar.show(
          title: 'تعذر تحديث الإشعارات',
          message: error.toString(),
          type: JisrSnackbarType.error,
        );
      }
    }
  }

  Future<void> markAllAsRead() async {
    final previousCount =
        unreadCount.value;

    final previousNotifications =
        notifications.toList(
      growable: false,
    );

    // تحديث فوري للواجهة قبل انتظار الباك.
    unreadCount.value = 0;

    final now = DateTime.now().toUtc();

    notifications.assignAll(
      notifications.map(
        (item) {
          if (item.isRead) {
            return item;
          }

          return item.copyWith(
            isRead: true,
            readAt: now,
          );
        },
      ),
    );

    try {
      await _apiService.markAllAsRead();
    } catch (error) {
      // إذا فشل الطلب نعيد الحالة السابقة.
      unreadCount.value =
          previousCount;

      notifications.assignAll(
        previousNotifications,
      );

      await refreshUnreadCount(
        silent: true,
      );

      JisrSnackbar.show(
        title: 'تعذر تحديث حالة الإشعارات',
        message: error.toString(),
        type: JisrSnackbarType.error,
      );
    }
  }

  Future<void> markAsRead(
    AppNotificationModel notification,
  ) async {
    if (notification.isRead) {
      return;
    }

    final index =
        notifications.indexWhere(
      (item) => item.id == notification.id,
    );

    if (index == -1) {
      return;
    }

    notifications[index] =
        notification.copyWith(
      isRead: true,
      readAt: DateTime.now().toUtc(),
    );

    if (unreadCount.value > 0) {
      unreadCount.value--;
    }

    try {
      await _apiService.markAsRead(
        notification.id,
      );
    } catch (_) {
      // نعيد مزامنة العدد إذا فشل الطلب.
      await refreshUnreadCount(
        silent: true,
      );
    }
  }

  Future<void> retry() async {
    await onNotificationCenterOpened();
  }

  void _handleForegroundMessage(
    RemoteMessage message,
  ) {
    // تحديث العداد فور وصول FCM.
    unreadCount.value++;

    final notification =
        _fromRemoteMessage(message);

    if (notification != null) {
      // منع تكرار نفس الإشعار.
      notifications.removeWhere(
        (item) =>
            item.id == notification.id,
      );

      notifications.insert(
        0,
        notification,
      );
    }

    JisrSnackbar.show(
      title:
          message.notification?.title ??
          'إشعار جديد',
      message:
          message.notification?.body ??
          'لديك تحديث جديد في منصة جسور',
      type: JisrSnackbarType.info,
    );
  }

  void _handleOpenedMessage(
    RemoteMessage message,
  ) {
    /*
     * سيتم لاحقًا استخدام:
     *
     * message.data['screen']
     *
     * لتوجيه المستخدم للصفحة المناسبة،
     * مثل active_task أو conversation.
     *
     * حاليًا نعيد مزامنة العداد فقط.
     */
    refreshUnreadCount(
      silent: true,
    );
  }

  AppNotificationModel? _fromRemoteMessage(
    RemoteMessage message,
  ) {
    final rawId =
        message.data['notification_id'] ??
        message.data['id'];

    final id = int.tryParse(
      rawId?.toString() ?? '',
    );

    /*
     * إذا لم يرسل الباك notification_id
     * لا نضيف الإشعار مؤقتًا للقائمة حتى
     * لا ننشئ ID وهميًا، لكن العداد يبقى
     * محدثًا فورًا.
     */
    if (id == null) {
      return null;
    }

    return AppNotificationModel(
      id: id,
      type:
          message.data['type']?.toString() ??
          '',
      title:
          message.notification?.title ??
          message.data['title']?.toString() ??
          'إشعار جديد',
      body:
          message.notification?.body ??
          message.data['body']?.toString() ??
          '',
      data: Map<String, dynamic>.from(
        message.data,
      ),
      actor: null,
      isRead: false,
      readAt: null,
      createdAt:
          message.sentTime?.toUtc() ??
          DateTime.now().toUtc(),
    );
  }

  @override
  void onClose() {
    _foregroundSubscription?.cancel();
    _openedSubscription?.cancel();

    super.onClose();
  }
}