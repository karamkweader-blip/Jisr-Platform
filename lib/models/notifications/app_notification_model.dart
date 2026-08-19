class AppNotificationModel {
  final int id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final NotificationActorModel? actor;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const AppNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.actor,
    required this.isRead,
    required this.readAt,
    required this.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final rawActor = json['actor'];

    return AppNotificationModel(
      id: _asInt(json['id']),
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? 'إشعار جديد',
      body: json['body']?.toString() ?? '',
      data: rawData is Map
          ? Map<String, dynamic>.from(rawData)
          : const <String, dynamic>{},
      actor: rawActor is Map
          ? NotificationActorModel.fromJson(
              Map<String, dynamic>.from(rawActor),
            )
          : null,
      isRead: json['is_read'] == true,
      readAt: DateTime.tryParse(
        json['read_at']?.toString() ?? '',
      ),
      createdAt: DateTime.tryParse(
            json['created_at']?.toString() ?? '',
          ) ??
          DateTime.now().toUtc(),
    );
  }

  AppNotificationModel copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return AppNotificationModel(
      id: id,
      type: type,
      title: title,
      body: body,
      data: data,
      actor: actor,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
    );
  }

  bool get isRecent {
    final difference = DateTime.now().toUtc().difference(
          createdAt.toUtc(),
        );

    return difference < const Duration(hours: 1);
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class NotificationActorModel {
  final int id;
  final String name;

  const NotificationActorModel({
    required this.id,
    required this.name,
  });

  factory NotificationActorModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return NotificationActorModel(
      id: AppNotificationModel._asInt(json['id']),
      name: json['name']?.toString() ?? '',
    );
  }
}