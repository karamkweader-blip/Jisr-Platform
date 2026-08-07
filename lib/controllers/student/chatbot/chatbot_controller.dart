import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/models/student/chatbot/chatbot_mode.dart';
import 'package:jisr_platform/models/student/chatbot/chatbot_models.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/student/chatbot/chatbot_api_exception.dart';
import 'package:jisr_platform/services/student/chatbot/chatbot_service.dart';

class ChatbotController extends GetxController {
  final ChatbotService _service = ChatbotService();
  final AuthService _authService = AuthService();

  final RxList<ChatbotConversation> conversations = <ChatbotConversation>[].obs;
  final RxList<ChatbotMessage> messages = <ChatbotMessage>[].obs;
  final Rxn<ChatbotConversation> activeConversation = Rxn<ChatbotConversation>();

  final RxBool isLoadingConversations = false.obs;
  final RxBool isLoadingMoreConversations = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxBool isLoadingOlderMessages = false.obs;
  final RxBool isCreatingConversation = false.obs;
  final RxBool isSending = false.obs;
  final RxBool isDeleting = false.obs;

  String? _conversationCursor;
  bool _hasMoreConversations = false;
  String? _messageCursor;
  bool _hasMoreMessages = false;
  int _localMessageId = -1;

  bool get hasMoreConversations => _hasMoreConversations;
  bool get hasMoreMessages => _hasMoreMessages;

  Future<void> loadConversations({bool refresh = false}) async {
    if (isLoadingConversations.value || isLoadingMoreConversations.value) return;
    if (!refresh && conversations.isNotEmpty && !_hasMoreConversations) return;

    refresh ? isLoadingConversations.value = true : isLoadingMoreConversations.value = true;
    try {
      if (refresh) {
        _conversationCursor = null;
        _hasMoreConversations = false;
      }
      final page = await _service.listConversations(cursor: _conversationCursor);
      if (refresh) {
        conversations.assignAll(page.items);
      } else {
        final ids = conversations.map((item) => item.id).toSet();
        conversations.addAll(page.items.where((item) => !ids.contains(item.id)));
      }
      _conversationCursor = page.nextCursor;
      _hasMoreConversations = page.hasMore;
    } catch (error) {
      await _handleError(error, title: 'تعذر جلب المحادثات');
    } finally {
      isLoadingConversations.value = false;
      isLoadingMoreConversations.value = false;
    }
  }

  Future<ChatbotConversation?> createConversation({
    required ChatbotMode mode,
    required String message,
  }) async {
    final text = message.trim();
    if (text.isEmpty || text.length > 2000 || isCreatingConversation.value) return null;

    isCreatingConversation.value = true;
    final clientMessageId = _service.newClientMessageId();
    try {
      final result = await _service.createConversation(
        mode: mode,
        message: text,
        clientMessageId: clientMessageId,
      );
      final conversation = result.conversation;
      if (conversation == null) {
        throw const ChatbotApiException(statusCode: 0, message: 'لم يُرجع الخادم بيانات المحادثة');
      }
      activeConversation.value = conversation;
      messages.assignAll([
        result.userMessage,
        if (result.assistantMessage != null) result.assistantMessage!,
      ]);
      conversations.removeWhere((item) => item.id == conversation.id);
      conversations.insert(0, conversation);
      _messageCursor = null;
      _hasMoreMessages = false;
      _showProcessingWarning(result.processingStatus);
      return conversation;
    } catch (error) {
      await _handleError(error, title: 'تعذر بدء المحادثة');
      return null;
    } finally {
      isCreatingConversation.value = false;
    }
  }

