class CompanyProfileModel {
  final int id;
  final String industry;
  final String location;
  final String website;
  final String documentationFile;
  final List<CompanyProfileUserModel> users;

  const CompanyProfileModel({
    required this.id,
    required this.industry,
    required this.location,
    required this.website,
    required this.documentationFile,
    required this.users,
  });

  factory CompanyProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return CompanyProfileModel(
      id: data['id'] as int? ?? 0,
      industry: data['industry'] as String? ?? '',
      location: data['location'] as String? ?? '',
      website: data['website'] as String? ?? '',
      documentationFile: data['documentation_file'] as String? ?? '',
      users: (data['users'] as List? ?? [])
          .map(
            (item) => CompanyProfileUserModel.fromJson(
              item as Map<String, dynamic>? ?? {},
            ),
          )
          .toList(),
    );
  }

  CompanyProfileUserModel? get primaryUser {
    if (users.isEmpty) return null;
    return users.first;
  }
}

class CompanyProfileUserModel {
  final int id;
  final String name;
  final String email;
  final String verificationStatus;
  final String? profilePictureUrl;
  final String? bio;
  final bool isActive;

  const CompanyProfileUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.verificationStatus,
    required this.profilePictureUrl,
    required this.bio,
    required this.isActive,
  });

  factory CompanyProfileUserModel.fromJson(Map<String, dynamic> json) {
    return CompanyProfileUserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      verificationStatus: json['is_verified_by_admin'] as String? ?? '',
      profilePictureUrl: json['profile_picture_url'] as String?,
      bio: json['bio'] as String?,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  bool get isVerified => verificationStatus == 'accepted';
}