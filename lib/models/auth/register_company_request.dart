class RegisterCompanyRequest {
  final String name;
  final String email;
  final String password;
  final String location;
  final String industry;
  final String role;
  final String? website;
  final String documentationFilePath;

  RegisterCompanyRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.location,
    required this.industry,
    required this.documentationFilePath,
    this.website,
    this.role = 'company',
  });

  Map<String, String> toFields() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'location': location,
      'industry': industry,
      'role': role,
      if (website != null && website!.isNotEmpty) 'website': website!,
    };
  }
}