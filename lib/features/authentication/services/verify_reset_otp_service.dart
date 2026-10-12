import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/features/authentication/model/auth_message_response.dart';
import 'package:hawiisaac/features/authentication/model/verify_reset_otp_request.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';

class VerifyResetOtpService {
  VerifyResetOtpService({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Future<AuthMessageResponse> verifyResetOtp(
    VerifyResetOtpRequest requestData,
  ) async {
    debugPrint(
      'VerifyResetOtp request: email=${requestData.email}, code=${requestData.code}',
    );
    final data = await _apiClient.postJson(
      url: ApiEndpoint.verifyResetOtp,
      body: requestData.toJson(),
      logLabel: 'Verify Reset OTP',
    );

    final response = AuthMessageResponse.fromJson(data);
    debugPrint('VerifyResetOtp response parsed: message=${response.message}');
    return response;
  }
}
