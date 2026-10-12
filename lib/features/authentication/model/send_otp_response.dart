class SendOtpResponse {
  const SendOtpResponse({
    required this.status,
    required this.message,
    required this.purpose,
  });

  final String status;
  final String message;
  final String purpose;

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
    );
  }
}