  Future<void> openConversation(int conversationId) async {
    messages.clear();
    activeConversation.value = null;
    _messageCursor = null;
    _hasMoreMessages = false;
    isLoadingMessages.value = true;
    try {
      final results = await Future.wait([
        _service.getConversation(conversationId),
        _service.listMessages(conversationId: conversationId),
      ]);
      activeConversation.value = results[0] as ChatbotConversation;
      final page = results[1] as CursorPage<ChatbotMessage>;
      messages.assignAll(page.items);
      _messageCursor = page.nextCursor;
      _hasMoreMessages = page.hasMore;
    } catch (error) {
      await _handleError(error, title: 'تعذر فتح المحادثة');
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> loadOlderMessages() async {
    final conversation = activeConversation.value;
    if (conversation == null || !_hasMoreMessages || isLoadingOlderMessages.value) return;

    isLoadingOlderMessages.value = true;
    try {
      final page = await _service.listMessages(
        conversationId: conversation.id,
        cursor: _messageCursor,
      );
      final existingIds = messages.where((item) => item.id > 0).map((item) => item.id).toSet();
      messages.insertAll(0, page.items.where((item) => !existingIds.contains(item.id)));
      _messageCursor = page.nextCursor;
      _hasMoreMessages = page.hasMore;
    } catch (error) {
      await _handleError(error, title: 'تعذر تحميل الرسائل الأقدم');
    } finally {
      isLoadingOlderMessages.value = false;
    }
  }

  Future<void> sendMessage(String message) async {
    final conversation = activeConversation.value;
    final text = message.trim();
    if (conversation == null || text.isEmpty || text.length > 2000 || isSending.value) return;

    final clientMessageId = _service.newClientMessageId();
    final local = ChatbotMessage.optimistic(
      localId: _localMessageId--,
      content: text,
      clientMessageId: clientMessageId,
    );
    messages.add(local);
    await _sendOptimistic(local);
  }

  Future<void> retryMessage(ChatbotMessage failedMessage) async {
    if (!failedMessage.isFailed || failedMessage.clientMessageId == null || isSending.value) return;
    final index = messages.indexWhere((item) => item.id == failedMessage.id);
    if (index == -1) return;
    final pending = failedMessage.copyWith(status: 'pending');
    messages[index] = pending;
    await _sendOptimistic(pending);
  }

  Future<void> _sendOptimistic(ChatbotMessage optimistic) async {
    final conversation = activeConversation.value;
    if (conversation == null || optimistic.clientMessageId == null) return;

    isSending.value = true;
    try {
      final result = await _service.sendMessage(
        conversationId: conversation.id,
        message: optimistic.content,
        clientMessageId: optimistic.clientMessageId!,
      );
      messages.removeWhere((item) => item.id == optimistic.id);
      _upsertOfficialMessage(result.userMessage);
      if (result.assistantMessage != null) _upsertOfficialMessage(result.assistantMessage!);
      _showProcessingWarning(result.processingStatus);
      await _refreshActiveConversationSilently(conversation.id);
    } catch (error) {
      final index = messages.indexWhere((item) => item.id == optimistic.id);
      if (index != -1) messages[index] = optimistic.copyWith(status: 'failed');
      await _handleError(error, title: 'تعذر إرسال الرسالة', showRetryHint: true);
    } finally {
      isSending.value = false;
    }
  }

  void _upsertOfficialMessage(ChatbotMessage message) {
    final index = messages.indexWhere((item) => item.id == message.id);
    if (index == -1) {
      messages.add(message);
    } else {
      messages[index] = message;
    }
  }

  Future<void> _refreshActiveConversationSilently(int id) async {
    try {
      final updated = await _service.getConversation(id);
      activeConversation.value = updated;
      conversations.removeWhere((item) => item.id == id);
      conversations.insert(0, updated);
    } catch (_) {}
  }

  Future<bool> deleteConversation(ChatbotConversation conversation) async {
    if (isDeleting.value) return false;
    isDeleting.value = true;
    try {
      await _service.deleteConversation(conversation.id);
      conversations.removeWhere((item) => item.id == conversation.id);
      if (activeConversation.value?.id == conversation.id) {
        activeConversation.value = null;
        messages.clear();
      }
      return true;
    } catch (error) {
      await _handleError(error, title: 'تعذر حذف المحادثة');
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  void openOpportunity(ChatbotAction action) {
    if (!action.canOpenOpportunity) return;
    Get.toNamed(Routes.studentOpportunityDetails, arguments: action.opportunityId);
  }

  void _showProcessingWarning(String status) {
    if (status == 'completed') return;
    final message = status == 'failed'
        ? 'تم حفظ الرسالة لكن تعذرت معالجة رد المساعد'
        : status == 'unsupported_mode'
            ? 'نوع المحادثة غير مدعوم حاليًا'
            : 'لم تكتمل معالجة الرسالة، يمكنك تحديث المحادثة أو إعادة المحاولة';
    Get.snackbar('تنبيه', message, snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> _handleError(
    Object error, {
    required String title,
    bool showRetryHint = false,
  }) async {
    final exception = error is ChatbotApiException
        ? error
        : ChatbotApiException(statusCode: 0, message: error.toString());

    if (exception.statusCode == 401) {
      await _authService.removeAuthData();
      Get.offAllNamed(Routes.login);
      return;
    }

    Get.snackbar(
      title,
      '${exception.displayMessage}${showRetryHint && exception.canRetry ? '\nاضغط على الرسالة لإعادة المحاولة.' : ''}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.red.shade700,
      margin: const EdgeInsets.all(16),
    );
  }
}
