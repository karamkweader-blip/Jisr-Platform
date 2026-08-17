class StudentInterviewsResponse {
  final bool status;
  final String message;
  final List<StudentInterviewModel> data;

  const StudentInterviewsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StudentInterviewsResponse.fromJson(Map<String, dynamic> json) {
    return StudentInterviewsResponse(
      status: json['status'] == true || json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: _InterviewJson.mapList(json['data'])
          .map(StudentInterviewModel.fromJson)
          .toList(),
    );
  }
}

class StudentInterviewModel {
  final int id;
  final StudentInterviewApplication application;
  final StudentInterviewOpportunity opportunity;
  final StudentInterviewCompany company;
  final DateTime? scheduledAt;
  final String meetingType;
  final String? meetingLink;
  final String? location;
  final String status;
  final bool hasPassed;
  final String displayStatus;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StudentInterviewModel({
    required this.id,
    required this.application,
    required this.opportunity,
    required this.company,
    required this.scheduledAt,
    required this.meetingType,
    required this.meetingLink,
    required this.location,
    required this.status,
    required this.hasPassed,
    required this.displayStatus,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentInterviewModel.fromJson(Map<String, dynamic> json) {
    return StudentInterviewModel(
      id: _InterviewJson.toInt(json['id']),
      application: StudentInterviewApplication.fromJson(
        _InterviewJson.map(json['application']),
      ),
      opportunity: StudentInterviewOpportunity.fromJson(
        _InterviewJson.map(json['opportunity']),
      ),
      company: StudentInterviewCompany.fromJson(
        _InterviewJson.map(json['company']),
      ),
      scheduledAt: _InterviewJson.date(json['scheduled_at']),
      meetingType: json['meeting_type']?.toString() ?? '',
      meetingLink: _InterviewJson.nullableString(json['meeting_link']),
      location: _InterviewJson.nullableString(json['location']),
      status: json['status']?.toString().toLowerCase() ?? '',
      hasPassed: _InterviewJson.toBool(json['has_passed']),
      displayStatus: json['display_status']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      createdAt: _InterviewJson.date(json['created_at']),
      updatedAt: _InterviewJson.date(json['updated_at']),
    );
  }

  bool get isActiveStatus => status == 'scheduled' || status == 'rescheduled';

  bool get isUpcoming => isActiveStatus && !hasPassed;

  bool get isHistory {
    return status == 'completed' ||
        status == 'cancelled' ||
        (isActiveStatus && hasPassed);
  }

  bool get canJoinOnlineMeeting {
    return isUpcoming &&
        meetingType == 'online' &&
        meetingLink != null &&
        meetingLink!.isNotEmpty;
  }
}

class StudentInterviewApplication {
  final int id;
  final String status;

  const StudentInterviewApplication({
    required this.id,
    required this.status,
  });

  factory StudentInterviewApplication.fromJson(Map<String, dynamic> json) {
    return StudentInterviewApplication(
      id: _InterviewJson.toInt(json['id']),
      status: json['status']?.toString() ?? '',
    );
  }
}

class StudentInterviewOpportunity {
  final int id;
  final String title;
  final String type;
  final String status;

  const StudentInterviewOpportunity({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
  });

  factory StudentInterviewOpportunity.fromJson(Map<String, dynamic> json) {
    return StudentInterviewOpportunity(
      id: _InterviewJson.toInt(json['id']),
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

class StudentInterviewCompany {
  final int id;
  final String name;
  final String industry;

  const StudentInterviewCompany({
    required this.id,
    required this.name,
    required this.industry,
  });

  factory StudentInterviewCompany.fromJson(Map<String, dynamic> json) {
    return StudentInterviewCompany(
      id: _InterviewJson.toInt(json['id']),
      name: json['name']?.toString().trim() ?? '',
      industry: json['industry']?.toString().trim() ?? '',
    );
  }
}

class _InterviewJson {
  static int toInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool toBool(dynamic value) {
    if (value is bool) return value;
    return value == 1 || value?.toString().toLowerCase() == 'true';
  }

  static DateTime? date(dynamic value) {
    final text = nullableString(value);
    return text == null ? null : DateTime.tryParse(text);
  }

  static String? nullableString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }

  static Map<String, dynamic> map(dynamic value) {
    return value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
  }

  static List<Map<String, dynamic>> mapList(dynamic value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }
}
