class VerifyEmailRequest {
  const VerifyEmailRequest({
    required this.email,
    required this.code,
  });

  final String email;
  final String code;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email,
      'code': code,
    };
  }

  Map<String, String> toFormBody() {
    return <String, String>{
      'email': email,
      'code': code,
    };
  }
}
