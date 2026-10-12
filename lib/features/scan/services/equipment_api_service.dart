import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/scan/model/equipment_category.dart';
import 'package:hawiisaac/features/scan/model/equipment_item.dart';
import 'package:hawiisaac/features/scan/model/muscle_group.dart';
import 'package:hawiisaac/features/scan/model/scan_result.dart';
import 'package:hawiisaac/features/scan/model/workout_item.dart';

class EquipmentApiService {
  EquipmentApiService({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? const AuthApiClient();

  final AuthApiClient _apiClient;

  Future<EquipmentScanResult> scanEquipmentUpload(String imagePath) async {
    final data = await _apiClient.requestMultipart(
      method: 'POST',
      url: ApiEndpoint.aiScanEquipmentUpload,
      fields: const <String, String>{},
      file: _buildImagePayload(imagePath),
      logLabel: 'AI Scan Equipment Upload',
      showDebugLog: true,
    );

    if (data is Map<String, dynamic>) {
      return EquipmentScanResult.fromJson(data);
    }

    throw const AuthException(
      message: 'Invalid response received from the server.',
      statusCode: 0,
    );
  }

  Future<EquipmentVerificationResult> verifyEquipment({
    required String equipmentName,
    required String imagePath,
  }) async {
    final data = await _apiClient.requestMultipart(
      method: 'POST',
      url: ApiEndpoint.aiVerifyEquipment,
      fields: <String, String>{'equipment_name': equipmentName},
      file: _buildImagePayload(imagePath),
      logLabel: 'AI Verify Equipment',
      showDebugLog: true,
    );

    if (data is Map<String, dynamic>) {
      return EquipmentVerificationResult.fromJson(data);
    }

    throw const AuthException(
      message: 'Invalid response received from the server.',
      statusCode: 0,
    );
  }

  Future<List<WorkoutItem>> getWorkouts({
    int? equipmentId,
    int offset = 0,
    int limit = 20,
  }) async {
    final data = await _apiClient.getList(
      url: ApiEndpoint.workouts(
        equipmentId: equipmentId,
        offset: offset,
        limit: limit,
      ),
      logLabel: 'Get Workouts',
      showDebugLog: true,
    );
    final workouts = _parseList(data, WorkoutItem.fromJson);
    debugPrint('Get Workouts parsed count: ${workouts.length}');
    return workouts;
  }

  Future<WorkoutItem> getWorkoutById(int id) async {
    final data = await _apiClient.get(
      url: ApiEndpoint.workoutById(id),
      logLabel: 'Get Workout Detail',
      showDebugLog: true,
    );
    final workout = WorkoutItem.fromJson(data);
    debugPrint(
      'Get Workout Detail parsed: id=${workout.id}, name=${workout.name}',
    );
    return workout;
  }

  Future<List<EquipmentItem>> getEquipments({
    int offset = 0,
    int limit = 20,
  }) async {
    final data = await _apiClient.getList(
      url: ApiEndpoint.equipments(offset: offset, limit: limit),
      logLabel: 'Get Equipments',
      showDebugLog: true,
    );
    final equipments = _parseList(data, EquipmentItem.fromJson);
    debugPrint('Get Equipments parsed count: ${equipments.length}');
    return equipments;
  }

  Future<EquipmentItem> getEquipmentById(int id) async {
    final data = await _apiClient.get(
      url: ApiEndpoint.equipmentById(id),
      logLabel: 'Get Equipment Detail',
      showDebugLog: true,
    );
    final equipment = EquipmentItem.fromJson(data);
    debugPrint(
      'Get Equipment Detail parsed: id=${equipment.id}, name=${equipment.name}',
    );
    return equipment;
  }

  Future<List<MuscleGroup>> getMuscleGroups({
    int offset = 0,
    int limit = 20,
  }) async {
    final data = await _apiClient.getList(
      url: ApiEndpoint.muscleGroups(offset: offset, limit: limit),
      logLabel: 'Get Muscle Groups',
      showDebugLog: true,
    );
    final muscleGroups = _parseList(data, MuscleGroup.fromJson);
    debugPrint('Get Muscle Groups parsed count: ${muscleGroups.length}');
    return muscleGroups;
  }

  Future<MuscleGroup> getMuscleGroupById(int id) async {
    final data = await _apiClient.get(
      url: ApiEndpoint.muscleGroupById(id),
      logLabel: 'Get Muscle Group Detail',
      showDebugLog: true,
    );
    final muscleGroup = MuscleGroup.fromJson(data);
    debugPrint(
      'Get Muscle Group Detail parsed: id=${muscleGroup.id}, name=${muscleGroup.name}',
    );
    return muscleGroup;
  }

  Future<List<EquipmentCategory>> getCategories({
    int offset = 0,
    int limit = 20,
  }) async {
    final data = await _apiClient.getList(
      url: ApiEndpoint.equipmentCategories(offset: offset, limit: limit),
      logLabel: 'Get Equipment Categories',
      showDebugLog: true,
    );
    final categories = _parseList(data, EquipmentCategory.fromJson);
    debugPrint('Get Equipment Categories parsed count: ${categories.length}');
    return categories;
  }

  Future<EquipmentCategory> getCategoryById(int id) async {
    final data = await _apiClient.get(
      url: ApiEndpoint.equipmentCategoryById(id),
      logLabel: 'Get Equipment Category Detail',
      showDebugLog: true,
    );
    final category = EquipmentCategory.fromJson(data);
    debugPrint(
      'Get Equipment Category Detail parsed: id=${category.id}, name=${category.name}',
    );
    return category;
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

  MultipartFilePayload _buildImagePayload(String imagePath) {
    final file = File(imagePath);
    if (!file.existsSync()) {
      throw const AuthException(
        message: 'Captured image was not found. Please try scanning again.',
        statusCode: 0,
      );
    }

    return MultipartFilePayload(
      fieldName: 'image',
      path: imagePath,
      fileName: file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : 'equipment.jpg',
      contentType: _contentTypeFor(imagePath),
    );
  }

  String _contentTypeFor(String path) {
    final normalized = path.toLowerCase();
    if (normalized.endsWith('.png')) return 'image/png';
    if (normalized.endsWith('.webp')) return 'image/webp';
    if (normalized.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}
