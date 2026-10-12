class AuthTokenResponse {
  const AuthTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    this.message = '',
    this.username = '',
    this.role = '',
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String message;
  final String username;
  final String role;

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponse(
      accessToken: json['access']?.toString() ??
          json['access_token']?.toString() ??
          '',
      refreshToken: json['refresh']?.toString() ??
          json['refresh_token']?.toString() ??
          '',
      tokenType: json['token_type']?.toString() ?? 'bearer',
      message: json['message']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }
}
