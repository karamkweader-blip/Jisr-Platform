class ConversationListResponse {
  final bool status;
  final String message;
  final List<StudentConversationModel> items;
  final ConversationPagination pagination;

  const ConversationListResponse({
    required this.status,
    required this.message,
    required this.items,
    required this.pagination,
  });

  factory ConversationListResponse.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);

    return ConversationListResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      items: _asList(data['items'])
          .map((item) => StudentConversationModel.fromJson(_asMap(item)))
          .toList(),
      pagination: ConversationPagination.fromJson(
        _asMap(data['pagination']),
      ),
    );
  }
}

class ConversationMessagesResponse {
  final bool status;
  final String message;
  final ConversationContextModel? conversation;
  final List<ConversationMessageModel> items;
  final ConversationPagination pagination;

  const ConversationMessagesResponse({
    required this.status,
    required this.message,
    required this.conversation,
    required this.items,
    required this.pagination,
  });

  factory ConversationMessagesResponse.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);

    return ConversationMessagesResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      conversation: data['conversation'] is Map
          ? ConversationContextModel.fromJson(_asMap(data['conversation']))
          : null,
      items: _asList(data['items'])
          .map((item) => ConversationMessageModel.fromJson(_asMap(item)))
          .toList(),
      pagination: ConversationPagination.fromJson(
        _asMap(data['pagination']),
      ),
    );
  }
}

class StudentConversationModel {
  final int id;
  final String type;
  final int? contextId;
  final String status;
  final ConversationTaskModel? task;
  final ConversationTaskAssignmentModel? taskAssignment;
  final int unreadMessagesCount;
  final ConversationLatestMessage? latestMessage;
  final List<ConversationUserModel> participants;
  final String? createdAt;
  final String? updatedAt;

