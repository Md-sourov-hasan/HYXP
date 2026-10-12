import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/model/auth_message_response.dart';
import 'package:hawiisaac/features/authentication/model/user_preference.dart';
import 'package:hawiisaac/features/authentication/model/user_preference_request.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';

class UserPreferenceService {
  UserPreferenceService({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Future<UserPreference> updateUnits(
    UserPreferenceRequest requestData,
  ) async {
    final data = await _apiClient.putJson(
      url: ApiEndpoint.authUnits,
      body: requestData.toJson(),
      headers: _authHeaders,
      logLabel: 'Update Units Preference',
      showDebugLog: true,
    );

    final preference = UserPreference.fromJson(data);
    debugPrint(
      'Update Units Preference parsed: ${_debugPreference(preference)}',
    );
    return preference;
  }

  Future<UserPreference> createPreference(
    UserPreferenceRequest requestData,
  ) async {
    return updateUnits(requestData);
  }

  Future<UserPreference> getPreference() async {
    final data = await _apiClient.get(
      url: ApiEndpoint.authUnits,
      headers: _authHeaders,
      logLabel: 'Get User Preference',
      showDebugLog: true,
    );

    final preference = UserPreference.fromJson(data);
    debugPrint('Get User Preference parsed: ${_debugPreference(preference)}');
    return preference;
  }

  Future<UserPreference> updatePreference(
    UserPreferenceRequest requestData,
  ) async {
    return updateUnits(requestData);
  }

  Future<AuthMessageResponse> deletePreference() async {
    final data = await _apiClient.delete(
      url: ApiEndpoint.authUnits,
      headers: _authHeaders,
      logLabel: 'Delete User Preference',
      showDebugLog: true,
    );

    final response = AuthMessageResponse.fromJson(data);
    debugPrint('Delete User Preference parsed: ${response.message}');
    return response;
  }

  Map<String, String> get _authHeaders {
    if (!StorageService.hasAccessToken) {
      throw const AuthException(
        message: 'Please log in again to update your preferences.',
        statusCode: 401,
      );
    }

    return <String, String>{
      'Content-Type': 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${StorageService.accessToken}',
    };
  }

  String _debugPreference(UserPreference preference) {
    return 'weight=${preference.weight}, distance=${preference.distance}, '
        'bodyMeasurements=${preference.bodyMeasurements}';
  }
}
