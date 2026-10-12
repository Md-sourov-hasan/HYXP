import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/features/authentication/model/auth_token_response.dart';
import 'package:hawiisaac/features/authentication/model/login_request.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';

class LoginService {
  LoginService({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Future<AuthTokenResponse> login(LoginRequest requestData) async {
    final data = await _apiClient.postJson(
      url: ApiEndpoint.login,
      body: <String, dynamic>{
        'email': requestData.email,
        'password': requestData.password,
      },
      logLabel: 'Login',
    );

    return AuthTokenResponse.fromJson(data);
  }
}
