import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/features/authentication/model/verify_otp_request.dart';
import 'package:hawiisaac/features/authentication/model/verify_otp_response.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';

class VerifyOtpService {
  VerifyOtpService({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest requestData) async {
    final data = await _apiClient.postForm(
      url: ApiEndpoint.verifyOtp,
      body: <String, String>{
        'email': requestData.email,
        'otp_value': requestData.otpValue,
        'purpose': requestData.purpose,
      },
      logLabel: 'Verify OTP',
    );

    return VerifyOtpResponse.fromJson(data);
  }
}
