class VerifyOtpResponse {
  const VerifyOtpResponse({
    required this.status,
    required this.sessionKey,
  });

  final String status;
  final String sessionKey;

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      status: json['status']?.toString() ?? '',
      sessionKey: json['sessionKey']?.toString() ?? '',
    );
  }
}
