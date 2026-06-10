import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/conversations/student_conversation_model.dart';
import 'package:jisr_platform/services/student/conversations/student_conversation_service.dart';

enum ConversationTabType { task, all, closed }

class StudentConversationController extends GetxController {
  final StudentConversationService _service = StudentConversationService();

  final TextEditingController messageController = TextEditingController();
  final TextEditingController editMessageController = TextEditingController();

  final RxBool isLoadingConversations = false.obs;
  final RxBool isLoadingMoreConversations = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxBool isSending = false.obs;
  final RxBool isUpdating = false.obs;

  final Rx<ConversationTabType> selectedTab = ConversationTabType.task.obs;

  final RxList<StudentConversationModel> conversations =
      <StudentConversationModel>[].obs;

  final RxList<ConversationMessageModel> messages =
      <ConversationMessageModel>[].obs;

  final Rxn<StudentConversationModel> selectedConversation =
      Rxn<StudentConversationModel>();

  int currentPage = 1;
  int lastPage = 1;
  int perPage = 10;
  int totalConversations = 0;

  bool get canLoadMoreConversations => currentPage < lastPage;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchCurrentConversations({bool refresh = true}) async {
    switch (selectedTab.value) {
      case ConversationTabType.task:
        await fetchTaskConversations(refresh: refresh);
        break;
      case ConversationTabType.all:
        await fetchAllConversations(refresh: refresh);
        break;
      case ConversationTabType.closed:
        await fetchClosedConversations(refresh: refresh);
        break;
    }
  }

  Future<void> changeConversationTab(ConversationTabType tab) async {
    if (selectedTab.value == tab && conversations.isNotEmpty) return;

    selectedTab.value = tab;
    conversations.clear();

    currentPage = 1;
    lastPage = 1;
    totalConversations = 0;

    await fetchCurrentConversations(refresh: true);
  }

  Future<void> fetchTaskConversations({bool refresh = true}) async {
    try {
      if (refresh) {
        isLoadingConversations.value = true;
        currentPage = 1;
      } else {
        isLoadingMoreConversations.value = true;
      }

      final response = await _service.getTaskConversations(
        page: currentPage,
        perPage: perPage,
      );

      _applyConversationResponse(response, refresh: refresh);
    } catch (e) {
      _showError(e);
    } finally {
      isLoadingConversations.value = false;
      isLoadingMoreConversations.value = false;
    }
  }

  Future<void> fetchAllConversations({bool refresh = true}) async {
    try {
      if (refresh) {
        isLoadingConversations.value = true;
        currentPage = 1;
      } else {
        isLoadingMoreConversations.value = true;
      }

      final response = await _service.getAllConversations(
        page: currentPage,
        perPage: perPage,
      );

      _applyConversationResponse(response, refresh: refresh);
    } catch (e) {
      _showError(e);
    } finally {
      isLoadingConversations.value = false;
      isLoadingMoreConversations.value = false;
    }
  }

  Future<void> fetchClosedConversations({bool refresh = true}) async {
    try {
      if (refresh) {
        isLoadingConversations.value = true;
        currentPage = 1;
      } else {
        isLoadingMoreConversations.value = true;
      }

      final response = await _service.getClosedConversations(
        page: currentPage,
        perPage: perPage,
      );

      _applyConversationResponse(response, refresh: refresh);
    } catch (e) {
      _showError(e);
    } finally {
      isLoadingConversations.value = false;
      isLoadingMoreConversations.value = false;
    }
  }

  Future<void> loadMoreConversations() async {
    if (!canLoadMoreConversations) return;
    if (isLoadingMoreConversations.value || isLoadingConversations.value) {
      return;
    }

    currentPage++;

    await fetchCurrentConversations(refresh: false);
  }

  void _applyConversationResponse(
    ConversationListResponse response, {
    required bool refresh,
  }) {
    currentPage = response.pagination.currentPage;
    lastPage = response.pagination.lastPage;
    perPage = response.pagination.perPage;
    totalConversations = response.pagination.total;

    if (refresh) {
      conversations.assignAll(response.items);
    } else {
      conversations.addAll(response.items);
    }
  }

  Future<void> openConversation(StudentConversationModel conversation) async {
    selectedConversation.value = conversation;

    await fetchMessages(conversation.id);

    await markConversationAsRead(conversation.id);
  }

