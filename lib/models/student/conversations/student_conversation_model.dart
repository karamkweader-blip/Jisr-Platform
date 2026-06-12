class ConversationListResponse {
  final bool status;
  final String message;
  final List<StudentConversationModel> items;
  final ConversationPagination pagination;

  ConversationListResponse({
    required this.status,
    required this.message,
    required this.items,
    required this.pagination,
  });

  factory ConversationListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return ConversationListResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      items: (data['items'] as List? ?? [])
          .map((item) => StudentConversationModel.fromJson(item))
          .toList(),
      pagination: ConversationPagination.fromJson(data['pagination'] ?? {}),
    );
  }
}

class ConversationMessagesResponse {
  final bool status;
  final String message;
  final List<ConversationMessageModel> items;
  final ConversationPagination pagination;

  ConversationMessagesResponse({
    required this.status,
    required this.message,
    required this.items,
    required this.pagination,
  });

  factory ConversationMessagesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return ConversationMessagesResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      items: (data['items'] as List? ?? [])
          .map((item) => ConversationMessageModel.fromJson(item))
          .toList(),
      pagination: ConversationPagination.fromJson(data['pagination'] ?? {}),
    );
  }
}

class StudentConversationModel {
  final int id;
  final String type;
  final int? contextId;
  final String status;
  final int unreadMessagesCount;
  final ConversationLatestMessage? latestMessage;
  final List<ConversationUserModel> participants;
  final ConversationTaskAssignmentModel? taskAssignment;
  final String? createdAt;
  final String? updatedAt;

  StudentConversationModel({
    required this.id,
    required this.type,
    required this.contextId,
    required this.status,
    required this.unreadMessagesCount,
    required this.latestMessage,
    required this.participants,
    required this.taskAssignment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentConversationModel.fromJson(Map<String, dynamic> json) {
    return StudentConversationModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      type: json['type']?.toString() ?? '',
      contextId: json['context_id'] == null
          ? null
          : int.tryParse(json['context_id'].toString()),
      status: json['status']?.toString() ?? '',
      unreadMessagesCount:
          int.tryParse(json['unread_messages_count'].toString()) ?? 0,
      latestMessage: json['latest_message'] is Map<String, dynamic>
          ? ConversationLatestMessage.fromJson(json['latest_message'])
          : null,
      participants: (json['participants'] as List? ?? [])
          .map((item) => ConversationUserModel.fromJson(item))
          .toList(),
      taskAssignment: json['task_assignment'] is Map<String, dynamic>
          ? ConversationTaskAssignmentModel.fromJson(json['task_assignment'])
          : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
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
      unreadMessagesCount: unreadMessagesCount ?? this.unreadMessagesCount,
      latestMessage: latestMessage ?? this.latestMessage,
      participants: participants,
      taskAssignment: taskAssignment,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class ConversationTaskAssignmentModel {
  final int id;
  final String type;
  final String? title;

  ConversationTaskAssignmentModel({
    required this.id,
    required this.type,
    this.title,
  });

  factory ConversationTaskAssignmentModel.fromJson(Map<String, dynamic> json) {
    return ConversationTaskAssignmentModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      type: json['type']?.toString() ?? '',
      title:
          json['title']?.toString() ??
          json['task_title']?.toString() ??
          (json['task'] is Map<String, dynamic>
              ? json['task']['title']?.toString()
              : null),
    );
  }
}

class ConversationLatestMessage {
  final int id;
  final String content;
  final int? senderId;
  final String? createdAt;

  ConversationLatestMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
  });

  factory ConversationLatestMessage.fromJson(Map<String, dynamic> json) {
    final senderObject = json['sender'] is Map<String, dynamic>
        ? ConversationUserModel.fromJson(json['sender'])
        : null;

    final parsedSenderId = json['sender_id'] == null
        ? senderObject?.id
        : int.tryParse(json['sender_id'].toString());

    return ConversationLatestMessage(
      id: int.tryParse(json['id'].toString()) ?? 0,
      content: json['content']?.toString() ?? '',
      senderId: parsedSenderId,
      createdAt: json['created_at']?.toString(),
    );
  }
}

class ConversationMessageModel {
  final int id;
  final int conversationId;
  final int? senderId;
  final ConversationUserModel? sender;
  final String type;
  final String content;
  final String? readAt;
  final String? createdAt;
  final String? updatedAt;
  final bool isMine;

  ConversationMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.sender,
    required this.type,
    required this.content,
    required this.readAt,
    required this.createdAt,
    required this.updatedAt,
    required this.isMine,
  });

  factory ConversationMessageModel.fromJson(Map<String, dynamic> json) {
    final senderObject = json['sender'] is Map<String, dynamic>
        ? ConversationUserModel.fromJson(json['sender'])
        : null;

    final parsedSenderId = json['sender_id'] == null
        ? senderObject?.id
        : int.tryParse(json['sender_id'].toString());

    return ConversationMessageModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      conversationId: int.tryParse(json['conversation_id'].toString()) ?? 0,
      senderId: parsedSenderId,
      sender: senderObject,
      type: json['type']?.toString() ?? 'text',
      content: json['content']?.toString() ?? '',
      readAt: json['read_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      isMine: json['is_mine'] == true,
    );
  }

  ConversationMessageModel copyWith({
    int? id,
    int? conversationId,
    int? senderId,
    ConversationUserModel? sender,
    String? type,
    String? content,
    String? readAt,
    String? createdAt,
    String? updatedAt,
    bool? isMine,
  }) {
    return ConversationMessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      content: content ?? this.content,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isMine: isMine ?? this.isMine,
    );
  }
}

class ConversationUserModel {
  final int id;
  final String name;
  final String email;
  final String? profilePictureUrl;
  final String? bio;
  final dynamic isVerifiedByAdmin;
  final dynamic isActive;

  ConversationUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePictureUrl,
    this.bio,
    this.isVerifiedByAdmin,
    this.isActive,
  });

  factory ConversationUserModel.fromJson(Map<String, dynamic> json) {
    return ConversationUserModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'مستخدم',
      email: json['email']?.toString() ?? '',
      profilePictureUrl: json['profile_picture_url']?.toString(),
      bio: json['bio']?.toString(),
      isVerifiedByAdmin: json['is_verified_by_admin'],
      isActive: json['is_active'],
    );
  }
}

class ConversationPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  ConversationPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory ConversationPagination.fromJson(Map<String, dynamic> json) {
    return ConversationPagination(
      currentPage: int.tryParse(json['current_page'].toString()) ?? 1,
      lastPage: int.tryParse(json['last_page'].toString()) ?? 1,
      perPage: int.tryParse(json['per_page'].toString()) ?? 15,
      total: int.tryParse(json['total'].toString()) ?? 0,
    );
  }
}
