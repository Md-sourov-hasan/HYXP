class VerifyOtpRequest {
  const VerifyOtpRequest({
    required this.email,
    required this.otpValue,
    required this.purpose,
  });

  final String email;
  final String otpValue;
  final String purpose;
}
