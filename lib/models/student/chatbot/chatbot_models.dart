import 'chatbot_mode.dart';

class ChatbotConversation {
  const ChatbotConversation({
    required this.id,
    required this.mode,
    required this.title,
    required this.lastMessagePreview,
    required this.lastMessageAt,
    required this.createdAt,
  });

  final int id;
  final ChatbotMode mode;
  final String title;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final DateTime createdAt;

  factory ChatbotConversation.fromJson(Map<String, dynamic> json) {
    return ChatbotConversation(
      id: _asInt(json['id']),
      mode: ChatbotMode.fromApiValue(json['mode']?.toString() ?? ''),
      title: json['title']?.toString() ?? 'محادثة جديدة',
      lastMessagePreview: json['last_message_preview']?.toString(),
      lastMessageAt: _dateOrNull(json['last_message_at']),
      createdAt: _dateOrNull(json['created_at']) ?? DateTime.now(),
    );
  }
}

class ChatbotAction {
  const ChatbotAction({required this.type, required this.label, this.opportunityId});

  final String type;
  final String label;
  final int? opportunityId;

  bool get canOpenOpportunity => type == 'open_opportunity' && opportunityId != null;

  factory ChatbotAction.fromJson(Map<String, dynamic> json) {
    return ChatbotAction(
      type: json['type']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      opportunityId: _nullableInt(json['opportunity_id']),
    );
  }
}

class ChatbotMessage {
  const ChatbotMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.language,
    required this.status,
    required this.actions,
    required this.createdAt,
    this.clientMessageId,
  });

  final int id;
  final String role;
  final String content;
  final String language;
  final String status;
  final List<ChatbotAction> actions;
  final DateTime createdAt;
  final String? clientMessageId;

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';

  ChatbotMessage copyWith({String? status}) => ChatbotMessage(
        id: id,
        role: role,
        content: content,
        language: language,
        status: status ?? this.status,
        actions: actions,
        createdAt: createdAt,
        clientMessageId: clientMessageId,
      );

  factory ChatbotMessage.fromJson(Map<String, dynamic> json) {
    final rawActions = json['actions'];
    return ChatbotMessage(
      id: _asInt(json['id']),
      role: json['role']?.toString() ?? 'assistant',
      content: json['content']?.toString() ?? '',
      language: json['language']?.toString() ?? 'ar',
      status: json['status']?.toString() ?? 'completed',
      actions: rawActions is List
          ? rawActions.whereType<Map>().map((item) => ChatbotAction.fromJson(Map<String, dynamic>.from(item))).toList(growable: false)
          : const [],
      createdAt: _dateOrNull(json['created_at']) ?? DateTime.now(),
    );
  }

  factory ChatbotMessage.optimistic({
    required int localId,
    required String content,
    required String clientMessageId,
  }) {
    final containsArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(content);
    return ChatbotMessage(
      id: localId,
      role: 'user',
      content: content,
      language: containsArabic ? 'ar' : 'en',
      status: 'pending',
      actions: const [],
      createdAt: DateTime.now(),
      clientMessageId: clientMessageId,
    );
  }
}

class CursorPage<T> {
  const CursorPage({required this.items, required this.nextCursor, required this.hasMore});
  final List<T> items;
  final String? nextCursor;
  final bool hasMore;
}

class ChatbotExchangeResult {
  const ChatbotExchangeResult({
    required this.duplicated,
    required this.userMessage,
    required this.assistantMessage,
    required this.processingStatus,
    this.conversation,
  });

  final bool duplicated;
  final ChatbotConversation? conversation;
  final ChatbotMessage userMessage;
  final ChatbotMessage? assistantMessage;
  final String processingStatus;

  factory ChatbotExchangeResult.fromJson(Map<String, dynamic> json) {
    final conversation = json['conversation'];
    final assistant = json['assistant_message'];
    return ChatbotExchangeResult(
      duplicated: json['duplicated'] == true,
      conversation: conversation is Map ? ChatbotConversation.fromJson(Map<String, dynamic>.from(conversation)) : null,
      userMessage: ChatbotMessage.fromJson(Map<String, dynamic>.from(json['user_message'] as Map)),
      assistantMessage: assistant is Map ? ChatbotMessage.fromJson(Map<String, dynamic>.from(assistant)) : null,
      processingStatus: json['processing_status']?.toString() ?? 'unknown',
    );
  }
}

int _asInt(dynamic value) => value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
int? _nullableInt(dynamic value) => value == null ? null : (value is int ? value : int.tryParse(value.toString()));
DateTime? _dateOrNull(dynamic value) => value == null ? null : DateTime.tryParse(value.toString());