  Future<void> fetchMessages(int conversationId) async {
    try {
      isLoadingMessages.value = true;

      final response = await _service.getMessages(conversationId);

      final preparedMessages = response.items.map((message) {
        return message.copyWith(isMine: message.isMine);
      }).toList();

      messages.assignAll(preparedMessages);
    } catch (e) {
      _showError(e);
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> sendMessage() async {
    final conversation = selectedConversation.value;
    final content = messageController.text.trim();

    if (conversation == null) return;

    if (content.isEmpty) {
      JisrSnackbar.show(
        title: 'رسالة فارغة',
        message: 'اكتب نص الرسالة أولاً',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    try {
      isSending.value = true;

      final sentMessage = await _service.sendMessage(
        conversationId: conversation.id,
        content: content,
      );

      final myMessage = sentMessage.copyWith(isMine: true);

      messages.add(myMessage);
      messageController.clear();

      _updateLatestMessage(conversation.id, myMessage);
    } catch (e) {
      JisrSnackbar.show(
        title: 'فشل الإرسال',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    } finally {
      isSending.value = false;
    }
  }

  bool isSystemMessage(ConversationMessageModel message) {
    return message.type == 'system';
  }

  bool canEditMessage(ConversationMessageModel message) {
    return message.isMine &&
        message.readAt == null &&
        !isSystemMessage(message);
  }

  bool isReadByOtherSide(ConversationMessageModel message) {
    return message.isMine && message.readAt != null;
  }

  Future<void> updateMessage(ConversationMessageModel oldMessage) async {
    if (!canEditMessage(oldMessage)) {
      JisrSnackbar.show(
        title: 'لا يمكن التعديل',
        message: 'لا يمكن تعديل الرسالة بعد قراءتها من الطرف الآخر',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    final content = editMessageController.text.trim();

    if (content.isEmpty) {
      JisrSnackbar.show(
        title: 'رسالة فارغة',
        message: 'اكتب النص الجديد أولاً',
        type: JisrSnackbarType.warning,
      );
      return;
    }

    try {
      isUpdating.value = true;

      final updated = await _service.updateMessage(
        messageId: oldMessage.id,
        content: content,
      );

      final index = messages.indexWhere((item) => item.id == oldMessage.id);

      if (index != -1) {
        messages[index] = messages[index].copyWith(
          content: updated.content,
          isMine: true,
          updatedAt: updated.updatedAt,
        );

        messages.refresh();
      }

      final conversation = selectedConversation.value;

      if (conversation != null && index != -1) {
        _updateLatestMessage(conversation.id, messages[index]);
      }

      Get.back();

      JisrSnackbar.show(
        title: 'تم التعديل',
        message: 'تم تعديل الرسالة بنجاح',
        type: JisrSnackbarType.success,
      );
    } catch (e) {
      JisrSnackbar.show(
        title: 'فشل التعديل',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: JisrSnackbarType.error,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> markConversationAsRead(int conversationId) async {
    try {
      await _service.markAsRead(conversationId);

      final index = conversations.indexWhere(
        (item) => item.id == conversationId,
      );

      if (index != -1) {
        conversations[index] = conversations[index].copyWith(
          unreadMessagesCount: 0,
        );
        conversations.refresh();
      }
    } catch (e) {
      debugPrint('MARK READ ERROR: $e');
    }
  }

  void _updateLatestMessage(
    int conversationId,
    ConversationMessageModel message,
  ) {
    final index = conversations.indexWhere((item) => item.id == conversationId);

    if (index != -1) {
      conversations[index] = conversations[index].copyWith(
        latestMessage: ConversationLatestMessage(
          id: message.id,
          content: message.content,
          senderId: message.senderId,
          createdAt: message.createdAt,
        ),
        unreadMessagesCount: 0,
      );

      conversations.refresh();
    }
  }

  ConversationUserModel? otherParticipant(
    StudentConversationModel conversation,
  ) {
    if (conversation.participants.length >= 2) {
      return conversation.participants[1];
    }

    if (conversation.participants.isNotEmpty) {
      return conversation.participants.first;
    }

    return null;
  }

  String otherParticipantName(StudentConversationModel conversation) {
    return otherParticipant(conversation)?.name ?? 'شركة';
  }

  String conversationCompanyName(StudentConversationModel conversation) {
    return otherParticipantName(conversation);
  }

  String conversationTaskTitle(StudentConversationModel conversation) {
    final title = conversation.taskAssignment?.title;

    if (title != null && title.trim().isNotEmpty) {
      return title;
    }

    final taskId = conversation.taskAssignment?.id ?? conversation.contextId;

    if (taskId != null && taskId != 0) {
      return 'تاسك رقم $taskId';
    }

    return 'محادثة تاسك';
  }

  String latestMessageText(StudentConversationModel conversation) {
    final latest = conversation.latestMessage;

    if (latest == null || latest.content.trim().isEmpty) {
      return 'لا توجد رسائل بعد';
    }

    return latest.content;
  }

  String selectedTabTitle() {
    switch (selectedTab.value) {
      case ConversationTabType.task:
        return 'محادثات التاسكات';
      case ConversationTabType.all:
        return 'كل المحادثات';
      case ConversationTabType.closed:
        return 'المغلقة';
    }
  }

  String emptyMessageTitle() {
    switch (selectedTab.value) {
      case ConversationTabType.task:
        return 'لا توجد محادثات تاسكات حالياً';
      case ConversationTabType.all:
        return 'لا توجد محادثات حالياً';
      case ConversationTabType.closed:
        return 'لا توجد محادثات مغلقة';
    }
  }

  String emptyMessageSubtitle() {
    switch (selectedTab.value) {
      case ConversationTabType.task:
        return 'عند قبولك في تاسك من شركة، ستظهر المحادثة هنا.';
      case ConversationTabType.all:
        return 'كل محادثاتك ستظهر هنا عند توفرها.';
      case ConversationTabType.closed:
        return 'المحادثات المغلقة ستظهر هنا عند وجودها.';
    }
  }

  bool get hasMessages => messages.isNotEmpty;

  String dateOnly(String? value) {
    if (value == null || value.isEmpty) return '';

    return value.split('T').first;
  }

  String timeOnly(String? value) {
    if (value == null || value.isEmpty) return '';

    final parts = value.split('T');

    if (parts.length < 2) return value;

    final timePart = parts[1];

    if (timePart.length < 5) return timePart;

    return timePart.substring(0, 5);
  }

  void prepareEditMessage(ConversationMessageModel message) {
    editMessageController.text = message.content;
  }

  void _showError(Object e) {
    JisrSnackbar.show(
      title: 'خطأ',
      message: e.toString().replaceFirst('Exception: ', ''),
      type: JisrSnackbarType.error,
    );
  }

  @override
  void onClose() {
    messageController.dispose();
    editMessageController.dispose();
    super.onClose();
  }
}
