class VerifyResetOtpRequest {
  const VerifyResetOtpRequest({
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
}
