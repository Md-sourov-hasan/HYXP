import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/features/authentication/model/auth_message_response.dart';
import 'package:hawiisaac/features/authentication/model/verify_email_request.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';

class VerifyEmailService {
  VerifyEmailService({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Future<AuthMessageResponse> verifyEmail(VerifyEmailRequest requestData) async {
    debugPrint(
      'VerifyEmail request: email=${requestData.email}, code=${requestData.code}',
    );
    final data = await _apiClient.postJson(
      url: ApiEndpoint.verifyEmail,
      body: requestData.toJson(),
      logLabel: 'Verify Email',
    );

    final response = AuthMessageResponse.fromJson(data);
    debugPrint('VerifyEmail response parsed: message=${response.message}');
    return response;
  }
}
