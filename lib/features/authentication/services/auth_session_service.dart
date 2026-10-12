import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/model/auth_token_response.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';

class AuthSessionService {
  AuthSessionService({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Future<AuthTokenResponse> verifyToken() async {
    if (!StorageService.hasRefreshToken) {
      debugPrint('Auto login skipped: no saved refresh token');
      throw const AuthException(
        message: 'Please log in again.',
        statusCode: 401,
      );
    }

    debugPrint(
      'Auto login verify-token request: refresh=${_tokenPreview(StorageService.refreshToken)}, '
      'access=${_tokenPreview(StorageService.accessToken)}',
    );
    final headers = <String, String>{
      'refresh-token': StorageService.refreshToken,
    };
    if (StorageService.hasAccessToken) {
      headers[HttpHeaders.authorizationHeader] =
          'Bearer ${StorageService.accessToken}';
    }

    final data = await _apiClient.get(
      url: ApiEndpoint.verifyToken,
      headers: headers,
      logLabel: 'Verify Token',
      showDebugLog: true,
    );

    final newTokens = data['new_tokens'];
    if (newTokens is Map<String, dynamic>) {
      final tokens = AuthTokenResponse.fromJson(newTokens);
      if (tokens.accessToken.isEmpty || tokens.refreshToken.isEmpty) {
        debugPrint('Auto login verify-token failed: empty new token received');
        throw const AuthException(
          message: 'Invalid token response received from the server.',
          statusCode: 0,
        );
      }

      debugPrint(
        'Auto login verify-token success: newAccess=${_tokenPreview(tokens.accessToken)}, '
        'newRefresh=${_tokenPreview(tokens.refreshToken)}',
      );
      return tokens;
    }

    debugPrint('Auto login verify-token failed: new_tokens missing');
    throw const AuthException(
      message: 'Invalid token response received from the server.',
      statusCode: 0,
    );
  }

  String _tokenPreview(String token) {
    if (token.isEmpty) return 'empty';
    if (token.length <= 12) return 'len=${token.length}';

    return '${token.substring(0, 6)}...${token.substring(token.length - 6)} '
        '(len=${token.length})';
  }
}
