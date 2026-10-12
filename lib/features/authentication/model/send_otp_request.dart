class SendOtpRequest {
  const SendOtpRequest({
    required this.email,
    required this.purpose,
  });

  final String email;
  final String purpose;
}
