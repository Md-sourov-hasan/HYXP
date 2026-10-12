class SignupRequest {
  const SignupRequest({
    required this.email,
    required this.password,
    required this.username,
    required this.gender,
    required this.dateOfBirth,
  });

  final String email;
  final String password;
  final String username;
  final String gender;
  final String dateOfBirth;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'email': email,
      'password': password,
      'username': username,
    };
    if (gender.trim().isNotEmpty) {
      map['gender'] = gender.trim();
    }
    if (dateOfBirth.trim().isNotEmpty &&
        RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateOfBirth.trim())) {
      map['date_of_birth'] = dateOfBirth.trim();
    }
    return map;
  }

  Map<String, String> toFormBody() {
    final map = <String, String>{
      'email': email,
      'password': password,
      'username': username,
    };
    if (gender.trim().isNotEmpty) {
      map['gender'] = gender.trim();
    }
    if (dateOfBirth.trim().isNotEmpty &&
        RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateOfBirth.trim())) {
      map['date_of_birth'] = dateOfBirth.trim();
    }
    return map;
  }
}
