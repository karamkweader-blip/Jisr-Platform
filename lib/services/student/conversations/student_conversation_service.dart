import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_links.dart';
import 'package:jisr_platform/models/student/conversations/student_conversation_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class StudentConversationService {
  final AuthService _authService = AuthService();

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

  Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) return {};

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'message': 'استجابة غير مفهومة من الخادم'};
    }
  }

  Uri _withPagination({
    required String url,
    required int page,
    required int perPage,
  }) {
    return Uri.parse(url).replace(
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
    );
  }

  Future<ConversationListResponse> getTaskConversations({
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await http
        .get(
          _withPagination(
            url: ApiLinks.taskConversations,
            page: page,
            perPage: perPage,
          ),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال بجلب محادثات التاسكات');
          },
        );

    print('TASK CONVERSATIONS STATUS: ${response.statusCode}');
    print('TASK CONVERSATIONS BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      return ConversationListResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب محادثات التاسكات');
  }

  Future<ConversationListResponse> getAllConversations({
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await http
        .get(
          _withPagination(
            url: ApiLinks.allConversations,
            page: page,
            perPage: perPage,
          ),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال بجلب كل المحادثات');
          },
        );

    print('ALL CONVERSATIONS STATUS: ${response.statusCode}');
    print('ALL CONVERSATIONS BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      return ConversationListResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب كل المحادثات');
  }

  Future<ConversationListResponse> getClosedConversations({
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await http
        .get(
          _withPagination(
            url: ApiLinks.closedConversations,
            page: page,
            perPage: perPage,
          ),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال بجلب المحادثات المغلقة');
          },
        );

    print('CLOSED CONVERSATIONS STATUS: ${response.statusCode}');
    print('CLOSED CONVERSATIONS BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      return ConversationListResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب المحادثات المغلقة');
  }

  Future<ConversationMessagesResponse> getMessages(int conversationId) async {
    final response = await http
        .get(
          Uri.parse(ApiLinks.conversationMessages(conversationId)),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال بجلب الرسائل');
          },
        );

    print('MESSAGES STATUS: ${response.statusCode}');
    print('MESSAGES BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      return ConversationMessagesResponse.fromJson(data);
    }

    throw Exception(data['message'] ?? 'فشل جلب الرسائل');
  }

  Future<ConversationMessageModel> sendMessage({
    required int conversationId,
    required String content,
  }) async {
    final response = await http
        .post(
          Uri.parse(ApiLinks.conversationMessages(conversationId)),
          headers: await _headers(),
          body: jsonEncode({'content': content}),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال أثناء إرسال الرسالة');
          },
        );

    print('SEND MESSAGE STATUS: ${response.statusCode}');
    print('SEND MESSAGE BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ConversationMessageModel.fromJson(
        data['data'] ?? {},
      ).copyWith(isMine: true);
    }

    throw Exception(data['message'] ?? 'فشل إرسال الرسالة');
  }

  Future<ConversationMessageModel> updateMessage({
    required int messageId,
    required String content,
  }) async {
    final response = await http
        .post(
          Uri.parse(ApiLinks.updateConversationMessage(messageId)),
          headers: await _headers(),
          body: jsonEncode({'content': content}),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال أثناء تعديل الرسالة');
          },
        );

    print('UPDATE MESSAGE STATUS: ${response.statusCode}');
    print('UPDATE MESSAGE BODY: ${response.body}');

    final data = _decodeBody(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ConversationMessageModel.fromJson(
        data['data'] ?? {},
      ).copyWith(isMine: true);
    }

    throw Exception(data['message'] ?? 'فشل تعديل الرسالة');
  }

  Future<void> markAsRead(int conversationId) async {
    final response = await http
        .patch(
          Uri.parse(ApiLinks.markConversationAsRead(conversationId)),
          headers: await _headers(),
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال عند تعليم المحادثة كمقروءة');
          },
        );

    print('MARK READ STATUS: ${response.statusCode}');
    print('MARK READ BODY: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    final data = _decodeBody(response);
    throw Exception(data['message'] ?? 'فشل تعليم المحادثة كمقروءة');
  }
}
