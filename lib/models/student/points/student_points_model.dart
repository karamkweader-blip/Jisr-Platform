class StudentPointsSummaryResponse {
  final bool status;
  final String message;
  final int totalPoints;

  StudentPointsSummaryResponse({
    required this.status,
    required this.message,
    required this.totalPoints,
  });

  factory StudentPointsSummaryResponse.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] ?? {});
    return StudentPointsSummaryResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      totalPoints: _toInt(data['total_points']),
    );
  }
}

class StudentPointsHistoryResponse {
  final bool status;
  final String message;
  final List<StudentPointRecord> records;
  final StudentPointsMeta meta;

  StudentPointsHistoryResponse({
    required this.status,
    required this.message,
    required this.records,
    required this.meta,
  });

  factory StudentPointsHistoryResponse.fromJson(Map<String, dynamic> json) {
    return StudentPointsHistoryResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      records: ((json['data'] as List?) ?? [])
          .map((item) => StudentPointRecord.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      meta: StudentPointsMeta.fromJson(Map<String, dynamic>.from(json['meta'] ?? {})),
    );
  }
}

class StudentPointsMeta {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  StudentPointsMeta({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;

  factory StudentPointsMeta.fromJson(Map<String, dynamic> json) {
    return StudentPointsMeta(
      currentPage: _toInt(json['current_page'], fallback: 1),
      perPage: _toInt(json['per_page'], fallback: 10),
      total: _toInt(json['total']),
      lastPage: _toInt(json['last_page'], fallback: 1),
    );
  }

  factory StudentPointsMeta.empty() {
    return StudentPointsMeta(currentPage: 1, perPage: 10, total: 0, lastPage: 1);
  }
}

class StudentPointRecord {
  final int id;
  final int points;
  final String? actionType;
  final String category;
  final String description;
  final StudentPointReference? reference;
  final DateTime? createdAt;

  StudentPointRecord({
    required this.id,
    required this.points,
    required this.actionType,
    required this.category,
    required this.description,
    required this.reference,
    required this.createdAt,
  });

  factory StudentPointRecord.fromJson(Map<String, dynamic> json) {
    final rawReference = json['reference'];
    return StudentPointRecord(
      id: _toInt(json['id']),
      points: _toInt(json['points']),
      actionType: json['action_type']?.toString(),
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      reference: rawReference == null
          ? null
          : StudentPointReference.fromJson(Map<String, dynamic>.from(rawReference)),
      createdAt: _date(json['created_at']),
    );
  }

  String get arabicDescription {
    final text = description.trim();

    if (text == 'Created a community post.') {
      return 'أنشأت منشورًا في المجتمع التقني';
    }
    if (text == 'Created a community comment.') {
      return 'أضفت تعليقًا في المجتمع التقني';
    }

    final postLike = RegExp(r'^Received a like from user (.+)\.$').firstMatch(text);
    if (postLike != null) {
      return 'حصل منشورك على إعجاب من ${postLike.group(1)}';
    }

    final commentLike = RegExp(r'^Received a like on comment from user (.+)\.$').firstMatch(text);
    if (commentLike != null) {
      return 'حصل تعليقك على إعجاب من ${commentLike.group(1)}';
    }

    return text.isEmpty ? 'نشاط جديد في المنصة' : text;
  }

  String get arabicCategory {
    switch (category.toLowerCase()) {
      case 'community':
        return 'المجتمع التقني';
      default:
        return category.isEmpty ? 'عام' : category;
    }
  }

  String get referenceTitle {
    final type = reference?.type ?? '';
    switch (type.toLowerCase()) {
      case 'post':
        return 'منشور';
      case 'postlike':
        return 'إعجاب منشور';
      case 'comment':
        return 'تعليق';
      case 'commentlike':
        return 'إعجاب تعليق';
      default:
        return type.isEmpty ? 'مرجع' : type;
    }
  }
}

class StudentPointReference {
  final String type;
  final int id;

  StudentPointReference({required this.type, required this.id});

  factory StudentPointReference.fromJson(Map<String, dynamic> json) {
    return StudentPointReference(
      type: json['type']?.toString() ?? '',
      id: _toInt(json['id']),
    );
  }
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
