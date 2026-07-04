import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:jisr_platform/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint(
    '📩 Background FCM message: ${message.messageId}',
  );
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initializeForTest() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      '🔔 Notification permission: ${settings.authorizationStatus}',
    );

    try {
      final token = await _messaging.getToken();

      debugPrint(
        '🔑 FCM_TOKEN=$token',
        wrapWidth: 2048,
      );

      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint(
          '🔄 FCM_TOKEN_REFRESHED=$newToken',
          wrapWidth: 2048,
        );
      });
    } catch (error) {
      debugPrint('❌ Failed to get FCM token: $error');
    }
  }
}