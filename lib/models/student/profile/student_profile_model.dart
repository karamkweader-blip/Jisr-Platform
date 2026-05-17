class StudentProfileResponse {
  final StudentProfileModel data;

  StudentProfileResponse({required this.data});

  factory StudentProfileResponse.fromJson(Map<String, dynamic> json) {
    return StudentProfileResponse(
      data: StudentProfileModel.fromJson(json['data'] ?? {}),
    );
  }
}

class StudentProfileModel {
  final int id;
  final ProfileUserModel user;
  final String? university;
  final String? major;
  final String? graduationYear;
  final String? phone;
  final String? createdAt;
  final String? updatedAt;

  StudentProfileModel({
    required this.id,
    required this.user,
    this.university,
    this.major,
    this.graduationYear,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      user: ProfileUserModel.fromJson(json['user'] ?? {}),
      university: json['university']?.toString(),
      major: json['major']?.toString(),
      graduationYear: json['graduation_year']?.toString(),
      phone: json['phone']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class ProfileUserModel {
  final int id;
  final String name;
  final String email;
  final String verificationStatus;
  final String? profilePictureUrl;
  final String? bio;
  final int isActive;

  ProfileUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.verificationStatus,
    this.profilePictureUrl,
    this.bio,
    required this.isActive,
  });

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      verificationStatus: json['is_verified_by_admin']?.toString() ?? '',
      profilePictureUrl: json['profile_picture_url']?.toString(),
      bio: json['bio']?.toString(),
      isActive: int.tryParse(json['is_active'].toString()) ?? 0,
    );
  }
}
