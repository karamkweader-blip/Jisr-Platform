import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/notifications/app_notification_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class NotificationApiService {
  final AuthService _authService;

  const NotificationApiService(this._authService);

  Future<NotificationsResult> getNotifications() async {
    final response = await _send(
      method: 'GET',
      url: ApiLinks.notifications,
    );

    final data = _successData(response);
    final rawNotifications = data['notifications'];
    final meta = data['meta'];

    return NotificationsResult(
      notifications: rawNotifications is List
          ? rawNotifications
              .whereType<Map>()
              .map(
                (item) => AppNotificationModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
      unreadCount: meta is Map
          ? _asInt(meta['unread_count'])
          : 0,
    );
  }

  Future<int> getUnreadCount() async {
    final response = await _send(
      method: 'GET',
      url: ApiLinks.unreadNotificationsCount,
    );

    final data = _successData(response);

    return _asInt(data['unread_count']);
  }

  Future<void> markAsRead(
    int notificationId,
  ) async {
    final response = await _send(
      method: 'PATCH',
      url: ApiLinks.markNotificationAsRead(
        notificationId,
      ),
    );

    _ensureSuccess(response);
  }

  Future<void> markAllAsRead() async {
    final response = await _send(
      method: 'PATCH',
      url: ApiLinks.markAllNotificationsAsRead,
    );

    _ensureSuccess(response);
  }

  Future<void> storeDeviceToken(
    String fcmToken,
  ) async {
    final response = await _send(
      method: 'POST',
      url: ApiLinks.notificationDeviceTokens,
      body: {
        'token': fcmToken,
      },
    );

    _ensureSuccess(response);
  }

  Future<void> deleteDeviceToken(
    String fcmToken,
  ) async {
    final response = await _send(
      method: 'DELETE',
      url: ApiLinks.notificationDeviceTokens,
      body: {
        'token': fcmToken,
      },
    );

    _ensureSuccess(response);
  }

  Future<http.Response> _send({
    required String method,
    required String url,
    Map<String, dynamic>? body,
  }) async {
    final token = await _authService.getToken();

    if (token == null || token.isEmpty) {
      throw const NotificationApiException(
        'انتهت جلسة تسجيل الدخول',
      );
    }

    final uri = Uri.parse(url);

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final encodedBody = body == null
        ? null
        : jsonEncode(body);

    try {
      final Future<http.Response> request;

      switch (method) {
        case 'GET':
          request = http.get(
            uri,
            headers: headers,
          );
          break;

        case 'POST':
          request = http.post(
            uri,
            headers: headers,
            body: encodedBody,
          );
          break;

        case 'PATCH':
          request = http.patch(
            uri,
            headers: headers,
            body: encodedBody,
          );
          break;

        case 'DELETE':
          request = http.delete(
            uri,
            headers: headers,
            body: encodedBody,
          );
          break;

        default:
          throw UnsupportedError(
            'Unsupported HTTP method: $method',
          );
      }

      return await request.timeout(
        const Duration(seconds: 15),
      );
    } on NotificationApiException {
      rethrow;
    } catch (_) {
      throw const NotificationApiException(
        'تعذر الاتصال بالخادم، تحقق من اتصال الإنترنت',
      );
    }
  }

  Map<String, dynamic> _successData(
    http.Response response,
  ) {
    final decoded = _ensureSuccess(response);
    final data = decoded['data'];

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return {};
  }

  Map<String, dynamic> _ensureSuccess(
    http.Response response,
  ) {
    Map<String, dynamic> decoded = {};

    if (response.body.isNotEmpty) {
      try {
        final raw = jsonDecode(response.body);

        if (raw is Map) {
          decoded = Map<String, dynamic>.from(raw);
        }
      } catch (_) {
        throw const NotificationApiException(
          'استجابة الخادم غير صالحة',
        );
      }
    }

    final isSuccessful =
        response.statusCode >= 200 &&
        response.statusCode < 300;

    if (!isSuccessful) {
      throw NotificationApiException(
        decoded['message']?.toString() ??
            'تعذر تنفيذ طلب الإشعارات',
      );
    }

    return decoded;
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}

class NotificationsResult {
  final List<AppNotificationModel> notifications;
  final int unreadCount;

  const NotificationsResult({
    required this.notifications,
    required this.unreadCount,
  });
}

class NotificationApiException implements Exception {
  final String message;

  const NotificationApiException(this.message);

  @override
  String toString() => message;
}