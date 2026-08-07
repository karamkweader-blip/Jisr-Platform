import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/company/conversations/company_conversation_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/company/conversations/company_conversation_service.dart';

enum CompanyConversationTab {
  tasks,
  all,
  closed,
}

class CompanyConversationController extends GetxController {
  final CompanyConversationService _service;
  final AuthService _authService;

  CompanyConversationController(
    this._service,
    this._authService,
  );

  final messageController = TextEditingController();
  final editMessageController = TextEditingController();

  final selectedTab = CompanyConversationTab.tasks.obs;
  final searchQuery = ''.obs;

  final conversations = <CompanyConversationModel>[].obs;
  final messages = <CompanyConversationMessage>[].obs;

  final selectedConversation =
      Rxn<CompanyConversationModel>();

  final conversationContext =
      Rxn<CompanyConversationContext>();

  final RxnInt currentUserId = RxnInt();

  final isLoadingConversations = false.obs;
  final isLoadingMore = false.obs;
  final isLoadingMessages = false.obs;
  final isSending = false.obs;
  final isUpdating = false.obs;

  final conversationsError = RxnString();
  final messagesError = RxnString();

  int currentPage = 1;
  int lastPage = 1;
  int perPage = 15;

  bool get canLoadMore => currentPage < lastPage;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUserId();
  }

  @override
  void onReady() {
    super.onReady();

    if (conversations.isEmpty) {
      fetchCurrentConversations();
    }
  }

  Future<void> _loadCurrentUserId() async {
    currentUserId.value =
        await _authService.getUserId();
  }

  void updateSearchQuery(String value) {
    searchQuery.value =
        value.trim().toLowerCase();
  }

  List<CompanyConversationModel>
      get visibleConversations {
    final query = searchQuery.value;

    if (query.isEmpty) {
      return conversations.toList();
    }

    return conversations.where((conversation) {
      final taskTitle =
          conversation.displayTaskTitle.toLowerCase();

      final studentName =
          participantName(conversation).toLowerCase();

      final latestMessage =
          latestMessageText(conversation).toLowerCase();

      return taskTitle.contains(query) ||
          studentName.contains(query) ||
          latestMessage.contains(query);
    }).toList();
  }

  int get totalUnreadMessages {
    return conversations.fold(
      0,
      (total, conversation) =>
          total +
          conversation.unreadMessagesCount,
    );
  }

  Future<void> changeTab(
    CompanyConversationTab tab,
  ) async {
    if (selectedTab.value == tab &&
        conversations.isNotEmpty) {
      return;
    }

    selectedTab.value = tab;

    currentPage = 1;
    lastPage = 1;

    conversations.clear();
    conversationsError.value = null;

    await fetchCurrentConversations();
  }

  String tabTitle() {
    switch (selectedTab.value) {
      case CompanyConversationTab.tasks:
        return 'محادثات المهام';

      case CompanyConversationTab.all:
        return 'كل المحادثات';

      case CompanyConversationTab.closed:
        return 'المحادثات المغلقة';
    }
  }

  Future<void> fetchCurrentConversations({
    bool refresh = true,
  }) async {
    switch (selectedTab.value) {
      case CompanyConversationTab.tasks:
        await _fetchTasks(refresh: refresh);
        break;

      case CompanyConversationTab.all:
        await _fetchAll(refresh: refresh);
        break;

      case CompanyConversationTab.closed:
        await _fetchClosed(refresh: refresh);
        break;
    }
  }

  Future<void> _fetchTasks({
    required bool refresh,
  }) async {
    await _loadConversationList(
      () => _service.getTaskConversations(
        page: currentPage,
        perPage: perPage,
      ),
      refresh: refresh,
    );
  }

  Future<void> _fetchAll({
    required bool refresh,
  }) async {
    await _loadConversationList(
      () => _service.getAllConversations(
        page: currentPage,
        perPage: perPage,
      ),
      refresh: refresh,
    );
  }

  Future<void> _fetchClosed({
    required bool refresh,
  }) async {
    await _loadConversationList(
      () => _service.getClosedConversations(
        page: currentPage,
        perPage: perPage,
      ),
      refresh: refresh,
    );
  }

  Future<void> _loadConversationList(
    Future<CompanyConversationListResponse>
            Function()
        request, {
    required bool refresh,
  }) async {
    try {
      conversationsError.value = null;

      if (refresh) {
        currentPage = 1;
        isLoadingConversations.value = true;
      } else {
        isLoadingMore.value = true;
      }

      final response = await request();

      currentPage =
          response.pagination.currentPage;
      lastPage = response.pagination.lastPage;
      perPage = response.pagination.perPage;

      if (refresh) {
        conversations.assignAll(
          response.items,
        );
      } else {
        conversations.addAll(
          response.items,
        );
      }
    } catch (e) {
      conversationsError.value =
          _cleanError(e);
    } finally {
      isLoadingConversations.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!canLoadMore ||
        isLoadingMore.value ||
        isLoadingConversations.value) {
      return;
    }

    currentPage++;

    await fetchCurrentConversations(
      refresh: false,
    );
  }

  CompanyConversationParticipant?
      otherParticipant(
    CompanyConversationModel conversation,
  ) {
    final studentByRole =
        conversation.participants.firstWhereOrNull(
      (participant) =>
          participant.role?.toLowerCase() ==
          'student',
    );

    if (studentByRole != null) {
      return studentByRole;
    }

    final userId = currentUserId.value;

    if (userId != null) {
      final participant = conversation
          .participants
          .firstWhereOrNull(
        (participant) =>
            participant.id != userId,
      );

      if (participant != null) {
        return participant;
      }
    }

    if (conversation.participants.isNotEmpty) {
      return conversation.participants.last;
    }

    return null;
  }

  String participantName(
    CompanyConversationModel conversation,
  ) {
    return otherParticipant(conversation)?.name ??
        'طالب';
  }

  Future<void> openConversation(
    CompanyConversationModel conversation,
  ) async {
    selectedConversation.value = conversation;

    conversationContext.value = null;
    messagesError.value = null;

    messages.clear();

    await fetchMessages(conversation.id);

    await markAsRead(conversation.id);
  }

  Future<void> fetchMessages(
    int conversationId,
  ) async {
    try {
      messagesError.value = null;
      isLoadingMessages.value = true;

      final response =
          await _service.getMessages(
        conversationId,
      );

      conversationContext.value =
          response.conversation;

      messages.assignAll(
        response.items,
      );
    } catch (e) {
      messagesError.value =
          _cleanError(e);
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> sendMessage() async {
    final conversation =
        selectedConversation.value;

    final content =
        messageController.text.trim();

    if (conversation == null) {
      return;
    }

    if (isConversationClosed) {
      _showWarning(
        'المحادثة مغلقة',
        'هذه المحادثة متاحة للقراءة فقط',
      );
      return;
    }

    if (content.isEmpty) {
      _showWarning(
        'رسالة فارغة',
        'اكتب نص الرسالة أولاً',
      );
      return;
    }

    if (isSending.value) {
      return;
    }

    try {
      isSending.value = true;

      final sentMessage =
          await _service.sendMessage(
        conversationId: conversation.id,
        content: content,
      );

      final myMessage =
          sentMessage.copyWith(
        isMine: true,
      );

      messages.add(myMessage);

      messageController.clear();

      _updateLatestMessage(
        conversation.id,
        myMessage,
      );
    } catch (e) {
      _showError(
        e,
        title: 'فشل الإرسال',
      );
    } finally {
      isSending.value = false;
    }
  }

  bool canEditMessage(
    CompanyConversationMessage message,
  ) {
    return message.isMine &&
        !message.isRead &&
        !message.isSystem &&
        !isConversationClosed;
  }

  void prepareEditMessage(
    CompanyConversationMessage message,
  ) {
    editMessageController.text =
        message.content;
  }

  Future<void> updateMessage(
    CompanyConversationMessage message,
  ) async {
    if (!canEditMessage(message)) {
      _showWarning(
        'لا يمكن التعديل',
        'لا يمكن تعديل الرسالة بعد قراءتها',
      );
      return;
    }

    final content =
        editMessageController.text.trim();

    if (content.isEmpty) {
      _showWarning(
        'رسالة فارغة',
        'اكتب النص الجديد أولاً',
      );
      return;
    }

    if (isUpdating.value) {
      return;
    }

    try {
      isUpdating.value = true;

      final updatedMessage =
          await _service.updateMessage(
        messageId: message.id,
        content: content,
      );

      final index = messages.indexWhere(
        (item) => item.id == message.id,
      );

      if (index != -1) {
        messages[index] =
            messages[index].copyWith(
          content: updatedMessage.content,
          updatedAt:
              updatedMessage.updatedAt,
          isMine: true,
          isRead: updatedMessage.isRead,
          readAt: updatedMessage.readAt,
        );

        messages.refresh();

        final conversation =
            selectedConversation.value;

        if (conversation != null) {
          _updateLatestMessage(
            conversation.id,
            messages[index],
          );
        }
      }

      editMessageController.clear();

      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }

      JisrSnackbar.show(
        title: 'تم التعديل',
        message:
            'تم تعديل الرسالة بنجاح',
        type: JisrSnackbarType.success,
      );
    } catch (e) {
      _showError(
        e,
        title: 'فشل التعديل',
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> markAsRead(
    int conversationId,
  ) async {
    try {
      await _service.markAsRead(
        conversationId,
      );

      final index = conversations.indexWhere(
        (conversation) =>
            conversation.id ==
            conversationId,
      );

      if (index != -1) {
        conversations[index] =
            conversations[index].copyWith(
          unreadMessagesCount: 0,
        );

        conversations.refresh();
      }
    } catch (e) {
      debugPrint(
        'Company conversation mark read error: $e',
      );
    }
  }

  bool get isConversationClosed {
    final contextStatus =
        conversationContext.value?.status;

    if (contextStatus != null &&
        contextStatus.trim().isNotEmpty) {
      return contextStatus.toLowerCase() ==
          'closed';
    }

    return selectedConversation
            .value
            ?.isClosed ??
        false;
  }

  String get currentTaskTitle {
    final contextTask =
        conversationContext
            .value
            ?.task
            ?.title
            .trim();

    if (contextTask != null &&
        contextTask.isNotEmpty) {
      return contextTask;
    }

    return selectedConversation
            .value
            ?.displayTaskTitle ??
        'المحادثة';
  }

  String assignmentStatusLabel(
    String? status,
  ) {
    switch (status?.toLowerCase()) {
      case 'working':
        return 'قيد التنفيذ';

      case 'completed':
        return 'مكتملة';

      case 'under_review':
        return 'قيد المراجعة';

      case 'closed':
        return 'مغلقة';

      case 'pending':
        return 'بانتظار البدء';

      default:
        return status ?? '';
    }
  }

  /// يحول فقط System Message الخاصة بقبول الطالب
  /// إلى صياغة مناسبة لواجهة الشركة.
  ///
  /// الـ Shared Message Bubble لا يعرف أي شيء
  /// عن Company أو Student.
  String displayMessageContent(
    CompanyConversationMessage message,
  ) {
    final content = message.content.trim();

    if (!message.isSystem) {
      return content;
    }

    final isAcceptanceMessage =
        content.contains('تم قبولك') &&
            (content.contains('المهمة') ||
                content.contains('مهمة'));

    if (isAcceptanceMessage) {
      return 'تم قبول الطالب رسميًا في هذه المهمة. '
          'يمكنك الآن التواصل معه ومتابعة التنفيذ عبر هذه المحادثة.';
    }

    return content;
  }

  String latestMessageText(
    CompanyConversationModel conversation,
  ) {
    final latestMessage =
        conversation.latestMessage;

    if (latestMessage == null) {
      return 'لا توجد رسائل بعد';
    }

    final content =
        latestMessage.content.trim();

    if (content.isEmpty) {
      return 'لا توجد رسائل بعد';
    }

    final isSystemMessage =
        latestMessage.senderId == null;

    if (isSystemMessage) {
      final isAcceptanceMessage =
          content.contains('تم قبولك') &&
              (content.contains('المهمة') ||
                  content.contains('مهمة'));

      if (isAcceptanceMessage) {
        return 'تم قبول الطالب رسميًا في هذه المهمة. '
            'يمكنك الآن التواصل معه ومتابعة التنفيذ عبر هذه المحادثة.';
      }
    }

    return content;
  }

  bool isLatestMessageMine(
    CompanyConversationModel conversation,
  ) {
    final senderId =
        conversation.latestMessage?.senderId;

    final userId = currentUserId.value;

    if (senderId == null ||
        userId == null) {
      return false;
    }

    return senderId == userId;
  }

  String formatTime(String? value) {
    final date = _parseDate(value);

    if (date == null) {
      return '';
    }

    final hour = date.hour % 12 == 0
        ? 12
        : date.hour % 12;

    final minute =
        date.minute
            .toString()
            .padLeft(2, '0');

    final period =
        date.hour >= 12 ? 'م' : 'ص';

    return '$hour:$minute $period';
  }

  String formatDate(String? value) {
    final date = _parseDate(value);

    if (date == null) {
      return '';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  String relativeTime(String? value) {
    final date = _parseDate(value);

    if (date == null) {
      return '';
    }

    final difference =
        DateTime.now().difference(date);

    if (difference.isNegative) {
      return 'الآن';
    }

    if (difference.inSeconds < 60) {
      return 'الآن';
    }

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    }

    if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    }

    if (difference.inDays == 1) {
      return 'أمس';
    }

    if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  String readStatusText(
    CompanyConversationMessage message,
  ) {
    if (!message.isMine) {
      return '';
    }

    if (!message.isRead) {
      return 'لم تتم القراءة بعد';
    }

    final relative =
        relativeTime(message.readAt);

    if (relative.isEmpty) {
      return 'تمت القراءة';
    }

    return 'تمت القراءة $relative';
  }

  DateTime? _parseDate(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return null;
    }

    final normalized =
        value.contains('T')
            ? value
            : value.replaceFirst(
                ' ',
                'T',
              );

    final parsed =
        DateTime.tryParse(normalized);

    if (parsed == null) {
      return null;
    }

    return parsed.isUtc
        ? parsed.toLocal()
        : parsed;
  }

  void _updateLatestMessage(
    int conversationId,
    CompanyConversationMessage message,
  ) {
    final index = conversations.indexWhere(
      (conversation) =>
          conversation.id ==
          conversationId,
    );

    if (index == -1) {
      return;
    }

    conversations[index] =
        conversations[index].copyWith(
      unreadMessagesCount: 0,
      latestMessage:
          CompanyLatestMessage(
        id: message.id,
        senderId:
            message.sender?.id ??
            currentUserId.value,
        content: message.content,
        createdAt: message.createdAt,
      ),
    );

    conversations.refresh();
  }

  void _showWarning(
    String title,
    String message,
  ) {
    JisrSnackbar.show(
      title: title,
      message: message,
      type: JisrSnackbarType.warning,
    );
  }

  void _showError(
    Object error, {
    String title = 'خطأ',
  }) {
    JisrSnackbar.show(
      title: title,
      message: _cleanError(error),
      type: JisrSnackbarType.error,
    );
  }

  String _cleanError(
    Object error,
  ) {
    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );
  }

  @override
  void onClose() {
    messageController.dispose();
    editMessageController.dispose();

    super.onClose();
  }
}