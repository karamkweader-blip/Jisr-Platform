class PortfolioProjectsResponse {
  final List<PortfolioProjectModel> data;

  PortfolioProjectsResponse({required this.data});

  factory PortfolioProjectsResponse.fromJson(Map<String, dynamic> json) {
    return PortfolioProjectsResponse(
      data: (json['data'] as List? ?? [])
          .map((e) => PortfolioProjectModel.fromJson(e))
          .toList(),
    );
  }
}

class PortfolioProjectResponse {
  final String? message;
  final PortfolioProjectModel data;

  PortfolioProjectResponse({this.message, required this.data});

  factory PortfolioProjectResponse.fromJson(Map<String, dynamic> json) {
    return PortfolioProjectResponse(
      message: json['message']?.toString(),
      data: PortfolioProjectModel.fromJson(json['data'] ?? {}),
    );
  }
}

class PortfolioProjectModel {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String projectUrl;
  final String source;
  final String? completionDate;
  final num? grade;
  final String? createdAt;
  final String? updatedAt;

  PortfolioProjectModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.projectUrl,
    required this.source,
    this.completionDate,
    this.grade,
    this.createdAt,
    this.updatedAt,
  });

  factory PortfolioProjectModel.fromJson(Map<String, dynamic> json) {
    return PortfolioProjectModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      projectUrl: json['project_url']?.toString() ?? '',
      source: json['source']?.toString() ?? 'manual',
      completionDate: json['completion_date']?.toString(),
      grade: num.tryParse(json['grade'].toString()),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
