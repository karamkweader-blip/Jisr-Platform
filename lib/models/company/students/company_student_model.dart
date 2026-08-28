class CompanyStudentModel {
  final int id;
  final String name;
  final String email;
  final String? profilePictureUrl;

  const CompanyStudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
  });

  factory CompanyStudentModel.fromJson(Map<String, dynamic> json) {
    return CompanyStudentModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString().trim() ?? '',
      email: json['email']?.toString().trim() ?? '',
      profilePictureUrl: _nullableString(
        json['profile_picture_url'],
      ),
    );
  }
}

class CompanyStudentPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const CompanyStudentPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory CompanyStudentPagination.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyStudentPagination(
      currentPage: _parseInt(
        json['current_page'],
        fallback: 1,
      ),
      lastPage: _parseInt(
        json['last_page'],
        fallback: 1,
      ),
      perPage: _parseInt(
        json['per_page'],
        fallback: 10,
      ),
      total: _parseInt(json['total']),
    );
  }
}

class CompanyStudentSearchResult {
  final List<CompanyStudentModel> students;
  final CompanyStudentPagination pagination;

  const CompanyStudentSearchResult({
    required this.students,
    required this.pagination,
  });

  factory CompanyStudentSearchResult.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawStudents = json['students'];
    final rawPagination = json['pagination'];

    return CompanyStudentSearchResult(
      students: rawStudents is List
          ? rawStudents
              .whereType<Map>()
              .map(
                (item) => CompanyStudentModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .where((student) => student.id > 0)
              .toList()
          : const <CompanyStudentModel>[],
      pagination: CompanyStudentPagination.fromJson(
        rawPagination is Map
            ? Map<String, dynamic>.from(rawPagination)
            : const <String, dynamic>{},
      ),
    );
  }
}

class CompanyStudentFilterSkill {
  final int id;
  final String name;
  final String category;

  const CompanyStudentFilterSkill({
    required this.id,
    required this.name,
    required this.category,
  });

  factory CompanyStudentFilterSkill.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyStudentFilterSkill(
      id: _parseInt(json['id']),
      name: json['name']?.toString().trim() ?? '',
      category: json['category']?.toString().trim() ?? '',
    );
  }
}

int _parseInt(
  Object? value, {
  int fallback = 0,
}) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

String? _nullableString(Object? value) {
  final normalized = value?.toString().trim();

  return normalized == null || normalized.isEmpty
      ? null
      : normalized;
}