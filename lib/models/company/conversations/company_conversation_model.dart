class CompanyConversationListResponse {
  final bool status;
  final String message;
  final List<CompanyConversationModel> items;
  final CompanyConversationPagination pagination;

  const CompanyConversationListResponse({
    required this.status,
    required this.message,
    required this.items,
    required this.pagination,
  });

  factory CompanyConversationListResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = _asMap(json['data']);

    return CompanyConversationListResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      items: _asList(data['items'])
          .map((item) => CompanyConversationModel.fromJson(_asMap(item)))
          .toList(),
      pagination: CompanyConversationPagination.fromJson(
        _asMap(data['pagination']),
      ),
    );
  }
}

class CompanyConversationMessagesResponse {
  final bool status;
  final String message;
  final CompanyConversationContext? conversation;
  final List<CompanyConversationMessage> items;
  final CompanyConversationPagination pagination;

  const CompanyConversationMessagesResponse({
    required this.status,
    required this.message,
    required this.conversation,
    required this.items,
    required this.pagination,
  });

  factory CompanyConversationMessagesResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = _asMap(json['data']);

    return CompanyConversationMessagesResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      conversation: data['conversation'] is Map
          ? CompanyConversationContext.fromJson(
              _asMap(data['conversation']),
            )
          : null,
      items: _asList(data['items'])
          .map((item) => CompanyConversationMessage.fromJson(_asMap(item)))
          .toList(),
      pagination: CompanyConversationPagination.fromJson(
        _asMap(data['pagination']),
      ),
    );
  }
}

class CompanyConversationModel {
  final int id;
  final String type;
  final String status;
  final CompanyConversationTaskAssignment? taskAssignment;
  final CompanyConversationTask? task;
  final int unreadMessagesCount;
  final CompanyLatestMessage? latestMessage;
  final List<CompanyConversationParticipant> participants;
  final String? createdAt;
  final String? updatedAt;

