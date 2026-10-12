import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/features/authentication/model/send_otp_request.dart';
import 'package:hawiisaac/features/authentication/model/send_otp_response.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';

class SendOtpService {
  SendOtpService({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Future<SendOtpResponse> sendOtp(SendOtpRequest requestData) async {
    final data = await _apiClient.postForm(
      url: ApiEndpoint.sendOtp,
      body: <String, String>{
        'email': requestData.email,
        'purpose': requestData.purpose,
      },
      logLabel: 'Send OTP',
    );

    return SendOtpResponse.fromJson(data);
  }
}
