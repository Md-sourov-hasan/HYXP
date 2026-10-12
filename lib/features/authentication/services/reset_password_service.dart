import 'dart:io';

import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/model/auth_message_response.dart';
import 'package:hawiisaac/features/authentication/model/forgot_password_reset_request.dart';
import 'package:hawiisaac/features/authentication/model/reset_password_request.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';

class ResetPasswordService {
  ResetPasswordService({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Future<AuthMessageResponse> resetPasswordWithCode(
    ForgotPasswordResetRequest requestData,
  ) async {
    final data = await _apiClient.postJson(
      url: ApiEndpoint.resetPassword,
      body: requestData.toJson(),
      logLabel: 'Reset Password',
    );

    return AuthMessageResponse.fromJson(data);
  }

  Future<AuthMessageResponse> resetPassword(
    ResetPasswordRequest requestData,
  ) async {
    if (!StorageService.hasAuthTokens) {
      throw const AuthException(
        message: 'Please log in again to change your password.',
        statusCode: 401,
      );
    }

    final data = await _apiClient.postForm(
      url: ApiEndpoint.resetPassword,
      body: <String, String>{
        'old_password': requestData.oldPassword,
        'new_password': requestData.newPassword,
      },
      headers: <String, String>{
        'refresh-token': StorageService.refreshToken,
        HttpHeaders.authorizationHeader:
            'Bearer ${StorageService.accessToken}',
      },
      logLabel: 'Reset Password',
    );

    return AuthMessageResponse.fromJson(data);
  }
}
