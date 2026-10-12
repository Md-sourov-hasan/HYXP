import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/features/authentication/model/auth_message_response.dart';
import 'package:hawiisaac/features/authentication/model/signup_request.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';

class SignupService {
  SignupService({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Future<AuthMessageResponse> signup(SignupRequest requestData) async {
    debugPrint(
      'Signup request: email=${requestData.email}, username=${requestData.username}, '
      'gender=${requestData.gender}, date_of_birth=${requestData.dateOfBirth}',
    );
    final data = await _apiClient.postJson(
      url: ApiEndpoint.signup,
      body: requestData.toJson(),
      logLabel: 'Signup',
    );

    final response = AuthMessageResponse.fromJson(data);
    debugPrint('Signup response parsed: message/detail=${response.message}');
    return response;
  }
}
