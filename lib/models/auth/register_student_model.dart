class RegisterStudentModel {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String role;

  RegisterStudentModel({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'role': role,
    };
  }
}
