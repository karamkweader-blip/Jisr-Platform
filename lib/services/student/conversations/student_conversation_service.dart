import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/conversations/student_conversation_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class StudentConversationService {
  final AuthService _authService;

  StudentConversationService(this._authService);

  Future<Map<String, String>> _headers() async {
    final token = (await _authService.getToken())?.trim();

    if (token == null || token.isEmpty) {
      throw Exception('انتهت الجلسة، يرجى تسجيل الدخول من جديد');
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.trim().isEmpty) return <String, dynamic>{};

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      // تعالج الرسالة أدناه بدل كشف الاستجابة الخام للمستخدم.
    }

    return {'message': 'استجابة غير مفهومة من الخادم'};
  }

  Uri _withPagination(
    String url, {
    required int page,
    required int perPage,
  }) {
    return Uri.parse(url).replace(
      queryParameters: {
        'page': '$page',
        'per_page': '$perPage',
      },
    );
  }

  Future<ConversationListResponse> getTaskConversations({
    int page = 1,
    int perPage = 15,
  }) {
    return _getConversationList(
      ApiLinks.taskConversations,
      page: page,
      perPage: perPage,
      fallbackMessage: 'تعذر جلب محادثات المهام',
    );
  }

  Future<ConversationListResponse> getAllConversations({
    int page = 1,
    int perPage = 15,
  }) {
    return _getConversationList(
      ApiLinks.allConversations,
      page: page,
      perPage: perPage,
      fallbackMessage: 'تعذر جلب المحادثات',
    );
  }

  Future<ConversationListResponse> getClosedConversations({
    int page = 1,
    int perPage = 15,
  }) {
    return _getConversationList(
      ApiLinks.closedConversations,
      page: page,
      perPage: perPage,
      fallbackMessage: 'تعذر جلب المحادثات المغلقة',
    );
  }

  Future<ConversationListResponse> _getConversationList(
    String url, {
    required int page,
    required int perPage,
    required String fallbackMessage,
  }) async {
    try {
      final response = await http
          .get(
            _withPagination(url, page: page, perPage: perPage),
            headers: await _headers(),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
          );

      final body = _decode(response);

      if (response.statusCode == 200) {
        return ConversationListResponse.fromJson(body);
      }

      throw Exception(body['message']?.toString() ?? fallbackMessage);
    } catch (error) {
      if (error is Exception) rethrow;
      throw Exception(fallbackMessage);
    }
  }

  Future<ConversationMessagesResponse> getMessages(
    int conversationId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiLinks.conversationMessages(conversationId)),
            headers: await _headers(),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('انتهت مهلة جلب الرسائل'),
          );

      final body = _decode(response);

      if (response.statusCode == 200) {
        return ConversationMessagesResponse.fromJson(body);
      }

      throw Exception(
        body['message']?.toString() ?? 'تعذر جلب رسائل المحادثة',
      );
    } catch (error) {
      if (error is Exception) rethrow;
      throw Exception('تعذر جلب رسائل المحادثة');
    }
  }

  Future<ConversationMessageModel> sendMessage({
    required int conversationId,
    required String content,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiLinks.conversationMessages(conversationId)),
            headers: await _headers(),
            body: jsonEncode({'content': content}),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('انتهت مهلة إرسال الرسالة'),
          );

      final body = _decode(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ConversationMessageModel.fromJson(
          body['data'] is Map
              ? Map<String, dynamic>.from(body['data'])
              : <String, dynamic>{},
        ).copyWith(isMine: true);
      }

      throw Exception(body['message']?.toString() ?? 'تعذر إرسال الرسالة');
    } catch (error) {
      if (error is Exception) rethrow;
      throw Exception('تعذر إرسال الرسالة');
    }
  }

  Future<ConversationMessageModel> updateMessage({
    required int messageId,
    required String content,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiLinks.updateConversationMessage(messageId)),
            headers: await _headers(),
            body: jsonEncode({'content': content}),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('انتهت مهلة تعديل الرسالة'),
          );

      final body = _decode(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ConversationMessageModel.fromJson(
          body['data'] is Map
              ? Map<String, dynamic>.from(body['data'])
              : <String, dynamic>{},
        ).copyWith(isMine: true);
      }

      throw Exception(body['message']?.toString() ?? 'تعذر تعديل الرسالة');
    } catch (error) {
      if (error is Exception) rethrow;
      throw Exception('تعذر تعديل الرسالة');
    }
  }

  Future<void> markAsRead(int conversationId) async {
    try {
      final response = await http
          .patch(
            Uri.parse(ApiLinks.markConversationAsRead(conversationId)),
            headers: await _headers(),
          )
          .timeout(
            const Duration(seconds: 12),
            onTimeout: () => throw Exception('انتهت مهلة تحديث حالة القراءة'),
          );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return;
      }

      final body = _decode(response);
      throw Exception(
        body['message']?.toString() ?? 'تعذر تعليم المحادثة كمقروءة',
      );
    } catch (error) {
      if (error is Exception) rethrow;
      throw Exception('تعذر تعليم المحادثة كمقروءة');
    }
  }
}
