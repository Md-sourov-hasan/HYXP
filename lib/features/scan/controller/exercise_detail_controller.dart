import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/scan/model/workout_item.dart';
import 'package:hawiisaac/features/scan/services/equipment_api_service.dart';
import 'package:hawiisaac/features/sessions/services/session_api_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class ExerciseDetailController extends GetxController {
  final SessionApiService _sessionApiService = SessionApiService();
  final EquipmentApiService _equipmentApiService = EquipmentApiService();
  final RxBool isLoading = true.obs;
  final RxBool isStartingWorkout = false.obs;

  // ─── Exercise Info ───────────────────────────────────────────────
  String exerciseName = 'Barbell Bench\nPress';
  String category = 'Compound';
  String muscleGroup = 'Chest';
  String imageUrl = 'assets/images/burbel_brench.png';
  String videoUrl = '';
  int workoutId = 0;
  bool isCardioWorkout = false;

  // ─── Stats ───────────────────────────────────────────────────────
  String sets = '3-5';
  String reps = '6-12';
  String rest = '60-90';
  String time = '';
  String distance = '';
  String speed = '';
  String incline = '';
  String kg = '';

  // ─── Muscle Tags ─────────────────────────────────────────────────
  // true  = primary (cyan highlight)
  // false = secondary (grey)
  Map<String, bool> muscleTags = {
    'Pectorals': true,
    'Anterior Delt': true,
    'Triceps': false,
    'Serratus': false,
  };

  // ─── How-to Steps ────────────────────────────────────────────────
  List<String> steps = [
    'Lie flat on the bench and grip the bar slightly wider than shoulder-width.',
    'Unrack the bar and lower it to mid-chest with control.',
    'Press explosively back up, keeping feet flat and shoulder blades retracted.',
  ];

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;
    if (arguments is Map) {
      _applyWorkout(arguments);
    }

    _loadWorkoutDetail();
  }

  // ─── Actions ─────────────────────────────────────────────────────
  Future<void> addToWorkout() async {
    if (isStartingWorkout.value) return;
    await _startWorkoutLog();
  }

  void _applyWorkout(Map<dynamic, dynamic> workout) {
    workoutId = int.tryParse(workout['id']?.toString() ?? '') ?? 0;
    final title = workout['title']?.toString() ?? '';
    final description = workout['description']?.toString() ?? '';
    final categoryValue = workout['category']?.toString() ?? '';
    final equipmentValue = workout['equipment']?.toString() ?? '';
    final imageValue = workout['imageUrl']?.toString() ?? '';
    final videoValue = workout['video']?.toString() ?? '';
    final workoutTypeValue = workout['workoutType']?.toString() ?? '';
    final usesValue = workout['uses'];

    if (title.isNotEmpty) exerciseName = title;
    if (categoryValue.isNotEmpty) category = categoryValue;
    if (equipmentValue.isNotEmpty) muscleGroup = equipmentValue;
    if (imageValue.isNotEmpty) imageUrl = imageValue;
    if (videoValue.isNotEmpty) videoUrl = videoValue;
    isCardioWorkout =
        workoutTypeValue.toLowerCase() == 'cardio' ||
        time.isNotEmpty ||
        distance.isNotEmpty ||
        speed.isNotEmpty ||
        incline.isNotEmpty;

    sets = workout['sets']?.toString() ?? sets;
    reps = workout['reps']?.toString() ?? reps;
    rest = workout['rest']?.toString() ?? rest;
    time = _normalizeMetricValue(workout['time']);
    distance = _normalizeMetricValue(workout['distance']);
    speed = _normalizeMetricValue(workout['speed']);
    incline = _normalizeMetricValue(workout['incline']);
    kg = _normalizeMetricValue(workout['kg'] ?? workout['weight']);

    final muscles = workout['muscleGroups'];
    if (muscles is List && muscles.isNotEmpty) {
      muscleTags = {
        for (final entry in muscles.asMap().entries)
          entry.value.toString(): entry.key == 0,
      };
    }

    if (usesValue is List && usesValue.isNotEmpty) {
      steps = usesValue.map((use) => use.toString()).toList(growable: false);
    } else if (description.isNotEmpty) {
      steps = [description];
    }
  }

  Future<void> _loadWorkoutDetail() async {
    if (workoutId <= 0) {
      isLoading.value = false;
      return;
    }

    try {
      final detail = await _equipmentApiService.getWorkoutById(workoutId);
      _applyWorkoutDetail(detail);
    } on AuthException catch (error) {
      AppLoadingService.showError('Workout Load Failed', error.message);
    } catch (_) {
      AppLoadingService.showError(
        'Workout Load Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _applyWorkoutDetail(WorkoutItem workout) {
    workoutId = workout.id;
    exerciseName = workout.name.isNotEmpty ? workout.name : exerciseName;
    category = workout.category.name.isNotEmpty
        ? workout.category.name
        : category;
    muscleGroup = workout.equipment.name.isNotEmpty
        ? workout.equipment.name
        : muscleGroup;
    imageUrl = workout.banner.isNotEmpty ? workout.banner : imageUrl;
    videoUrl = workout.video.isNotEmpty ? workout.video : videoUrl;
    isCardioWorkout = workout.workoutType.toLowerCase() == 'cardio';

    if (workout.sets.isNotEmpty) sets = workout.sets;
    if (workout.reps.isNotEmpty) reps = workout.reps;
    if (workout.rest.isNotEmpty) rest = workout.rest;
    time = _normalizeMetricValue(workout.time);
    if (time.isEmpty) {
      time = _normalizeMetricValue(workout.duration);
    }
    distance = _normalizeMetricValue(workout.distance);
    speed = _normalizeMetricValue(workout.speed);
    incline = _normalizeMetricValue(workout.incline);
    isCardioWorkout =
        workout.workoutType.toLowerCase() == 'cardio' ||
        time.isNotEmpty ||
        distance.isNotEmpty ||
        speed.isNotEmpty ||
        incline.isNotEmpty;

    if (workout.muscleGroups.isNotEmpty) {
      muscleTags = {
        for (final entry in workout.muscleGroups.asMap().entries)
          entry.value.name: entry.key == 0,
      };
    }

    if (workout.description.trim().isNotEmpty) {
      steps = <String>[workout.description.trim()];
    }

    if (workout.uses.isNotEmpty) {
      steps = <String>[
        if (workout.description.trim().isNotEmpty) workout.description.trim(),
        ...workout.uses.map((use) => 'Best for ${use.toString()}'),
      ];
    }
  }

  Future<void> _startWorkoutLog() async {
    if (workoutId <= 0) {
      AppLoadingService.showError(
        'Start Failed',
        'Workout information is missing.',
      );
      return;
    }

    isStartingWorkout.value = true;

    try {
      debugPrint(
        'Add to workout tapped: workoutId=$workoutId, title=$exerciseName',
      );
      final response = await _sessionApiService.startWorkoutLog(workoutId);
      debugPrint(
        'Start log response: '
        'sessionId=${response.session.id}, '
        'sessionStatus=${response.session.status}, '
        'firstSessionWorkoutId=${response.firstSessionWorkout.id}, '
        'firstWorkoutName=${response.firstSessionWorkout.workout.name}',
      );
      debugPrint('Start log session payload: ${response.session.toJson()}');
      debugPrint(
        'Start log first_session_workout payload: '
        '${response.firstSessionWorkout.toJson()}',
      );
      Get.toNamed(
        AppRoute.getLoggingScreen(),
        arguments: <String, dynamic>{
          'session_id': response.session.id,
          'session_workout_id': response.firstSessionWorkout.id,
          'title': response.firstSessionWorkout.workout.name.isNotEmpty
              ? response.firstSessionWorkout.workout.name
              : exerciseName,
          'tags': muscleGroup,
          'sets': response.firstSessionWorkout.workout.sets.isNotEmpty
              ? response.firstSessionWorkout.workout.sets
              : sets,
          'reps': response.firstSessionWorkout.workout.reps.isNotEmpty
              ? response.firstSessionWorkout.workout.reps
              : reps,
          'rest': response.firstSessionWorkout.workout.rest.isNotEmpty
              ? response.firstSessionWorkout.workout.rest
              : rest,
          'time': time,
          'distance': distance,
          'speed': speed,
          'incline': incline,
          'kg': kg,
          'is_cardio':
              response.firstSessionWorkout.workout.workoutType.toLowerCase() ==
              'cardio',
          'session': response.session.toJson(),
          'first_session_workout': response.firstSessionWorkout.toJson(),
        },
      );
      debugPrint(
        'Navigating to logging screen: '
        'session_id=${response.session.id}, '
        'session_workout_id=${response.firstSessionWorkout.id}',
      );
    } on AuthException catch (error) {
      debugPrint('Start workout auth error: ${error.message}');
      AppLoadingService.showError('Start Failed', error.message);
    } catch (error) {
      debugPrint('Start workout unexpected error: $error');
      AppLoadingService.showError(
        'Start Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isStartingWorkout.value = false;
    }
  }

  String _normalizeMetricValue(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text == 'null') {
      return '';
    }
    if (text == '0' || text == '0.0') {
      return '';
    }
    return text;
  }
}
