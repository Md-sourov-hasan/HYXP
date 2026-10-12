import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/core/services/storage_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/sessions/model/session_models.dart';

class SessionApiService {
  SessionApiService({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Future<WorkoutSession> createSession(CreateSessionRequest requestData) async {
    final data = await _apiClient.postJson(
      url: ApiEndpoint.sessions,
      body: requestData.toJson(),
      headers: _authHeaders,
      logLabel: 'Create Session',
      showDebugLog: true,
    );
    final session = WorkoutSession.fromJson(data);
    debugPrint(
      'Create Session parsed: id=${session.id}, date=${requestData.date}',
    );
    return session;
  }

  Future<List<WorkoutSession>> getSessions({
    int offset = 0,
    int limit = 20,
  }) async {
    final userId = _currentUserId;
    final data = await _apiClient.getList(
      url: ApiEndpoint.sessionsList(
        userId: userId,
        offset: offset,
        limit: limit,
      ),
      headers: _authHeaders,
      logLabel: 'Get Sessions',
      showDebugLog: true,
    );
    final sessions = _parseList(data, WorkoutSession.fromJson);
    debugPrint('Get Sessions parsed count: ${sessions.length}');
    return sessions;
  }

  Future<ActiveWorkoutSession> getActiveSession() async {
    final data = await _apiClient.get(
      url: ApiEndpoint.activeSession(),
      headers: _authHeaders,
      logLabel: 'Get Active Session',
      showDebugLog: true,
    );
    final sessionJson = data['session'];
    final session = ActiveWorkoutSession.fromJson(
      sessionJson is Map<String, dynamic> ? sessionJson : <String, dynamic>{},
    );
    debugPrint(
      'Get Active Session parsed: id=${session.id}, workouts=${session.workouts.length}',
    );
    return session;
  }

  Future<ActiveWorkoutSession> getSessionById(int id) async {
    final data = await _apiClient.get(
      url: ApiEndpoint.sessionById(id),
      headers: _authHeaders,
      logLabel: 'GET /sessions/sessions/{sessionId}',
      showDebugLog: true,
    );
    final session = ActiveWorkoutSession.fromJson(data);
    debugPrint(
      'GET /sessions/sessions/{sessionId} parsed: '
      'sessionId=${session.id}, workouts=${session.workouts.length}',
    );
    return session;
  }

  Future<WorkoutStartLogResponse> startWorkoutLog(int workoutId) async {
    final url = ApiEndpoint.workoutStartLog(workoutId);
    debugPrint(
      '[API HIT][POST] /equipments/workout/$workoutId/start-log -> $url',
    );

    final data = await _apiClient.requestJson(
      method: 'POST',
      url: url,
      headers: _progressHeaders,
      logLabel: 'POST /workouts/{workoutId}/start-log',
      showDebugLog: true,
    );

    if (data is Map<String, dynamic>) {
      final response = WorkoutStartLogResponse.fromJson(data);
      debugPrint(
        'POST /workouts/{workoutId}/start-log parsed: '
        'sessionId=${response.session.id}, '
        'firstSessionWorkoutId=${response.firstSessionWorkout.id}',
      );
      return response;
    }

    throw const AuthException(
      message: 'Invalid response received from the server.',
      statusCode: 0,
    );
  }

  Future<ActiveSessionWorkout> completeSessionWorkout(
    int sessionWorkoutId,
    CompleteSessionWorkoutRequest requestData,
  ) async {
    final url = ApiEndpoint.completeSessionWorkout(sessionWorkoutId);
    debugPrint(
      '[API HIT][POST] /sessions/session-workouts/$sessionWorkoutId/complete -> $url',
    );
    debugPrint(
      'POST /sessions/session-workouts/{sessionWorkoutId}/complete body: '
      '${jsonEncode(requestData.toJson())}',
    );

    final data = await _apiClient.postJson(
      url: url,
      body: requestData.toJson(),
      headers: _progressHeaders,
      logLabel: 'POST /sessions/session-workouts/{sessionWorkoutId}/complete',
      showDebugLog: true,
    );
    final workout = ActiveSessionWorkout.fromJson(data);
    debugPrint(
      'POST /sessions/session-workouts/{sessionWorkoutId}/complete parsed: '
      'sessionWorkoutId=${workout.id}, isCompleted=${workout.isCompleted}',
    );
    return workout;
  }

  Future<CardioLog> createCardioLog(CreateCardioLogRequest requestData) async {
    final url = ApiEndpoint.cardioLog();
    debugPrint('[API HIT][POST] /sessions/cardio-log -> $url');
    debugPrint(
      'POST /sessions/cardio-log body: ${jsonEncode(requestData.toJson())}',
    );

    final data = await _apiClient.postJson(
      url: url,
      body: requestData.toJson(),
      headers: _progressHeaders,
      logLabel: 'POST /sessions/cardio-log',
      showDebugLog: true,
    );
    final cardioLog = CardioLog.fromJson(data);
    debugPrint(
      'POST /sessions/cardio-log parsed: '
      'id=${cardioLog.id}, '
      'timeMinutes=${cardioLog.timeMinutes}, '
      'caloriesBurned=${cardioLog.caloriesBurned}',
    );
    return cardioLog;
  }

  Future<SetLog> createSetLog(CreateSetLogRequest requestData) async {
    final url = ApiEndpoint.setLog();
    debugPrint('[API HIT][POST] /sessions/set-log -> $url');
    debugPrint(
      'POST /sessions/set-log body: ${jsonEncode(requestData.toJson())}',
    );

    final data = await _apiClient.postJson(
      url: url,
      body: requestData.toJson(),
      headers: _progressHeaders,
      logLabel: 'POST /sessions/set-log',
      showDebugLog: true,
    );
    final setLog = SetLog.fromJson(data);
    debugPrint(
      'POST /sessions/set-log parsed: '
      'id=${setLog.id}, '
      'order=${setLog.order}, '
      'isCompleted=${setLog.isCompleted}',
    );
    return setLog;
  }

  Future<ActiveWorkoutSession> completeSession(
    int sessionId,
    CompleteSessionRequest requestData,
  ) async {
    final url = ApiEndpoint.completeSession(sessionId);
    debugPrint(
      '[API HIT][POST] /sessions/sessions/$sessionId/complete -> $url',
    );
    debugPrint(
      'POST /sessions/sessions/{sessionId}/complete body: '
      '${jsonEncode(requestData.toJson())}',
    );

    final data = await _apiClient.postJson(
      url: url,
      body: requestData.toJson(),
      headers: _progressHeaders,
      logLabel: 'POST /sessions/sessions/{sessionId}/complete',
      showDebugLog: true,
    );
    final session = ActiveWorkoutSession.fromJson(data);
    debugPrint(
      'POST /sessions/sessions/{sessionId}/complete parsed: '
      'sessionId=${session.id}, '
      'status=${session.status}, '
      'currentWorkoutOrder=${session.currentWorkoutOrder}',
    );
    return session;
  }

  Future<ProgressSummary> getProgressSummary({
    String? startDate,
    String? endDate,
  }) async {
    final data = await _apiClient.get(
      url: ApiEndpoint.progressSummary(startDate: startDate, endDate: endDate),
      headers: _progressHeaders,
      logLabel: 'Get Progress Summary',
      showDebugLog: true,
    );
    final summary = ProgressSummary.fromJson(data);
    debugPrint(
      'Get Progress Summary parsed: workouts=${summary.totalWorkouts}, volume=${summary.totalVolume}',
    );
    return summary;
  }

  Future<ProgressHighlights> getProgressHighlights() async {
    final userId = _currentUserId;
    final data = await _apiClient.get(
      url: ApiEndpoint.progressHighlights(userId: userId),
      headers: _progressHeaders,
      logLabel: 'Get Progress Highlights',
      showDebugLog: true,
    );
    final highlights = ProgressHighlights.fromJson(data);
    debugPrint(
      'Get Progress Highlights parsed: streak=${highlights.daysStreak}, '
      'week=${highlights.workoutsThisWeek}, calories=${highlights.caloriesBurned}',
    );
    return highlights;
  }

  Future<List<ProgressRecentActivity>> getProgressRecentActivity({
    int limit = 5,
  }) async {
    final userId = _currentUserId;
    final data = await _apiClient.getList(
      url: ApiEndpoint.progressRecentActivity(userId: userId, limit: limit),
      headers: _progressHeaders,
      logLabel: 'Get Progress Recent Activity',
      showDebugLog: true,
    );
    final activities = _parseList(data, ProgressRecentActivity.fromJson);
    debugPrint(
      'Get Progress Recent Activity parsed count: ${activities.length}',
    );
    return activities;
  }

  Future<List<ProgressChartPoint>> getProgressChart({
    String? startDate,
    String? endDate,
  }) async {
    final data = await _apiClient.getList(
      url: ApiEndpoint.progressChart(startDate: startDate, endDate: endDate),
      headers: _progressHeaders,
      logLabel: 'Get Progress Chart',
      showDebugLog: true,
    );
    final chart = _parseList(data, ProgressChartPoint.fromJson);
    debugPrint('Get Progress Chart parsed count: ${chart.length}');
    return chart;
  }

  Future<List<ProgressBest>> getProgressBests({
    int limit = 3,
    String? startDate,
    String? endDate,
  }) async {
    final data = await _apiClient.getList(
      url: ApiEndpoint.progressBests(
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      ),
      headers: _progressHeaders,
      logLabel: 'Get Progress Bests',
      showDebugLog: true,
    );
    final bests = _parseList(data, ProgressBest.fromJson);
    debugPrint('Get Progress Bests parsed count: ${bests.length}');
    return bests;
  }

  Map<String, String> get _authHeaders {
    if (!StorageService.hasAuthTokens) {
      throw const AuthException(
        message: 'Please log in again to load sessions.',
        statusCode: 401,
      );
    }

    return <String, String>{
      'refresh-token': StorageService.refreshToken,
      HttpHeaders.authorizationHeader: 'Bearer ${StorageService.accessToken}',
    };
  }

  Map<String, String> get _progressHeaders {
    if (!StorageService.hasAccessToken) {
      throw const AuthException(
        message: 'Please log in again to load progress.',
        statusCode: 401,
      );
    }

    return <String, String>{
      HttpHeaders.authorizationHeader: 'Bearer ${StorageService.accessToken}',
    };
  }

  String get _currentUserId {
    final token = StorageService.accessToken;
    final parts = token.split('.');
    if (parts.length < 2) {
      throw const AuthException(
        message: 'Please log in again to load sessions.',
        statusCode: 401,
      );
    }

    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final data = jsonDecode(payload);
    final userId = data is Map<String, dynamic>
        ? data['sub']?.toString()
        : null;

    if (userId == null || userId.isEmpty) {
      throw const AuthException(
        message: 'Please log in again to load sessions.',
        statusCode: 401,
      );
    }

    return userId;
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