  const StudentConversationModel({
    required this.id,
    required this.type,
    required this.contextId,
    required this.status,
    required this.task,
    required this.taskAssignment,
    required this.unreadMessagesCount,
    required this.latestMessage,
    required this.participants,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentConversationModel.fromJson(Map<String, dynamic> json) {
    return StudentConversationModel(
      id: _toInt(json['id']),
      type: json['type']?.toString() ?? '',
      contextId:
          json['context_id'] == null ? null : _toInt(json['context_id']),
      status: json['status']?.toString() ?? '',
      task: json['task'] is Map
          ? ConversationTaskModel.fromJson(_asMap(json['task']))
          : null,
      taskAssignment: json['task_assignment'] is Map
          ? ConversationTaskAssignmentModel.fromJson(
              _asMap(json['task_assignment']),
            )
          : null,
      unreadMessagesCount: _toInt(json['unread_messages_count']),
      latestMessage: json['latest_message'] is Map
          ? ConversationLatestMessage.fromJson(_asMap(json['latest_message']))
          : null,
      participants: _asList(json['participants'])
          .map((item) => ConversationUserModel.fromJson(_asMap(item)))
          .toList(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  bool get isClosed => status.toLowerCase() == 'closed';

  String get displayTaskTitle {
    final taskTitle = task?.title.trim();
    if (taskTitle != null && taskTitle.isNotEmpty) return taskTitle;

    final legacyTitle = taskAssignment?.title?.trim();
    if (legacyTitle != null && legacyTitle.isNotEmpty) return legacyTitle;

    final taskId = task?.id ?? taskAssignment?.id ?? contextId;
    if (taskId != null && taskId > 0) return 'مهمة رقم $taskId';

    return 'مهمة';
  }

  StudentConversationModel copyWith({
    int? unreadMessagesCount,
    ConversationLatestMessage? latestMessage,
  }) {
    return StudentConversationModel(
      id: id,
      type: type,
      contextId: contextId,
      status: status,
      task: task,
      taskAssignment: taskAssignment,
      unreadMessagesCount:
          unreadMessagesCount ?? this.unreadMessagesCount,
      latestMessage: latestMessage ?? this.latestMessage,
      participants: participants,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class ConversationTaskModel {
  final int id;
  final int? assignmentId;
  final String title;
  final String? deadline;
  final String? assignmentStatus;

  const ConversationTaskModel({
    required this.id,
    required this.assignmentId,
    required this.title,
    required this.deadline,
    required this.assignmentStatus,
  });

  factory ConversationTaskModel.fromJson(Map<String, dynamic> json) {
    return ConversationTaskModel(
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

/// دعم احتياطي للعقد القديم بدون الاعتماد عليه في الواجهة الجديدة.
class ConversationTaskAssignmentModel {
  final int id;
  final String type;
  final String? title;

  const ConversationTaskAssignmentModel({
    required this.id,
    required this.type,
    required this.title,
  });

  factory ConversationTaskAssignmentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final nestedTask = _asMap(json['task']);

    return ConversationTaskAssignmentModel(
      id: _toInt(json['id']),
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ??
          json['task_title']?.toString() ??
          nestedTask['title']?.toString(),
    );
  }
}

class ConversationLatestMessage {
  final int id;
  final int? senderId;
  final String content;
  final String? createdAt;

  const ConversationLatestMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory ConversationLatestMessage.fromJson(Map<String, dynamic> json) {
    final sender = _asMap(json['sender']);

    return ConversationLatestMessage(
      id: _toInt(json['id']),
      senderId: json['sender_id'] == null
          ? (sender.isEmpty ? null : _toInt(sender['id']))
          : _toInt(json['sender_id']),
      content: json['content']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
    );
  }
}

class ConversationContextModel {
  final int id;
  final String type;
  final String status;
  final ConversationTaskModel? task;
  final String? createdAt;
  final String? updatedAt;

  const ConversationContextModel({
    required this.id,
    required this.type,
    required this.status,
    required this.task,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConversationContextModel.fromJson(Map<String, dynamic> json) {
    return ConversationContextModel(
      id: _toInt(json['id']),
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      task: json['task'] is Map
          ? ConversationTaskModel.fromJson(_asMap(json['task']))
          : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  bool get isClosed => status.toLowerCase() == 'closed';
}

class ConversationMessageModel {
  final int id;
  final int conversationId;
  final int? senderId;
  final ConversationUserModel? sender;
  final String type;
  final String content;
  final bool isMine;
  final bool isRead;
  final String? readAt;
  final String? createdAt;
  final String? updatedAt;

  const ConversationMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.sender,
    required this.type,
    required this.content,
    required this.isMine,
    required this.isRead,
    required this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConversationMessageModel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] is Map
        ? ConversationUserModel.fromJson(_asMap(json['sender']))
        : null;

    return ConversationMessageModel(
      id: _toInt(json['id']),
      conversationId: _toInt(json['conversation_id']),
      senderId: json['sender_id'] == null
          ? sender?.id
          : _toInt(json['sender_id']),
      sender: sender,
      type: json['type']?.toString() ?? 'text',
      content: json['content']?.toString() ?? '',
      isMine: json['is_mine'] == true,
      isRead: json['is_read'] == true || json['read_at'] != null,
      readAt: json['read_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  bool get isSystem => type.toLowerCase() == 'system' || sender == null;

  ConversationMessageModel copyWith({
    String? content,
    bool? isMine,
    bool? isRead,
    String? readAt,
    String? updatedAt,
  }) {
    return ConversationMessageModel(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      sender: sender,
      type: type,
      content: content ?? this.content,
      isMine: isMine ?? this.isMine,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ConversationUserModel {
  final int id;
  final String name;
  final String email;
  final String? role;
  final String? profilePictureUrl;

  const ConversationUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.profilePictureUrl,
  });

  factory ConversationUserModel.fromJson(Map<String, dynamic> json) {
    final pivot = _asMap(json['pivot']);

    return ConversationUserModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? 'مستخدم',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? pivot['role']?.toString(),
      profilePictureUrl: json['profile_picture_url']?.toString(),
    );
  }
}

class ConversationPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const ConversationPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory ConversationPagination.fromJson(Map<String, dynamic> json) {
    return ConversationPagination(
      currentPage: _toInt(json['current_page'], fallback: 1),
      lastPage: _toInt(json['last_page'], fallback: 1),
      perPage: _toInt(json['per_page'], fallback: 15),
      total: _toInt(json['total']),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  return value is List ? value : const [];
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
