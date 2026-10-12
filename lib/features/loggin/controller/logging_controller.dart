import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/sessions/model/session_models.dart';
import 'package:hawiisaac/features/sessions/services/session_api_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class WorkoutSet {
  final RxInt kg;
  final RxInt reps;
  final RxBool isCompleted;
  final RxnInt logId;

  WorkoutSet({int kg = 80, int reps = 8, bool isCompleted = false, int? logId})
    : kg = kg.obs,
      reps = reps.obs,
      isCompleted = isCompleted.obs,
      logId = RxnInt(logId);
}

class LoggingController extends GetxController with WidgetsBindingObserver {
  final SessionApiService _sessionApiService = SessionApiService();

  final RxBool isLoading = true.obs;
  final RxString exerciseName = 'Workout'.obs;
  final RxString workoutTags = ''.obs;
  final RxString restValue = ''.obs;
  final RxList<WorkoutSet> sets = <WorkoutSet>[].obs;
  final noteController = TextEditingController();
  final timeController = TextEditingController();
  final distanceController = TextEditingController();
  final speedController = TextEditingController();
  final RxInt elapsedSeconds = 0.obs;
  final RxBool isSaving = false.obs;
  final RxInt inclineValue = 0.obs;
  final RxList<int> savingSetIndexes = <int>[].obs;

  final RxnInt activeSessionId = RxnInt();
  final RxnInt sessionWorkoutId = RxnInt();
  final RxBool isCardioWorkout = false.obs;

  Timer? _timer;
  double _activeUserWeightKg = 1;
  int _defaultKg = 0;
  bool _hasTemplateFromArguments = false;
  bool _hasExplicitZeroSetsFromArguments = false;
  bool _hasCompletedSession = false;
  bool _isAutoCompletingOnExit = false;
  bool _navigateHomeAfterAutoComplete = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    debugPrint('LoggingController.onInit');
    _applyArguments();
    _initialize();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    noteController.dispose();
    timeController.dispose();
    distanceController.dispose();
    speedController.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint(
      'Logging lifecycle changed: '
      'state=$state, '
      'sessionId=${activeSessionId.value}, '
      'hasCompletedSession=$_hasCompletedSession, '
      'isAutoCompleting=$_isAutoCompletingOnExit',
    );