  const CompanyConversationModel({
    required this.id,
    required this.type,
    required this.status,
    required this.taskAssignment,
    required this.task,
    required this.unreadMessagesCount,
    required this.latestMessage,
    required this.participants,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyConversationModel.fromJson(Map<String, dynamic> json) {
    return CompanyConversationModel(
      id: _toInt(json['id']),
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      taskAssignment: json['task_assignment'] is Map
          ? CompanyConversationTaskAssignment.fromJson(
              _asMap(json['task_assignment']),
            )
          : null,
      task: json['task'] is Map
          ? CompanyConversationTask.fromJson(_asMap(json['task']))
          : null,
      unreadMessagesCount: _toInt(json['unread_messages_count']),
      latestMessage: json['latest_message'] is Map
          ? CompanyLatestMessage.fromJson(
              _asMap(json['latest_message']),
            )
          : null,
      participants: _asList(json['participants'])
          .map(
            (item) =>
                CompanyConversationParticipant.fromJson(_asMap(item)),
          )
          .toList(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  bool get isClosed => status.toLowerCase() == 'closed';

  String get displayTaskTitle {
    final title = task?.title.trim();

    if (title != null && title.isNotEmpty) {
      return title;
    }

    return 'مهمة';
  }

  CompanyConversationModel copyWith({
    int? unreadMessagesCount,
    CompanyLatestMessage? latestMessage,
  }) {
    return CompanyConversationModel(
      id: id,
      type: type,
      status: status,
      taskAssignment: taskAssignment,
      task: task,
      unreadMessagesCount:
          unreadMessagesCount ?? this.unreadMessagesCount,
      latestMessage: latestMessage ?? this.latestMessage,
      participants: participants,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class CompanyConversationTask {
  final int id;
  final int? assignmentId;
  final String title;
  final String? deadline;
  final String? assignmentStatus;

  const CompanyConversationTask({
    required this.id,
    required this.assignmentId,
    required this.title,
    required this.deadline,
    required this.assignmentStatus,
  });

  factory CompanyConversationTask.fromJson(Map<String, dynamic> json) {
    return CompanyConversationTask(
      id: _toInt(json['id']),
      assignmentId: json['assignment_id'] == null
          ? null
          : _toInt(json['assignment_id']),
      title: json['title']?.toString() ?? '',
      deadline: json['deadline']?.toString(),
      assignmentStatus: json['assignment_status']?.toString(),
    );
  }
}

class CompanyConversationTaskAssignment {
  final int id;
  final String type;

  const CompanyConversationTaskAssignment({
    required this.id,
    required this.type,
  });

  factory CompanyConversationTaskAssignment.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyConversationTaskAssignment(
      id: _toInt(json['id']),
      type: json['type']?.toString() ?? '',
    );
  }
}

class CompanyConversationParticipant {
  final int id;
  final String name;
  final String email;
  final String? role;
  final String? profilePictureUrl;

  const CompanyConversationParticipant({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.profilePictureUrl,
  });

  factory CompanyConversationParticipant.fromJson(
    Map<String, dynamic> json,
  ) {
    final pivot = _asMap(json['pivot']);

    return CompanyConversationParticipant(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? 'طالب',
      email: json['email']?.toString() ?? '',
      role:
          json['role']?.toString() ??
          pivot['role']?.toString(),
      profilePictureUrl: json['profile_picture_url']?.toString(),
    );
  }
}

class CompanyLatestMessage {
  final int id;
  final int? senderId;
  final String content;
  final String? createdAt;

  const CompanyLatestMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory CompanyLatestMessage.fromJson(Map<String, dynamic> json) {
    return CompanyLatestMessage(
      id: _toInt(json['id']),
      senderId: json['sender_id'] == null
          ? null
          : _toInt(json['sender_id']),
      content: json['content']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
    );
  }
}

class CompanyConversationContext {
  final int id;
  final String type;
  final String status;
  final CompanyConversationTask? task;
  final String? createdAt;
  final String? updatedAt;

  const CompanyConversationContext({
    required this.id,
    required this.type,
    required this.status,
    required this.task,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyConversationContext.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyConversationContext(
      id: _toInt(json['id']),
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      task: json['task'] is Map
          ? CompanyConversationTask.fromJson(_asMap(json['task']))
          : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  bool get isClosed => status.toLowerCase() == 'closed';
}

class CompanyConversationMessage {
  final int id;
  final int conversationId;
  final String type;
  final String content;
  final CompanyMessageSender? sender;
  final bool isMine;
  final bool isRead;
  final String? readAt;
  final String? createdAt;
  final String? updatedAt;

  const CompanyConversationMessage({
    required this.id,
    required this.conversationId,
    required this.type,
    required this.content,
    required this.sender,
    required this.isMine,
    required this.isRead,
    required this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyConversationMessage.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyConversationMessage(
      id: _toInt(json['id']),
      conversationId: _toInt(json['conversation_id']),
      type: json['type']?.toString() ?? 'text',
      content: json['content']?.toString() ?? '',
      sender: json['sender'] is Map
          ? CompanyMessageSender.fromJson(_asMap(json['sender']))
          : null,
      isMine: json['is_mine'] == true,
      isRead:
          json['is_read'] == true ||
          json['read_at'] != null,
      readAt: json['read_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  bool get isSystem => type == 'system' || sender == null;

  CompanyConversationMessage copyWith({
    String? content,
    bool? isMine,
    bool? isRead,
    String? readAt,
    String? updatedAt,
  }) {
    return CompanyConversationMessage(
      id: id,
      conversationId: conversationId,
      type: type,
      content: content ?? this.content,
      sender: sender,
      isMine: isMine ?? this.isMine,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CompanyMessageSender {
  final int id;
  final String name;
  final String email;
  final String role;

  const CompanyMessageSender({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory CompanyMessageSender.fromJson(Map<String, dynamic> json) {
    return CompanyMessageSender(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? 'مستخدم',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }
}

class CompanyConversationPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const CompanyConversationPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory CompanyConversationPagination.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyConversationPagination(
      currentPage: _toInt(json['current_page'], fallback: 1),
      lastPage: _toInt(json['last_page'], fallback: 1),
      perPage: _toInt(json['per_page'], fallback: 15),
      total: _toInt(json['total']),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  return value is List ? value : const [];
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }

  return int.tryParse(value?.toString() ?? '') ?? fallback;
}