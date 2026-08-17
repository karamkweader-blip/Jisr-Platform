import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/company/conversations/company_conversation_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class CompanyConversationService {
  final AuthService _authService;

  CompanyConversationService(this._authService);

  Future<Map<String, String>> _headers() async {
    final token = (await _authService.getToken())?.trim();

    if (token == null || token.isEmpty) {
      throw Exception(
        'انتهت الجلسة، يرجى تسجيل الدخول من جديد',
      );
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.trim().isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {};
    } catch (_) {
      return {
        'message': 'استجابة غير مفهومة من الخادم',
      };
    }
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

  void _printOpportunityConversationsResponse({
    required Uri requestUrl,
    required http.Response response,
  }) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('');
    debugPrint(
      '========== OPPORTUNITY CONVERSATIONS RESPONSE ==========',
    );
    debugPrint('REQUEST URL: $requestUrl');
    debugPrint('STATUS CODE: ${response.statusCode}');
    debugPrint('RESPONSE HEADERS: ${response.headers}');
    debugPrint('RESPONSE BODY:');

    if (response.body.trim().isEmpty) {
      debugPrint('[EMPTY RESPONSE BODY]');
    } else {
      debugPrint(
        response.body,
        wrapWidth: 1024,
      );
    }

    debugPrint(
      '========================================================',
    );
    debugPrint('');
  }

  Future<CompanyConversationListResponse> getTaskConversations({
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

  Future<CompanyConversationListResponse>
      getOpportunityConversations({
    int page = 1,
    int perPage = 15,
  }) {
    return _getConversationList(
      ApiLinks.opportunityConversations,
      page: page,
      perPage: perPage,
      fallbackMessage: 'تعذر جلب محادثات الفرص',
      printOpportunityResponse: true,
    );
  }

  Future<CompanyConversationListResponse> getAllConversations({
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

  Future<CompanyConversationListResponse>
      getClosedConversations({
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

  Future<CompanyConversationListResponse> _getConversationList(
    String url, {
    required int page,
    required int perPage,
    required String fallbackMessage,
    bool printOpportunityResponse = false,
  }) async {
    try {
      final requestUrl = _withPagination(
        url,
        page: page,
        perPage: perPage,
      );

      final response = await http
          .get(
            requestUrl,
            headers: await _headers(),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      if (printOpportunityResponse) {
        _printOpportunityConversationsResponse(
          requestUrl: requestUrl,
          response: response,
        );
      }

      final body = _decode(response);

      if (response.statusCode == 200) {
        return CompanyConversationListResponse.fromJson(
          body,
        );
      }

      throw Exception(
        body['message']?.toString() ??
            fallbackMessage,
      );
    } on TimeoutException {
      throw Exception(
        'انتهت مهلة الاتصال بالخادم',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(fallbackMessage);
    }
  }

  Future<CompanyConversationMessagesResponse> getMessages(
    int conversationId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              ApiLinks.conversationMessages(
                conversationId,
              ),
            ),
            headers: await _headers(),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final body = _decode(response);

      if (response.statusCode == 200) {
        return CompanyConversationMessagesResponse.fromJson(
          body,
        );
      }

      throw Exception(
        body['message']?.toString() ??
            'تعذر جلب رسائل المحادثة',
      );
    } on TimeoutException {
      throw Exception(
        'انتهت مهلة الاتصال بالخادم',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'تعذر جلب رسائل المحادثة',
      );
    }
  }

  Future<CompanyConversationMessage> sendMessage({
    required int conversationId,
    required String content,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              ApiLinks.conversationMessages(
                conversationId,
              ),
            ),
            headers: await _headers(),
            body: jsonEncode({
              'content': content,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final body = _decode(response);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return CompanyConversationMessage.fromJson(
          body['data'] is Map
              ? Map<String, dynamic>.from(
                  body['data'],
                )
              : {},
        ).copyWith(
          isMine: true,
        );
      }

      throw Exception(
        body['message']?.toString() ??
            'تعذر إرسال الرسالة',
      );
    } on TimeoutException {
      throw Exception(
        'انتهت مهلة الاتصال بالخادم',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'تعذر إرسال الرسالة',
      );
    }
  }

  Future<CompanyConversationMessage> updateMessage({
    required int messageId,
    required String content,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              ApiLinks.updateConversationMessage(
                messageId,
              ),
            ),
            headers: await _headers(),
            body: jsonEncode({
              'content': content,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      final body = _decode(response);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return CompanyConversationMessage.fromJson(
          body['data'] is Map
              ? Map<String, dynamic>.from(
                  body['data'],
                )
              : {},
        ).copyWith(
          isMine: true,
        );
      }

      throw Exception(
        body['message']?.toString() ??
            'تعذر تعديل الرسالة',
      );
    } on TimeoutException {
      throw Exception(
        'انتهت مهلة الاتصال بالخادم',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'تعذر تعديل الرسالة',
      );
    }
  }

  Future<void> markAsRead(
    int conversationId,
  ) async {
    try {
      final response = await http
          .patch(
            Uri.parse(
              ApiLinks.markConversationAsRead(
                conversationId,
              ),
            ),
            headers: await _headers(),
          )
          .timeout(
            const Duration(seconds: 12),
          );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return;
      }

      final body = _decode(response);

      throw Exception(
        body['message']?.toString() ??
            'تعذر تعليم المحادثة كمقروءة',
      );
    } on TimeoutException {
      throw Exception(
        'انتهت مهلة الاتصال بالخادم',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'تعذر تعليم المحادثة كمقروءة',
      );
    }
  }
}