    if (state == AppLifecycleState.resumed) {
      if (_navigateHomeAfterAutoComplete) {
        _navigateHomeAfterAutoComplete = false;
        Get.offAllNamed(AppRoute.getBottomNavigationScreen());
      }
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_completeSessionOnAppExit());
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value++;
    });
  }

  Future<void> _initialize() async {
    debugPrint('LoggingController._initialize started');
    await _loadSessionData();
    if (sets.isEmpty && !_hasExplicitZeroSetsFromArguments) {
      sets.assignAll(_buildDefaultSets());
      debugPrint(
        'LoggingController default sets applied: count=${sets.length}',
      );
    }
    _startTimer();
    isLoading.value = false;
    debugPrint(
      'LoggingController._initialize completed: '
      'sessionId=${activeSessionId.value}, '
      'sessionWorkoutId=${sessionWorkoutId.value}, '
      'exercise=${exerciseName.value}, '
      'sets=${sets.length}',
    );
  }

  String get formattedTime {
    final m = elapsedSeconds.value ~/ 60;
    final s = elapsedSeconds.value % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void incrementKg(int index) {
    if (_isSetLocked(index)) return;
    sets[index].kg.value++;
  }

  void decrementKg(int index) {
    if (_isSetLocked(index)) return;
    if (sets[index].kg.value > 0) sets[index].kg.value--;
  }

  void incrementReps(int index) {
    if (_isSetLocked(index)) return;
    sets[index].reps.value++;
  }

  void decrementReps(int index) {
    if (_isSetLocked(index)) return;
    if (sets[index].reps.value > 0) sets[index].reps.value--;
  }

  void incrementIncline() => inclineValue.value++;
  void decrementIncline() {
    if (inclineValue.value > 0) inclineValue.value--;
  }

  Future<void> toggleCompleted(int index) async {
    final set = sets[index];
    if (set.isCompleted.value) {
      AppLoadingService.showInfo('Set Saved', 'This set is already logged.');
      return;
    }

    final currentSessionWorkoutId = sessionWorkoutId.value;
    if (currentSessionWorkoutId == null || currentSessionWorkoutId <= 0) {
      AppLoadingService.showError(
        'Set Log Failed',
        'Session workout information is missing.',
      );
      return;
    }

    if (savingSetIndexes.contains(index)) return;
    savingSetIndexes.add(index);

    try {
      final response = await _sessionApiService.createSetLog(
        CreateSetLogRequest(
          sessionWorkoutId: currentSessionWorkoutId,
          weight: set.kg.value.toDouble(),
          reps: set.reps.value,
          order: index + 1,
          durationSeconds: 0,
          isCompleted: true,
        ),
      );
      set.kg.value = response.weight.round();
      set.reps.value = response.reps;
      set.isCompleted.value = response.isCompleted;
      set.logId.value = response.id;
    } on AuthException catch (error) {
      AppLoadingService.showError('Set Log Failed', error.message);
    } catch (_) {
      AppLoadingService.showError(
        'Set Log Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      savingSetIndexes.remove(index);
    }
  }

  void addSet() {
    final last = sets.isNotEmpty ? sets.last : WorkoutSet();
    sets.add(WorkoutSet(kg: last.kg.value, reps: last.reps.value));
  }

  Future<void> onFinishWorkout() async {
    final currentSessionWorkoutId = sessionWorkoutId.value;
    final currentSessionId = activeSessionId.value;
    if (currentSessionWorkoutId == null ||
        currentSessionWorkoutId <= 0 ||
        currentSessionId == null ||
        currentSessionId <= 0 ||
        isSaving.value) {
      AppLoadingService.showError(
        'Workout Failed',
        'Active workout session information is missing.',
      );
      return;
    }

    if (!isCardioWorkout.value && _hasIncompleteSets) {
      _showIncompleteSetsDialog();
      return;
    }

    _timer?.cancel();
    isSaving.value = true;

    try {
      if (isCardioWorkout.value) {
        await _sessionApiService.createCardioLog(
          CreateCardioLogRequest(
            sessionWorkoutId: currentSessionWorkoutId,
            timeMinutes: _cardioTimeMinutes,
            distance: _cardioDistance,
            speed: _cardioSpeed,
            incline: inclineValue.value.toDouble(),
            userWeightKg: _activeUserWeightKg,
          ),
        );
      }

      await _sessionApiService.completeSessionWorkout(
        currentSessionWorkoutId,
        CompleteSessionWorkoutRequest(
          note: noteController.text.trim().isNotEmpty
              ? noteController.text.trim()
              : 'Completed workout',
          markSessionCompleteIfFinished: false,
        ),
      );

      await _sessionApiService.completeSession(
        currentSessionId,
        CompleteSessionRequest(
          durationMinutes: _sessionDurationMinutes,
          note: noteController.text.trim().isNotEmpty
              ? noteController.text.trim()
              : 'Workout finished',
        ),
      );

      _hasCompletedSession = true;
      activeSessionId.value = null;
      sessionWorkoutId.value = null;
      AppLoadingService.showSuccess(
        'Workout Complete!',
        'Great job on your ${exerciseName.value} session.',
      );
      Get.offAllNamed(AppRoute.getBottomNavigationScreen());
    } on AuthException catch (error) {
      AppLoadingService.showError('Session Failed', error.message);
      _startTimer();
    } catch (_) {
      AppLoadingService.showError(
        'Session Failed',
        'Something went wrong. Please try again.',
      );
      _startTimer();
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _completeSessionOnAppExit() async {
    final currentSessionId = activeSessionId.value;
    if (currentSessionId == null ||
        currentSessionId <= 0 ||
        _hasCompletedSession ||
        _isAutoCompletingOnExit ||
        isSaving.value) {
      return;
    }

    _isAutoCompletingOnExit = true;
    debugPrint(
      'Auto completing session because user left the app: '
      'sessionId=$currentSessionId, '
      'elapsedSeconds=${elapsedSeconds.value}',
    );

    try {
      final completedSession = await _sessionApiService.completeSession(
        currentSessionId,
        CompleteSessionRequest(
          durationMinutes: _sessionDurationMinutes,
          note: noteController.text.trim().isNotEmpty
              ? noteController.text.trim()
              : 'Auto-completed because the user left the app',
        ),
      );
      debugPrint(
        'Auto complete session response: '
        'id=${completedSession.id}, '
        'status=${completedSession.status}, '
        'completedAt=${completedSession.completedAt}',
      );
      _hasCompletedSession = true;
      activeSessionId.value = null;
      sessionWorkoutId.value = null;
      _navigateHomeAfterAutoComplete = true;
    } on AuthException catch (error) {
      debugPrint(
        'Auto complete session auth error: '
        'sessionId=$currentSessionId, '
        'message=${error.message}, '
        'statusCode=${error.statusCode}',
      );
    } catch (error) {
      debugPrint(
        'Auto complete session failed: '
        'sessionId=$currentSessionId, error=$error',
      );
    } finally {
      _isAutoCompletingOnExit = false;
    }
  }

  void _applyArguments() {
    final arguments = Get.arguments;
    if (arguments is! Map) return;
    debugPrint('LoggingController arguments: $arguments');

    activeSessionId.value = _parseInt(arguments['session_id']);
    sessionWorkoutId.value = _parseInt(arguments['session_workout_id']);
    isCardioWorkout.value = arguments['is_cardio'] == true;

    final session = arguments['session'];
    if (session is Map<String, dynamic>) {
      final parsed = ActiveWorkoutSession.fromJson(session);
      if (parsed.userWeightKg != null && parsed.userWeightKg! > 0) {
        _activeUserWeightKg = parsed.userWeightKg!;
      }
    }

    final firstSessionWorkout = arguments['first_session_workout'];
    if (firstSessionWorkout is Map<String, dynamic>) {
      final parsed = ActiveSessionWorkout.fromJson(firstSessionWorkout);
      sessionWorkoutId.value = parsed.id;
      if (parsed.workout.workoutType.toLowerCase() == 'cardio') {
        isCardioWorkout.value = true;
      }
      if (parsed.setLogs.isNotEmpty) {
        final loggedSets = [...parsed.setLogs]
          ..sort((a, b) => a.order.compareTo(b.order));
        sets.assignAll(
          loggedSets.map((item) {
            return WorkoutSet(
              kg: item.weight.round(),
              reps: item.reps,
              isCompleted: item.isCompleted,
              logId: item.id,
            );
          }),
        );
      }
      final cardioLog = parsed.cardioLog;
      if (cardioLog != null) {
        timeController.text = '${cardioLog.timeMinutes} min';
        distanceController.text = _displayDistanceValue(
          cardioLog.distance.toString(),
        );
        speedController.text = _displaySpeedValue(cardioLog.speed.toString());
        inclineValue.value = cardioLog.incline.round();
      }
    }

    final title = arguments['title']?.toString() ?? '';
    final tags = arguments['tags']?.toString() ?? '';
    final setsText = arguments['sets']?.toString() ?? '';
    final repsText = arguments['reps']?.toString() ?? '';
    final restText = arguments['rest']?.toString() ?? '';
    final timeText = arguments['time']?.toString() ?? '';
    final durationText = arguments['duration']?.toString() ?? '';
    final distanceText = arguments['distance']?.toString() ?? '';
    final speedText = arguments['speed']?.toString() ?? '';
    final inclineText = arguments['incline']?.toString() ?? '';
    final kgText =
        arguments['kg']?.toString() ?? arguments['weight']?.toString() ?? '';
    final hasStrengthTemplate =
        setsText.trim().isNotEmpty ||
        repsText.trim().isNotEmpty ||
        restText.trim().isNotEmpty;
    final resolvedTimeText = timeText.trim().isNotEmpty
        ? timeText
        : durationText;
    final hasCardioMetrics =
        resolvedTimeText.trim().isNotEmpty ||
        distanceText.trim().isNotEmpty ||
        speedText.trim().isNotEmpty ||
        inclineText.trim().isNotEmpty;

    if (title.isNotEmpty) {
      exerciseName.value = title;
    }
    workoutTags.value = tags;
    restValue.value = restText;
    timeController.text = _displayTimeValue(resolvedTimeText);
    distanceController.text = _displayDistanceValue(distanceText);
    speedController.text = _displaySpeedValue(speedText);
    inclineValue.value = _parsePreferredInt(inclineText) ?? 0;
    _defaultKg = _parsePreferredInt(kgText) ?? 0;
    if (hasCardioMetrics) {
      isCardioWorkout.value = true;
    }

    final parsedSetCount = _parsePreferredInt(setsText);
    final setCount = parsedSetCount ?? 3;
    final repCount = _parsePreferredInt(repsText) ?? 8;
    if (!hasStrengthTemplate || parsedSetCount == 0) {
      _hasTemplateFromArguments = true;
      _hasExplicitZeroSetsFromArguments = true;
      sets.clear();
    } else if (sets.isEmpty) {
      sets.assignAll(
        List<WorkoutSet>.generate(
          setCount.clamp(1, 12),
          (_) => WorkoutSet(kg: _defaultKg, reps: repCount),
        ),
      );
      _hasTemplateFromArguments = true;
    }
    debugPrint(
      'LoggingController arguments applied: '
      'sessionId=${activeSessionId.value}, '
      'sessionWorkoutId=${sessionWorkoutId.value}, '
      'title=${exerciseName.value}, '
      'isCardio=${isCardioWorkout.value}, '
      'setCount=${sets.length}, '
      'explicitZeroSets=$_hasExplicitZeroSetsFromArguments, '
      'hasCardioMetrics=$hasCardioMetrics',
    );
  }

  Future<void> _loadSessionData() async {
    try {
      debugPrint('LoggingController loading active session');
      final activeSession = await _sessionApiService.getActiveSession();
      debugPrint(
        'Active session response: '
        'id=${activeSession.id}, '
        'status=${activeSession.status}, '
        'currentWorkoutOrder=${activeSession.currentWorkoutOrder}, '
        'workouts=${activeSession.workouts.length}',
      );
      debugPrint('Active session payload: ${activeSession.toJson()}');
      activeSessionId.value = activeSession.id;
      _applySessionData(activeSession);
    } on AuthException catch (error) {
      debugPrint('LoggingController session load auth error: ${error.message}');
      if (activeSessionId.value == null || activeSessionId.value! <= 0) {
        AppLoadingService.showError('Session Load Failed', error.message);
      }
    } catch (error) {
      debugPrint('LoggingController session load error: $error');
      if (activeSessionId.value == null || activeSessionId.value! <= 0) {
        AppLoadingService.showError(
          'Session Load Failed',
          'Something went wrong. Please try again.',
        );
      }
    }
  }

  void _applySessionData(ActiveWorkoutSession session) {
    debugPrint(
      'Applying session data: '
      'sessionId=${session.id}, '
      'currentWorkoutOrder=${session.currentWorkoutOrder}, '
      'workouts=${session.workouts.length}',
    );
    activeSessionId.value = session.id;
    if (session.userWeightKg != null && session.userWeightKg! > 0) {
      _activeUserWeightKg = session.userWeightKg!;
    }
    if (noteController.text.trim().isEmpty && session.note.trim().isNotEmpty) {
      noteController.text = session.note.trim();
    }

    final sortedWorkouts = [...session.workouts]
      ..sort((a, b) => a.order.compareTo(b.order));
    if (sortedWorkouts.isEmpty) {
      return;
    }

    final preferredSessionWorkoutId = sessionWorkoutId.value;
    final preferredWorkout = preferredSessionWorkoutId == null
        ? null
        : sortedWorkouts.cast<ActiveSessionWorkout?>().firstWhere(
            (item) => item?.id == preferredSessionWorkoutId,
            orElse: () => null,
          );
    final currentIndex = (session.currentWorkoutOrder - 1).clamp(
      0,
      sortedWorkouts.length - 1,
    );
    final currentWorkout = preferredWorkout ?? sortedWorkouts[currentIndex];
    debugPrint(
      'Resolved current workout: '
      'sessionWorkoutId=${currentWorkout.id}, '
      'order=${currentWorkout.order}, '
      'name=${currentWorkout.workout.name}',
    );
    _applySessionWorkout(currentWorkout);
  }

  void _applySessionWorkout(ActiveSessionWorkout workout) {
    debugPrint(
      'Applying session workout: '
      'id=${workout.id}, '
      'name=${workout.workout.name}, '
      'type=${workout.workout.workoutType}, '
      'sets=${workout.workout.sets}, '
      'reps=${workout.workout.reps}, '
      'rest=${workout.workout.rest}, '
      'loggedSets=${workout.setLogs.length}',
    );
    sessionWorkoutId.value = workout.id;

    if (workout.workout.name.trim().isNotEmpty) {
      exerciseName.value = workout.workout.name.trim();
    }

    if (workoutTags.value.trim().isEmpty) {
      final tagParts = <String>[
        if (workout.workout.workoutType.trim().isNotEmpty)
          workout.workout.workoutType.replaceAll('_', ' '),
        if (workout.workout.metValue > 0) '${workout.workout.metValue} MET',
      ];
      workoutTags.value = tagParts.join(' . ');
    }

    restValue.value = workout.workout.rest;
    isCardioWorkout.value =
        isCardioWorkout.value ||
        workout.workout.workoutType.toLowerCase() == 'cardio' ||
        _hasCardioInputValues();

    if (workout.cardioLog != null) {
      final cardioLog = workout.cardioLog!;
      timeController.text = '${cardioLog.timeMinutes} min';
      distanceController.text = _displayDistanceValue(
        cardioLog.distance.toString(),
      );
      speedController.text = _displaySpeedValue(cardioLog.speed.toString());
      inclineValue.value = cardioLog.incline.round();
    }

    if (workout.setLogs.isNotEmpty) {
      final loggedSets = [...workout.setLogs]
        ..sort((a, b) => a.order.compareTo(b.order));
      sets.assignAll(
        loggedSets.map((item) {
          return WorkoutSet(
            kg: item.weight.round(),
            reps: item.reps,
            isCompleted: item.isCompleted,
            logId: item.id,
          );
        }),
      );
      debugPrint('Applied logged sets: count=${sets.length}');
      return;
    }

    if (_hasExplicitZeroSetsFromArguments) {
      debugPrint('Preserving explicit zero sets from previous screen');
      sets.clear();
      return;
    }

    final hasStrengthTemplate =
        workout.workout.sets.trim().isNotEmpty ||
        workout.workout.reps.trim().isNotEmpty ||
        workout.workout.rest.trim().isNotEmpty;
    if (!hasStrengthTemplate) {
      debugPrint(
        'Session workout has no sets/reps/rest, preserving empty set list',
      );
      sets.clear();
      return;
    }

    if (_hasTemplateFromArguments && sets.isNotEmpty) {
      debugPrint(
        'Preserving template from previous screen: '
        'count=${sets.length}, '
        'defaultKg=$_defaultKg, '
        'defaultReps=${sets.first.reps.value}',
      );
      return;
    }

    final setCount = _parsePreferredInt(workout.workout.sets) ?? sets.length;
    final repCount = _parsePreferredInt(workout.workout.reps) ?? 8;
    sets.assignAll(
      List<WorkoutSet>.generate(
        setCount.clamp(1, 12),
        (_) => WorkoutSet(kg: _defaultKg, reps: repCount),
      ),
    );
    debugPrint(
      'Applied workout template sets: '
      'count=${sets.length}, defaultKg=$_defaultKg, defaultReps=$repCount',
    );
  }

  List<WorkoutSet> _buildDefaultSets() {
    return <WorkoutSet>[
      WorkoutSet(kg: 0, reps: 8),
      WorkoutSet(kg: 0, reps: 8),
      WorkoutSet(kg: 0, reps: 8),
    ];
  }

  int? _parsePreferredInt(String value) {
    final matches = RegExp(r'\d+').allMatches(value).toList(growable: false);
    if (matches.isEmpty) return null;
    return int.tryParse(matches.last.group(0)!);
  }

  int? _parseInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '');
  }

  int get _cardioTimeMinutes {
    final text = timeController.text.trim();
    if (text.isEmpty) {
      return (elapsedSeconds.value / 60).ceil().clamp(1, 1440);
    }

    if (text.contains(':')) {
      final parts = text.split(':').map((item) => int.tryParse(item) ?? 0);
      final values = parts.toList(growable: false);
      if (values.length == 3) {
        return ((values[0] * 60) + values[1] + (values[2] > 0 ? 1 : 0)).clamp(
          1,
          1440,
        );
      }
      if (values.length == 2) {
        return (values[0] + (values[1] > 0 ? 1 : 0)).clamp(1, 1440);
      }
    }

    return _parseNumeric(text).ceil().clamp(1, 1440);
  }

  double get _cardioDistance => _parseNumeric(distanceController.text.trim());

  double get _cardioSpeed => _parseNumeric(speedController.text.trim());

  int get _sessionDurationMinutes {
    return (elapsedSeconds.value / 60).ceil().clamp(1, 1440);
  }

  bool get _hasIncompleteSets {
    return sets.isNotEmpty && sets.any((set) => !set.isCompleted.value);
  }

  bool _isSetLocked(int index) {
    return savingSetIndexes.contains(index) || sets[index].isCompleted.value;
  }

  double _parseNumeric(String value) {
    final normalized = value.replaceAll(',', '.');
    final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(normalized);
    if (match == null) return 0;
    return double.tryParse(match.group(0)!) ?? 0;
  }

  bool _hasCardioInputValues() {
    return timeController.text.trim().isNotEmpty ||
        distanceController.text.trim().isNotEmpty ||
        speedController.text.trim().isNotEmpty ||
        inclineValue.value > 0;
  }

  String _displayTimeValue(String raw) {
    if (raw.trim().isEmpty) return '';
    if (raw.contains(':')) {
      final parts = raw.split(':');
      if (parts.length == 3) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        final totalMinutes = (hours * 60) + minutes;
        return '$totalMinutes min';
      }
    }
    return raw;
  }

  String _displayDistanceValue(String raw) {
    if (raw.trim().isEmpty) return '';
    final value = _parseNumeric(raw);
    if (value <= 0) return raw;
    return value % 1 == 0 ? '${value.toInt()} km' : '$value km';
  }

  String _displaySpeedValue(String raw) {
    if (raw.trim().isEmpty) return '';
    final value = _parseNumeric(raw);
    if (value <= 0) return raw;
    return value % 1 == 0 ? '${value.toInt()} km/h' : '$value km/h';
  }

  void _showIncompleteSetsDialog() {
    final incompleteCount = sets.where((set) => !set.isCompleted.value).length;

    Get.dialog<void>(
      AlertDialog(
        title: const Text('Complete all sets'),
        content: Text(
          incompleteCount == 1
              ? 'Please check the remaining set before finishing this workout.'
              : 'Please check all remaining sets before finishing this workout. $incompleteCount sets are still unchecked.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}
