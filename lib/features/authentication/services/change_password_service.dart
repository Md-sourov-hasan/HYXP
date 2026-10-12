import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/model/auth_message_response.dart';
import 'package:hawiisaac/features/authentication/model/change_password_request.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';

class ChangePasswordService {
  ChangePasswordService({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Future<AuthMessageResponse> changePassword(
    ChangePasswordRequest requestData,
  ) async {
    if (!StorageService.hasAccessToken) {
      throw const AuthException(
        message: 'Please log in again to change your password.',
        statusCode: 401,
      );
    }

    final data = await _apiClient.postJson(
      url: ApiEndpoint.changePassword,
      body: requestData.toJson(),
      headers: <String, String>{
        HttpHeaders.authorizationHeader:
            'Bearer ${StorageService.accessToken}',
      },
      logLabel: 'Change Password',
      showDebugLog: true,
    );

    final response = AuthMessageResponse.fromJson(data);
    debugPrint('Change Password parsed message: ${response.message}');
    return response;
  }
}
