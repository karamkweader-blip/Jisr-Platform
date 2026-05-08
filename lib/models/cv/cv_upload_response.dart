class CvUploadResponse {
  final int cvId;
  final String fileUrl;
  final bool isPrimary;
  final String message;

  CvUploadResponse({
    required this.cvId,
    required this.fileUrl,
    required this.isPrimary,
    required this.message,
  });

  factory CvUploadResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return CvUploadResponse(
      message: json['message'] ?? '',
      cvId: data['cv_id'],
      fileUrl: data['file_url'],
      isPrimary: data['is_primary'],
    );
  }
}
