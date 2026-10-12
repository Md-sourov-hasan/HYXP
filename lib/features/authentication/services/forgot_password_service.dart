import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/features/authentication/model/auth_message_response.dart';
import 'package:hawiisaac/features/authentication/model/forgot_password_request.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';

class ForgotPasswordService {
  ForgotPasswordService({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Future<AuthMessageResponse> sendForgotPasswordCode(String email) async {
    final data = await _apiClient.postJson(
      url: ApiEndpoint.forgotPassword,
      body: <String, dynamic>{'email': email},
      logLabel: 'Forgot Password',
    );

    return AuthMessageResponse.fromJson(data);
  }

  Future<AuthMessageResponse> forgotPassword(
    ForgotPasswordRequest requestData,
  ) async {
    final data = await _apiClient.postForm(
      url: ApiEndpoint.forgotPassword,
      body: <String, String>{
        'email': requestData.email,
        'password': requestData.password,
        'session_key': requestData.sessionKey,
      },
      logLabel: 'Forgot Password',
    );

    return AuthMessageResponse.fromJson(data);
  }
}
