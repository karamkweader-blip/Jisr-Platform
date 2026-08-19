import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:jisr_platform/firebase_options.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/notifications/notification_api_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  final AuthService _authService = AuthService();

  final StreamController<RemoteMessage>
      _foregroundMessagesController =
      StreamController<RemoteMessage>.broadcast();

  final StreamController<RemoteMessage>
      _openedMessagesController =
      StreamController<RemoteMessage>.broadcast();

  bool _isInitialized = false;

  Stream<RemoteMessage> get foregroundMessages {
    return _foregroundMessagesController.stream;
  }

  Stream<RemoteMessage> get openedMessages {
    return _openedMessagesController.stream;
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;

    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      await _messaging
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen(
        _foregroundMessagesController.add,
      );

      FirebaseMessaging.onMessageOpenedApp.listen(
        _openedMessagesController.add,
      );

      _messaging.onTokenRefresh.listen(
        _storeRefreshedToken,
      );

      final initialMessage =
          await _messaging.getInitialMessage();

      if (initialMessage != null) {
        Future<void>.delayed(
          Duration.zero,
          () {
            _openedMessagesController.add(
              initialMessage,
            );
          },
        );
      }

      // إذا فتح المستخدم التطبيق وهو مسجل مسبقًا،
      // نتأكد أن توكن الجهاز مخزن عند الباك.
      await syncDeviceToken();
    } catch (error) {
      debugPrint(
        'Notification initialization failed: $error',
      );
    }
  }

  Future<void> syncDeviceToken() async {
    final authToken = await _authService.getToken();

    if (authToken == null || authToken.isEmpty) {
      return;
    }

    try {
      final fcmToken = await _messaging.getToken();

      if (fcmToken == null || fcmToken.isEmpty) {
        return;
      }

      final apiService = NotificationApiService(
        _authService,
      );

      await apiService.storeDeviceToken(
        fcmToken,
      );
    } catch (error) {
      debugPrint(
        'FCM token sync failed: $error',
      );
    }
  }

  Future<void> deleteCurrentDeviceToken() async {
    final authToken = await _authService.getToken();

    if (authToken == null || authToken.isEmpty) {
      return;
    }

    try {
      final fcmToken = await _messaging.getToken();

      if (fcmToken == null || fcmToken.isEmpty) {
        return;
      }

      final apiService = NotificationApiService(
        _authService,
      );

      await apiService.deleteDeviceToken(
        fcmToken,
      );
    } catch (error) {
      // لا نمنع تسجيل الخروج إذا فشل حذف FCM Token.
      debugPrint(
        'FCM token deletion failed: $error',
      );
    }
  }

  Future<void> _storeRefreshedToken(
    String fcmToken,
  ) async {
    final authToken = await _authService.getToken();

    if (authToken == null ||
        authToken.isEmpty ||
        fcmToken.isEmpty) {
      return;
    }

    try {
      final apiService = NotificationApiService(
        _authService,
      );

      await apiService.storeDeviceToken(
        fcmToken,
      );
    } catch (error) {
      debugPrint(
        'Refreshed FCM token sync failed: $error',
      );
    }
  }
}