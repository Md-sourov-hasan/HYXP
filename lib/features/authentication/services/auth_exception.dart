class AuthException implements Exception {
  const AuthException({
    required this.message,
    required this.statusCode,
  });

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}
