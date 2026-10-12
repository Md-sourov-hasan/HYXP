class AuthMessageResponse {
  const AuthMessageResponse({required this.message});

  final String message;

  factory AuthMessageResponse.fromJson(Map<String, dynamic> json) {
    return AuthMessageResponse(
      message: json['message']?.toString() ?? json['detail']?.toString() ?? '',
    );
  }
}
