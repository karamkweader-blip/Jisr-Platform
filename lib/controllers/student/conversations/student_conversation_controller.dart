import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/core/widgets/jisr_snackbar.dart';
import 'package:jisr_platform/models/student/conversations/student_conversation_model.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';
import 'package:jisr_platform/services/student/conversations/student_conversation_service.dart';

enum ConversationTabType { task, all, closed }

class StudentConversationController extends GetxController {
  final StudentConversationService _service;
  final AuthService _authService;

  StudentConversationController(this._service, this._authService);

  final messageController = TextEditingController();
  final editMessageController = TextEditingController();

  final selectedTab = ConversationTabType.task.obs;
  final searchQuery = ''.obs;

  final conversations = <StudentConversationModel>[].obs;
  final messages = <ConversationMessageModel>[].obs;

  final selectedConversation = Rxn<StudentConversationModel>();
  final conversationContext = Rxn<ConversationContextModel>();
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
  int totalConversations = 0;

  bool get canLoadMore => currentPage < lastPage;

  // أسماء توافقية مع الواجهة القديمة حتى لا ينكسر أي استدعاء خارجي.
  RxBool get isLoadingMoreConversations => isLoadingMore;
  bool get canLoadMoreConversations => canLoadMore;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUserId();
  }

  @override
  void onReady() {
    super.onReady();
    if (conversations.isEmpty) fetchCurrentConversations();
  }

  Future<void> _loadCurrentUserId() async {
    currentUserId.value = await _authService.getUserId();
  }

  void updateSearchQuery(String value) {
    searchQuery.value = value.trim().toLowerCase();
  }

  List<StudentConversationModel> get visibleConversations {
    final query = searchQuery.value;
    if (query.isEmpty) return conversations.toList();

    return conversations.where((conversation) {
      return conversation.displayTaskTitle.toLowerCase().contains(query) ||
          participantName(conversation).toLowerCase().contains(query) ||
          latestMessageText(conversation).toLowerCase().contains(query);
    }).toList();
  }

  int get totalUnreadMessages {
    return conversations.fold(
      0,
      (total, conversation) => total + conversation.unreadMessagesCount,
    );
  }

  Future<void> changeTab(ConversationTabType tab) async {
    if (selectedTab.value == tab && conversations.isNotEmpty) return;

    selectedTab.value = tab;
    searchQuery.value = '';
    currentPage = 1;
    lastPage = 1;
    totalConversations = 0;
    conversations.clear();
    conversationsError.value = null;

    await fetchCurrentConversations();
  }

  Future<void> changeConversationTab(ConversationTabType tab) => changeTab(tab);

  String tabTitle() {
    switch (selectedTab.value) {
      case ConversationTabType.task:
        return 'محادثات المهام';
      case ConversationTabType.all:
        return 'كل المحادثات';
      case ConversationTabType.closed:
        return 'المحادثات المغلقة';
    }
  }

  String selectedTabTitle() => tabTitle();

  Future<void> fetchCurrentConversations({bool refresh = true}) async {
    switch (selectedTab.value) {
      case ConversationTabType.task:
        await _loadConversationList(
          () => _service.getTaskConversations(
            page: currentPage,
            perPage: perPage,
          ),
          refresh: refresh,
        );
        break;
      case ConversationTabType.all:
        await _loadConversationList(
          () => _service.getAllConversations(
            page: currentPage,
            perPage: perPage,
          ),
          refresh: refresh,
        );
        break;
      case ConversationTabType.closed:
        await _loadConversationList(
          () => _service.getClosedConversations(
            page: currentPage,
            perPage: perPage,
          ),
          refresh: refresh,
        );
        break;
    }
  }

  Future<void> _loadConversationList(
    Future<ConversationListResponse> Function() request, {
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

      currentPage = response.pagination.currentPage;
      lastPage = response.pagination.lastPage;
      perPage = response.pagination.perPage;
      totalConversations = response.pagination.total;

      if (refresh) {
        conversations.assignAll(response.items);
      } else {
        conversations.addAll(response.items);
      }
    } catch (error) {
      conversationsError.value = _cleanError(error);
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
    await fetchCurrentConversations(refresh: false);
  }

  Future<void> loadMoreConversations() => loadMore();

  ConversationUserModel? otherParticipant(
    StudentConversationModel conversation,
  ) {
    final companyByRole = conversation.participants.firstWhereOrNull(
      (participant) => participant.role?.toLowerCase() == 'company',
    );

    if (companyByRole != null) return companyByRole;

    final userId = currentUserId.value;
    if (userId != null) {
      final other = conversation.participants.firstWhereOrNull(
        (participant) => participant.id != userId,
      );
      if (other != null) return other;
    }

    if (conversation.participants.isNotEmpty) {
      return conversation.participants.last;
    }

    return null;
  }

  String participantName(StudentConversationModel conversation) {
    return otherParticipant(conversation)?.name ?? 'شركة';
  }

  String otherParticipantName(StudentConversationModel conversation) =>
      participantName(conversation);

  String conversationCompanyName(StudentConversationModel conversation) =>
      participantName(conversation);

  String conversationTaskTitle(StudentConversationModel conversation) =>
      conversation.displayTaskTitle;

  Future<void> openConversation(
    StudentConversationModel conversation,
  ) async {
    selectedConversation.value = conversation;
    conversationContext.value = null;
    messagesError.value = null;
    messages.clear();

    await fetchMessages(conversation.id);
    await markAsRead(conversation.id);
  }

  Future<void> fetchMessages(int conversationId) async {
    try {
      messagesError.value = null;
      isLoadingMessages.value = true;

      final response = await _service.getMessages(conversationId);
      conversationContext.value = response.conversation;
      messages.assignAll(response.items);
    } catch (error) {
      messagesError.value = _cleanError(error);
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> sendMessage() async {
    final conversation = selectedConversation.value;
    final content = messageController.text.trim();

    if (conversation == null) return;

    if (isConversationClosed) {
      _showWarning(
        'المحادثة مغلقة',
        'هذه المحادثة متاحة للقراءة فقط',
      );
      return;
    }

    if (content.isEmpty) {
      _showWarning('رسالة فارغة', 'اكتب نص الرسالة أولاً');
      return;
    }

    if (isSending.value) return;

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
    } catch (error) {
      _showError(error, title: 'فشل الإرسال');
    } finally {
      isSending.value = false;
    }
  }

  bool isSystemMessage(ConversationMessageModel message) => message.isSystem;

  bool canEditMessage(ConversationMessageModel message) {
    return message.isMine &&
        !message.isRead &&
        !message.isSystem &&
        !isConversationClosed;
  }

  bool isReadByOtherSide(ConversationMessageModel message) {
    return message.isMine && message.isRead;
  }

  void prepareEditMessage(ConversationMessageModel message) {
    editMessageController.text = message.content;
  }

  Future<void> updateMessage(ConversationMessageModel message) async {
    if (!canEditMessage(message)) {
      _showWarning(
        'لا يمكن التعديل',
        'لا يمكن تعديل الرسالة بعد قراءتها',
      );
      return;
    }

    final content = editMessageController.text.trim();

    if (content.isEmpty) {
      _showWarning('رسالة فارغة', 'اكتب النص الجديد أولاً');
      return;
    }

    if (isUpdating.value) return;

    try {
      isUpdating.value = true;

      final updatedMessage = await _service.updateMessage(
        messageId: message.id,
        content: content,
      );

      final index = messages.indexWhere((item) => item.id == message.id);

      if (index != -1) {
        messages[index] = messages[index].copyWith(
          content: updatedMessage.content,
          updatedAt: updatedMessage.updatedAt,
          isMine: true,
          isRead: updatedMessage.isRead,
          readAt: updatedMessage.readAt,
        );
        messages.refresh();

        final conversation = selectedConversation.value;
        if (conversation != null) {
          _updateLatestMessage(conversation.id, messages[index]);
        }
      }

      editMessageController.clear();
      if (Get.isBottomSheetOpen == true) Get.back();

      JisrSnackbar.show(
        title: 'تم التعديل',
        message: 'تم تعديل الرسالة بنجاح',
        type: JisrSnackbarType.success,
      );
    } catch (error) {
      _showError(error, title: 'فشل التعديل');
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> markAsRead(int conversationId) async {
    try {
      await _service.markAsRead(conversationId);

      final index = conversations.indexWhere(
        (conversation) => conversation.id == conversationId,
      );

      if (index != -1) {
        conversations[index] = conversations[index].copyWith(
          unreadMessagesCount: 0,
        );
        conversations.refresh();
      }
    } catch (error) {
      debugPrint('Student conversation mark read error: $error');
    }
  }

  Future<void> markConversationAsRead(int conversationId) =>
      markAsRead(conversationId);

  bool get isConversationClosed {
    final contextStatus = conversationContext.value?.status;
    if (contextStatus != null && contextStatus.trim().isNotEmpty) {
      return contextStatus.toLowerCase() == 'closed';
    }

    return selectedConversation.value?.isClosed ?? false;
  }

  String get currentTaskTitle {
    final contextTitle = conversationContext.value?.task?.title.trim();
    if (contextTitle != null && contextTitle.isNotEmpty) return contextTitle;

    return selectedConversation.value?.displayTaskTitle ?? 'المحادثة';
  }

  String assignmentStatusLabel(String? status) {
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

  /// يبقي System Message بصياغة الطالب كما أعادها الخادم.
  String displayMessageContent(ConversationMessageModel message) {
    return message.content.trim();
  }

  String latestMessageText(StudentConversationModel conversation) {
    final content = conversation.latestMessage?.content.trim();
    if (content == null || content.isEmpty) return 'لا توجد رسائل بعد';
    return content;
  }

  bool isLatestMessageMine(StudentConversationModel conversation) {
    final senderId = conversation.latestMessage?.senderId;
    final userId = currentUserId.value;
    if (senderId == null || userId == null) return false;
    return senderId == userId;
  }

  String formatTime(String? value) {
    final date = _parseDate(value);
    if (date == null) return '';

    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'م' : 'ص';
    return '$hour:$minute $period';
  }

  String timeOnly(String? value) => formatTime(value);

  String formatDate(String? value) {
    final date = _parseDate(value);
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  String dateOnly(String? value) => formatDate(value);

  String relativeTime(String? value) {
    final date = _parseDate(value);
    if (date == null) return '';

    final difference = DateTime.now().difference(date);
    if (difference.isNegative || difference.inSeconds < 60) return 'الآن';
    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    }
    if (difference.inHours < 24) return 'منذ ${difference.inHours} ساعة';
    if (difference.inDays == 1) return 'أمس';
    if (difference.inDays < 7) return 'منذ ${difference.inDays} أيام';
    return '${date.day}/${date.month}/${date.year}';
  }

  String readStatusText(ConversationMessageModel message) {
    if (!message.isMine) return '';
    if (!message.isRead) return 'لم تتم القراءة بعد';

    final relative = relativeTime(message.readAt);
    return relative.isEmpty ? 'تمت القراءة' : 'تمت القراءة $relative';
  }

  String emptyMessageTitle() {
    switch (selectedTab.value) {
      case ConversationTabType.task:
        return 'لا توجد محادثات مهام';
      case ConversationTabType.all:
        return 'لا توجد محادثات';
      case ConversationTabType.closed:
        return 'لا توجد محادثات مغلقة';
    }
  }

  String emptyMessageSubtitle() {
    switch (selectedTab.value) {
      case ConversationTabType.task:
        return 'ستظهر المحادثات هنا بعد قبولك في إحدى مهام الشركات.';
      case ConversationTabType.all:
        return 'كل محادثاتك المتاحة ستظهر هنا.';
      case ConversationTabType.closed:
        return 'المحادثات المنتهية ستظهر هنا للرجوع إليها لاحقًا.';
    }
  }

  bool get hasMessages => messages.isNotEmpty;

  DateTime? _parseDate(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty || raw == 'null') return null;

    final normalized = raw.contains('T')
        ? raw
        : raw.replaceFirst(' ', 'T');
    final hasTimezone =
        RegExp(r'(Z|[+-]\d{2}:\d{2})$').hasMatch(normalized);
    final parsed = DateTime.tryParse(
      hasTimezone ? normalized : '${normalized}Z',
    );

    return parsed?.toLocal();
  }

  void _updateLatestMessage(
    int conversationId,
    ConversationMessageModel message,
  ) {
    final index = conversations.indexWhere(
      (conversation) => conversation.id == conversationId,
    );

    if (index == -1) return;

    conversations[index] = conversations[index].copyWith(
      unreadMessagesCount: 0,
      latestMessage: ConversationLatestMessage(
        id: message.id,
        senderId: message.sender?.id ?? currentUserId.value,
        content: message.content,
        createdAt: message.createdAt,
      ),
    );
    conversations.refresh();
  }

  void _showWarning(String title, String message) {
    JisrSnackbar.show(
      title: title,
      message: message,
      type: JisrSnackbarType.warning,
    );
  }

  void _showError(Object error, {String title = 'خطأ'}) {
    JisrSnackbar.show(
      title: title,
      message: _cleanError(error),
      type: JisrSnackbarType.error,
    );
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  void onClose() {
    messageController.dispose();
    editMessageController.dispose();
    super.onClose();
  }
}
