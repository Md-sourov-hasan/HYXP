import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/home/model/content_item.dart';
import 'package:hawiisaac/features/sessions/model/session_models.dart';

class ContentApiService {
  ContentApiService({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Future<List<ContentItem>> getContents({
    bool isActive = true,
    String? feed,
    int offset = 0,
    int? limit,
  }) async {
    final data = await _apiClient.getList(
      url: ApiEndpoint.contents(
        isActive: isActive,
        feed: feed,
        offset: offset,
        limit: limit,
      ),
      logLabel: 'Get Contents',
      headers: _optionalAuthHeaders,
      showDebugLog: true,
    );
    final contents = _parseList(data, ContentItem.fromJson);
    debugPrint('Get Contents parsed count: ${contents.length}');
    return contents;
  }

  Future<ContentItem> getContentById(int id) async {
    final data = await _apiClient.get(
      url: ApiEndpoint.contentById(id),
      logLabel: 'Get Content Detail',
      headers: _optionalAuthHeaders,
      showDebugLog: true,
    );
    final content = ContentItem.fromJson(data);
    debugPrint(
      'Get Content Detail parsed: id=${content.id}, title=${content.title}',
    );
    return content;
  }

  Future<ContentBookmarkResult> addBookmark(int id) async {
    final data = await _apiClient.requestJson(
      method: 'POST',
      url: ApiEndpoint.contentBookmarks(id),
      logLabel: 'Add Content Bookmark',
      headers: _authHeaders,
      showDebugLog: true,
    );

    if (data is Map<String, dynamic>) {
      return ContentBookmarkResult.fromJson(data);
    }

    throw const AuthException(
      message: 'Invalid response received from the server.',
      statusCode: 0,
    );
  }

  Future<ContentBookmarkResult> removeBookmark(int id) async {
    final data = await _apiClient.requestJson(
      method: 'DELETE',
      url: ApiEndpoint.contentBookmarks(id),
      logLabel: 'Remove Content Bookmark',
      headers: _authHeaders,
      showDebugLog: true,
    );

    if (data is Map<String, dynamic>) {
      return ContentBookmarkResult.fromJson(data);
    }

    throw const AuthException(
      message: 'Invalid response received from the server.',
      statusCode: 0,
    );
  }

  Future<ContentBookmarkCount> getBookmarkCount(int id) async {
    final data = await _apiClient.get(
      url: ApiEndpoint.contentBookmarkCount(id),
      logLabel: 'Get Content Bookmark Count',
      headers: _optionalAuthHeaders,
      showDebugLog: true,
    );
    return ContentBookmarkCount.fromJson(data);
  }

  Future<ContentStartLogResponse> startContentLog(int id) async {
    final url = ApiEndpoint.contentStartLog(id);
    debugPrint('[API HIT][POST] /content/contents/$id/start-log -> $url');

    final data = await _apiClient.requestJson(
      method: 'POST',
      url: url,
      logLabel: 'Start Content Log',
      headers: _authHeaders,
      showDebugLog: true,
    );

    if (data is Map<String, dynamic>) {
      final response = ContentStartLogResponse.fromJson(data);
      debugPrint(
        'Start Content Log parsed: '
        'sessionId=${response.session.id}, '
        'firstSessionWorkoutId=${response.firstSessionWorkout.id}, '
        'workouts=${response.session.workouts.length}',
      );
      return response;
    }

    throw const AuthException(
      message: 'Invalid response received from the server.',
      statusCode: 0,
    );
  }

  Map<String, String> get _optionalAuthHeaders {
    if (StorageService.accessToken.isEmpty) {
      return const <String, String>{};
    }

    return <String, String>{
      HttpHeaders.authorizationHeader: 'Bearer ${StorageService.accessToken}',
    };
  }

  Map<String, String> get _authHeaders {
    if (StorageService.accessToken.isEmpty) {
      throw const AuthException(
        message: 'Please log in again to update bookmarks.',
        statusCode: 401,
      );
    }

    return _optionalAuthHeaders;
  }

  List<T> _parseList<T>(
    List<dynamic> data,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    return data
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList(growable: false);
  }
}
