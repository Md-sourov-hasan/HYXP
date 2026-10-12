import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/model/auth_message_response.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';

class LogoutService {
  LogoutService({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Future<AuthMessageResponse> logout() async {
    final refreshToken = StorageService.refreshToken;
    final accessToken = StorageService.accessToken;

    if (refreshToken.isEmpty && accessToken.isEmpty) {
      return const AuthMessageResponse(message: 'Logged out successfully.');
    }

    final headers = <String, String>{
      if (accessToken.isNotEmpty)
        HttpHeaders.authorizationHeader: 'Bearer $accessToken',
    };

    final data = await _apiClient.postJson(
      url: ApiEndpoint.logout,
      body: <String, dynamic>{'refresh': refreshToken},
      headers: headers,
      logLabel: 'Logout',
      showDebugLog: true,
    );

    final response = AuthMessageResponse.fromJson(data);
    debugPrint('Logout parsed message: ${response.message}');
    return response;
  }
}
