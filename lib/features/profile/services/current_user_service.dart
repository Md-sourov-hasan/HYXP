import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/profile/model/current_user.dart';

class CurrentUserService {
  CurrentUserService({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Future<CurrentUser> getProfile() async {
    final data = await _apiClient.get(
      url: ApiEndpoint.profile,
      headers: _authHeaders,
      logLabel: 'Get User Profile',
      showDebugLog: true,
    );

    final user = CurrentUser.fromJson(data);
    debugPrint(
      'Get User Profile parsed: email=${user.email}, '
      'username=${user.username}, name=${user.displayName}, gender=${user.gender}, dob=${user.dob}',
    );
    return user;
  }

  Future<CurrentUser> getCurrentUser() async {
    return getProfile();
  }

  Future<CurrentUser> getUserById(String id) async {
    final data = await _apiClient.get(
      url: ApiEndpoint.userById(id),
      headers: _authHeaders,
      logLabel: 'Get User Detail',
      showDebugLog: true,
    );

    final user = CurrentUser.fromJson(data);
    debugPrint(
      'Get User Detail parsed: id=${user.id}, email=${user.email}, '
      'username=${user.username}, name=${user.displayName}',
    );
    return user;
  }

  Future<CurrentUser> updateProfile({
    required String username,
    required String name,
    required String bio,
    required String gender,
    DateTime? dob,
    String? photoPath,
  }) async {
    final fields = <String, String>{
      'username': username,
      'name': name,
      'bio': bio,
      if (gender.isNotEmpty) 'gender': gender.toLowerCase(),
    };
    final formattedDob = _formatDate(dob);
    if (formattedDob.isNotEmpty) {
      fields['date_of_birth'] = formattedDob;
    }

    final hasFile = photoPath != null &&
        photoPath.trim().isNotEmpty &&
        File(photoPath).existsSync();

    Map<String, dynamic> data;

    if (hasFile) {
      data = await _apiClient.patchMultipart(
        url: ApiEndpoint.profile,
        headers: _authHeaders,
        logLabel: 'Update Profile (Multipart)',
        showDebugLog: true,
        fields: fields,
        file: _buildPhotoPayload(photoPath, fieldName: 'profile_image'),
      );
    } else {
      try {
        data = await _apiClient.patchMultipart(
          url: ApiEndpoint.profile,
          headers: _authHeaders,
          logLabel: 'Update Profile (Multipart)',
          showDebugLog: true,
          fields: fields,
        );
      } catch (error) {
        debugPrint(
          'patchMultipart failed without image file ($error), trying patchJson fallback...',
        );
        data = await _apiClient.patchJson(
          url: ApiEndpoint.profile,
          body: fields,
          headers: _authHeaders,
          logLabel: 'Update Profile (JSON)',
          showDebugLog: true,
        );
      }
    }

    final user = CurrentUser.fromJson(data);
    debugPrint(
      'Update Profile parsed: username=${user.username}, name=${user.name}, '
      'gender=${user.gender}, dob=${user.dob}, photo=${user.effectivePhoto}',
    );
    return user;
  }

  Future<CurrentUser> updateUser({
    required String userId,
    required String username,
    required String firstName,
    required String lastName,
    DateTime? dob,
    String? photoPath,
  }) async {
    return updateProfile(
      username: username,
      name: '$firstName $lastName'.trim(),
      bio: '',
      gender: '',
      dob: dob,
      photoPath: photoPath,
    );
  }

  Future<String> deleteUser(String userId) async {
    final data = await _apiClient.delete(
      url: ApiEndpoint.userById(userId),
      headers: _authHeaders,
      logLabel: 'Delete User',
      showDebugLog: true,
    );

    final detail = data['detail']?.toString().trim() ?? '';
    return detail.isNotEmpty ? detail : 'User deleted successfully';
  }

  Map<String, String> get _authHeaders {
    if (!StorageService.hasAccessToken) {
      throw const AuthException(
        message: 'Please log in again to load your profile.',
        statusCode: 401,
      );
    }

    return <String, String>{
      HttpHeaders.authorizationHeader: 'Bearer ${StorageService.accessToken}',
    };
  }

  MultipartFilePayload? _buildPhotoPayload(
    String? photoPath, {
    String fieldName = 'profile_image',
  }) {
    if (photoPath == null || photoPath.trim().isEmpty) {
      return null;
    }

    final file = File(photoPath);
    if (!file.existsSync()) {
      return null;
    }

    return MultipartFilePayload(
      fieldName: fieldName,
      path: photoPath,
      fileName: file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : 'profile_image.jpg',
      contentType: _contentTypeFor(photoPath),
    );
  }

  String _contentTypeFor(String path) {
    final normalized = path.toLowerCase();
    if (normalized.endsWith('.png')) return 'image/png';
    if (normalized.endsWith('.webp')) return 'image/webp';
    if (normalized.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '';

    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
