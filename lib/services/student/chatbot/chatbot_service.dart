import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/chatbot/chatbot_mode.dart';
import 'package:jisr_platform/models/student/chatbot/chatbot_models.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'chatbot_api_exception.dart';

class ChatbotService {
  ChatbotService({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;
  final AuthService _authService = AuthService();
  final Random _random = Random.secure();

  String newClientMessageId() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  Future<ChatbotExchangeResult> createConversation({
    required ChatbotMode mode,
    required String message,
    required String clientMessageId,
  }) async {
    final json = await _request(
      method: 'POST',
      uri: Uri.parse(ApiLinks.chatbotConversations),
      body: {'mode': mode.apiValue, 'message': message, 'client_message_id': clientMessageId},
    );
    return ChatbotExchangeResult.fromJson(Map<String, dynamic>.from(json['data'] as Map));
  }

  Future<ChatbotExchangeResult> sendMessage({
    required int conversationId,
    required String message,
    required String clientMessageId,
  }) async {
    final json = await _request(
      method: 'POST',
      uri: Uri.parse(ApiLinks.chatbotMessages(conversationId)),
      body: {'message': message, 'client_message_id': clientMessageId},
    );
    return ChatbotExchangeResult.fromJson(Map<String, dynamic>.from(json['data'] as Map));
  }

  Future<CursorPage<ChatbotConversation>> listConversations({int limit = 20, String? cursor}) async {
    final uri = Uri.parse(ApiLinks.chatbotConversations).replace(queryParameters: {
      'limit': limit.clamp(1, 50).toString(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
    });
    final json = await _request(method: 'GET', uri: uri);
    return _parsePage(json, ChatbotConversation.fromJson);
  }

  Future<ChatbotConversation> getConversation(int conversationId) async {
    final json = await _request(method: 'GET', uri: Uri.parse(ApiLinks.chatbotConversation(conversationId)));
    return ChatbotConversation.fromJson(Map<String, dynamic>.from(json['data'] as Map));
  }

  Future<CursorPage<ChatbotMessage>> listMessages({required int conversationId, int limit = 30, String? cursor}) async {
    final uri = Uri.parse(ApiLinks.chatbotMessages(conversationId)).replace(queryParameters: {
      'limit': limit.clamp(1, 100).toString(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
    });
    final json = await _request(method: 'GET', uri: uri);
    return _parsePage(json, ChatbotMessage.fromJson);
  }

  Future<void> deleteConversation(int conversationId) async {
    await _request(method: 'DELETE', uri: Uri.parse(ApiLinks.chatbotConversation(conversationId)));
  }

  CursorPage<T> _parsePage<T>(Map<String, dynamic> json, T Function(Map<String, dynamic>) parser) {
    final data = Map<String, dynamic>.from(json['data'] as Map);
    final rawItems = data['items'] as List? ?? const [];
    return CursorPage<T>(
      items: rawItems.whereType<Map>().map((item) => parser(Map<String, dynamic>.from(item))).toList(growable: false),
      nextCursor: data['next_cursor']?.toString(),
      hasMore: data['has_more'] == true,
    );
  }

  Future<Map<String, dynamic>> _request({
    required String method,
    required Uri uri,
    Map<String, dynamic>? body,
  }) async {
    try {
      final token = (await _authService
              .getToken()
              .timeout(const Duration(seconds: 5)))
          ?.trim();
      if (token == null || token.isEmpty) {
        throw const ChatbotApiException(
          statusCode: 401,
          message: 'Missing authentication token.',
        );
      }

      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      late final http.Response response;
      if (method == 'GET') {
        response = await _http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
      } else if (method == 'POST') {
        response = await _http.post(uri, headers: headers, body: jsonEncode(body ?? const {})).timeout(const Duration(seconds: 45));
      } else if (method == 'DELETE') {
        response = await _http.delete(uri, headers: headers).timeout(const Duration(seconds: 20));
      } else {
        throw ArgumentError.value(method, 'method', 'Unsupported method');
      }

      final decoded = _decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300 || decoded['status'] == false) {
        throw ChatbotApiException(
          statusCode: response.statusCode,
          message: decoded['message']?.toString() ?? 'فشل تنفيذ الطلب',
          fieldErrors: _parseFieldErrors(decoded['errors']),
        );
      }
      return decoded;
    } on TimeoutException {
      throw const ChatbotApiException(statusCode: 0, message: 'انتهت مهلة الاتصال بالخادم', isTimeout: true);
    } on ChatbotApiException {
      rethrow;
    } catch (_) {
      throw const ChatbotApiException(statusCode: 0, message: 'تعذر الاتصال بالخادم');
    }
  }

  Map<String, dynamic> _decode(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(body);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{'message': 'استجابة غير مفهومة من الخادم'};
    }
  }

  Map<String, List<String>> _parseFieldErrors(dynamic raw) {
    if (raw is! Map) return const {};
    return raw.map((key, value) => MapEntry(
          key.toString(),
          value is List ? value.map((item) => item.toString()).toList(growable: false) : <String>[value.toString()],
        ));
  }
}
