class ForgotPasswordRequest {
  const ForgotPasswordRequest({
    required this.email,
    required this.password,
    required this.sessionKey,
  });

  final String email;
  final String password;
  final String sessionKey;
}
