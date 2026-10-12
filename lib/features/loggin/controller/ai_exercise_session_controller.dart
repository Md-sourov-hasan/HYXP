import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/sessions/model/session_models.dart';
import 'package:hawiisaac/features/sessions/services/session_api_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class AiExerciseSessionItem {
  final int? sessionWorkoutId;
  final int? workoutId;
  final int order;
  final String name;
  final String tags;
  final String details;
  final int seconds;
  final String note;
  final bool isCardio;
  final bool hasExistingCardioLog;
  final double actualCaloriesBurned;
  final double distance;
  final double speed;
  final double incline;

  const AiExerciseSessionItem({
    this.sessionWorkoutId,
    this.workoutId,
    required this.order,
    required this.name,
    required this.tags,
    this.details = '',
    required this.seconds,
    this.note = '',
    this.isCardio = false,
    this.hasExistingCardioLog = false,
    this.actualCaloriesBurned = 0,
    this.distance = 0,
    this.speed = 0,
    this.incline = 0,
  });

  AiExerciseSessionItem copyWith({
    int? sessionWorkoutId,
    int? workoutId,
    int? order,
    String? name,
    String? tags,
    String? details,
    int? seconds,
    String? note,
    bool? isCardio,
    bool? hasExistingCardioLog,
    double? actualCaloriesBurned,
    double? distance,
    double? speed,
    double? incline,
  }) {
    return AiExerciseSessionItem(
      sessionWorkoutId: sessionWorkoutId ?? this.sessionWorkoutId,
      workoutId: workoutId ?? this.workoutId,
      order: order ?? this.order,
      name: name ?? this.name,
      tags: tags ?? this.tags,
      details: details ?? this.details,
      seconds: seconds ?? this.seconds,
      note: note ?? this.note,
      isCardio: isCardio ?? this.isCardio,
      hasExistingCardioLog: hasExistingCardioLog ?? this.hasExistingCardioLog,
      actualCaloriesBurned: actualCaloriesBurned ?? this.actualCaloriesBurned,
      distance: distance ?? this.distance,
      speed: speed ?? this.speed,
      incline: incline ?? this.incline,
    );
  }
}

class AiExerciseSessionController extends GetxController
    with WidgetsBindingObserver {
  final SessionApiService _sessionApiService = SessionApiService();

  final RxString title = 'Bodyweight Burn'.obs;
  final Rxn<ActiveWorkoutSession> sessionData = Rxn<ActiveWorkoutSession>();
  final RxString sessionLoadSource = ''.obs;
  final RxList<AiExerciseSessionItem> exercises = <AiExerciseSessionItem>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxInt remainingSeconds = 45.obs;
  final RxInt sessionRemainingSeconds = 45.obs;
  final RxList<int> completedIndexes = <int>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isAdvancing = false.obs;
  final RxBool isFinishing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxnInt activeSessionId = RxnInt();

  Timer? _timer;
  int _elapsedSessionSeconds = 0;
  int _elapsedCurrentExerciseSeconds = 0;
  double _activeUserWeightKg = 1;
  bool _hasSessionDuration = false;
  bool _hasCompletedSession = false;
  Map<int, int> _workoutDurationMap = {};
  Map<int, double> _workoutDistanceMap = {};
  Map<int, double> _workoutSpeedMap = {};
  Map<int, double> _workoutInclineMap = {};

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _applyArguments();
    _initializeSession();
    _startTimer();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint(
      'AI session lifecycle changed: '
      'state=$state, '
      'sessionId=${activeSessionId.value}, '
      'hasCompletedSession=$_hasCompletedSession',
    );
  }

  bool get hasExercises => exercises.isNotEmpty;
  bool get hasSessionData => sessionData.value != null;
  AiExerciseSessionItem get currentExercise => exercises[currentIndex.value];
  List<AiExerciseSessionItem> get completedExercises =>
      completedIndexes.map((index) => exercises[index]).toList(growable: false);
  List<AiExerciseSessionItem> get pendingExercises {
    if (exercises.length <= currentIndex.value + 1) return const [];
    return exercises.sublist(currentIndex.value + 1);
  }

  bool get isLastExercise => currentIndex.value >= exercises.length - 1;
  bool get allExercisesCompleted =>
      hasExercises && completedIndexes.length >= exercises.length;

  String get sessionIdLabel {
    final id = sessionData.value?.id ?? activeSessionId.value ?? 0;
    return id > 0 ? '#$id' : '-';
  }

  String get sessionStatusLabel {
    final value = sessionData.value?.status.trim() ?? '';
    if (value.isEmpty) return 'Unknown';
    return _titleCase(value);
  }

  String get sessionDateLabel {
    final value = sessionData.value?.date;
    if (value == null) return 'No date';

    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[value.month - 1]} ${value.day}, ${value.year}';
  }

  String get currentWorkoutOrderLabel {
    final currentOrder = hasSessionData
        ? sessionData.value!.currentWorkoutOrder
        : (hasExercises ? currentExercise.order : 0);
    final totalCount = totalWorkoutCount;
    if (currentOrder <= 0 || totalCount <= 0) return '-';
    return '$currentOrder / $totalCount';
  }

  int get totalWorkoutCount =>
      sessionData.value?.workouts.length ?? exercises.length;

  String get currentExerciseNote {
    if (!hasExercises) return '';
    return currentExercise.note.trim();
  }

  String get sourceContentTitle {
    final value = sessionData.value?.workouts
        .map((item) => item.content.title.trim())
        .firstWhere((title) => title.isNotEmpty, orElse: () => '');
    if (value != null && value.isNotEmpty) return value;
    return title.value.trim();
  }

  String get sessionSourceLabel {
    final value = sessionLoadSource.value.trim();
    if (value.isEmpty) return 'Session';
    return value;
  }

  String get formattedRemainingTime {
    final minutes = remainingSeconds.value ~/ 60;
    final seconds = remainingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedSessionRemainingTime {
    final minutes = sessionRemainingSeconds.value ~/ 60;
    final seconds = sessionRemainingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> nextExercise() async {
    if (!hasExercises) {
      debugPrint('AI nextExercise skipped: no exercises available');
      return;
    }
    if (isAdvancing.value) {
      debugPrint('AI nextExercise skipped: request already in progress');
      return;
    }

    var current = currentExercise;
    debugPrint(
      'AI nextExercise started: '
      'currentIndex=${currentIndex.value}, '
      'sessionWorkoutId=${current.sessionWorkoutId}, '
      'name=${current.name}, '
      'isCardio=${current.isCardio}, '
      'hasExistingCardioLog=${current.hasExistingCardioLog}, '
      'allExercisesCompleted=$allExercisesCompleted',
    );
    if (current.sessionWorkoutId == null || current.sessionWorkoutId! <= 0) {
      debugPrint(
        'AI nextExercise missing sessionWorkoutId before POST. '
        'Trying recovery from session API for currentIndex=${currentIndex.value}, '
        'workoutId=${current.workoutId}, sessionId=${activeSessionId.value}',
      );
      final recovered = await _recoverCurrentExerciseFromSession();
      if (!recovered) {
        AppLoadingService.showError(
          'Workout Failed',
          'Session workout ID is missing. Please reopen the active session.',
        );
        return;
      }
      current = currentExercise;
      debugPrint(
        'AI nextExercise recovered current exercise: '
        'currentIndex=${currentIndex.value}, '
        'sessionWorkoutId=${current.sessionWorkoutId}, '
        'workoutId=${current.workoutId}, '
        'name=${current.name}',
      );
    }

    if (current.sessionWorkoutId != null && current.sessionWorkoutId! > 0) {
      isAdvancing.value = true;
      debugPrint(
        'Completing session workout: '
        'sessionWorkoutId=${current.sessionWorkoutId}, '
        'order=${current.order}, '
        'name=${current.name}, '
        'isLastExercise=$isLastExercise',
      );

      try {
        if (current.isCardio && !current.hasExistingCardioLog) {
          debugPrint(
            'AI nextExercise will create cardio log from session workout id: '
            'sessionWorkoutId=${current.sessionWorkoutId}, '
            'workoutId=${current.workoutId}, '
            'order=${current.order}, '
            'name=${current.name}',
          );
          await _createCardioLogForCurrentExercise(
            trigger: 'before_next_completion',
          );
        } else if (current.isCardio && current.hasExistingCardioLog) {
          debugPrint(
            'Skipping cardio log creation because cardio_log already exists: '
            'sessionWorkoutId=${current.sessionWorkoutId}',
          );
        }

        final completionNote = current.note.isNotEmpty
            ? current.note
            : 'Completed workout';
        const markSessionCompleteIfFinished = true;
        debugPrint(
          'Completing session workout payload: '
          'sessionWorkoutId=${current.sessionWorkoutId}, '
          'note=$completionNote, '
          'markSessionCompleteIfFinished=$markSessionCompleteIfFinished',
        );
        final completedWorkout = await _sessionApiService
            .completeSessionWorkout(
              current.sessionWorkoutId!,
              CompleteSessionWorkoutRequest(
                note: completionNote,
                markSessionCompleteIfFinished: markSessionCompleteIfFinished,
              ),
            );
        debugPrint(
          'Complete session workout response: '
          'id=${completedWorkout.id}, '
          'order=${completedWorkout.order}, '
          'isCompleted=${completedWorkout.isCompleted}, '
          'note=${completedWorkout.note}, '
          'setLogs=${completedWorkout.setLogs.length}, '
          'hasCardioLog=${completedWorkout.cardioLog != null}, '
          'actualCaloriesBurned=${completedWorkout.actualCaloriesBurned}',
        );
        _applyCompletedWorkoutResult(completedWorkout);
        final refreshed = await _refreshSessionAfterAdvance();
        debugPrint(
          'AI nextExercise refresh result: '
          'sessionWorkoutId=${current.sessionWorkoutId}, '
          'refreshed=$refreshed, '
          'currentIndex=${currentIndex.value}, '
          'completedIndexes=${completedIndexes.join(",")}',
        );
        if (refreshed) {
          return;
        }
      } on AuthException catch (error) {
        debugPrint(
          'Complete session workout auth error: '
          'sessionWorkoutId=${current.sessionWorkoutId}, '
          'message=${error.message}, '
          'statusCode=${error.statusCode}',
        );
        AppLoadingService.showError('Workout Failed', error.message);
        isAdvancing.value = false;
        return;
      } catch (_) {
        debugPrint(
          'Complete session workout failed: '
          'sessionWorkoutId=${current.sessionWorkoutId}',
        );
        AppLoadingService.showError(
          'Workout Failed',
          'Something went wrong. Please try again.',
        );
        isAdvancing.value = false;
        return;
      } finally {
        if (isAdvancing.value) {
          isAdvancing.value = false;
        }
      }
    }

    if (!completedIndexes.contains(currentIndex.value)) {
      completedIndexes.add(currentIndex.value);
      debugPrint(
        'AI nextExercise marked local completion: '
        'currentIndex=${currentIndex.value}, '
        'completedIndexes=${completedIndexes.join(",")}',
      );
    }

    if (currentIndex.value >= exercises.length - 1) {
      remainingSeconds.value = 0;
      debugPrint(
        'All exercises completed for current session flow: '
        'sessionId=${activeSessionId.value}, '
        'completedIndexes=${completedIndexes.join(",")}',
      );
      return;
    }

    currentIndex.value++;
    _elapsedCurrentExerciseSeconds = 0;
    remainingSeconds.value = currentExercise.seconds;
    debugPrint(
      'Moved to next exercise: '
      'index=${currentIndex.value}, '
      'order=${currentExercise.order}, '
      'name=${currentExercise.name}, '
      'seconds=${currentExercise.seconds}',
    );
  }

  Future<void> finishWorkout() async {
    final sessionId = activeSessionId.value ?? sessionData.value?.id;
    if (sessionId == null || sessionId <= 0 || isFinishing.value) {
      debugPrint(
        'AI finishWorkout skipped: '
        'sessionId=$sessionId, '
        'isFinishing=${isFinishing.value}',
      );
      Get.offAllNamed(AppRoute.getBottomNavigationScreen());
      return;
    }

    isFinishing.value = true;
    final durationMinutes = _sessionDurationMinutes;
    const note = 'Workout finished';
    debugPrint(
      'Preparing POST /sessions/sessions/{sessionId}/complete: '
      'sessionId=$sessionId, '
      'elapsedSeconds=$_elapsedSessionSeconds, '
      'completedExercises=${completedIndexes.length}, '
      'totalExercises=${exercises.length}, '
      'durationMinutes=$durationMinutes, '
      'note=$note',
    );
    debugPrint(
      'AI finishWorkout payload: {'
      '"duration_minutes": $durationMinutes, '
      '"note": "$note"'
      '}',
    );

    try {
      final completedSession = await _sessionApiService.completeSession(
        sessionId,
        CompleteSessionRequest(durationMinutes: durationMinutes, note: note),
      );
      debugPrint(
        'Complete session response: '
        'id=${completedSession.id}, '
        'status=${completedSession.status}, '
        'completedAt=${completedSession.completedAt}',
      );
      _handleCompletedSessionExit(message: 'Session finished successfully.');
    } on AuthException catch (error) {
      debugPrint(
        'Complete session auth error: '
        'sessionId=$sessionId, '
        'message=${error.message}, '
        'statusCode=${error.statusCode}',
      );
      if (_isAlreadyCompletedError(error)) {
        _handleCompletedSessionExit(message: 'Session was already completed.');
        return;
      }
      AppLoadingService.showError('Session Failed', error.message);
    } catch (_) {
      debugPrint('Complete session failed: sessionId=$sessionId');
      AppLoadingService.showError(
        'Session Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isFinishing.value = false;
    }
  }

  Future<void> _initializeSession() async {
    final arguments = Get.arguments;
    final incomingSession = arguments is Map ? arguments['session'] : null;
    final firstSessionWorkout = arguments is Map
        ? arguments['first_session_workout']
        : null;
    final requestedSessionId = arguments is Map
        ? _parseInt(arguments['session_id'])
        : null;
    final preferredSessionWorkoutId = arguments is Map
        ? _parseInt(arguments['first_session_workout_id'])
        : null;
    final requestedContentId = arguments is Map
        ? _parseInt(arguments['content_id'])
        : null;
    final preferActiveSession = arguments is Map
        ? arguments['prefer_active_session'] == true
        : false;

    final parsedIncomingSession = _parseActiveWorkoutSession(incomingSession);
    final parsedFirstSessionWorkout = _parseActiveSessionWorkout(
      firstSessionWorkout,
    );

    final shouldRefreshFromActiveSession =
        preferActiveSession ||
        (requestedContentId != null && requestedContentId > 0);

    if (shouldRefreshFromActiveSession) {
      await _loadActiveSession(expectedContentId: requestedContentId);
    }

    if (exercises.isEmpty &&
        requestedSessionId != null &&
        requestedSessionId > 0) {
      await _loadSessionById(
        requestedSessionId,
        expectedContentId: requestedContentId,
      );
    }

    if (exercises.isEmpty &&
        parsedIncomingSession != null &&
        (requestedContentId == null ||
            requestedContentId <= 0 ||
            _matchesContent(parsedIncomingSession, requestedContentId))) {
      _applySession(
        parsedIncomingSession,
        preferredSessionWorkoutId:
            parsedFirstSessionWorkout?.id ?? preferredSessionWorkoutId,
      );
    } else if (exercises.isEmpty &&
        (preferActiveSession || requestedContentId == null)) {
      await _loadActiveSession(expectedContentId: requestedContentId);
    }

    if (exercises.isEmpty) {
      _loadStaticExercises();
    }

    await _ensureCurrentCardioLog();
  }

  void _applyArguments() {
    final arguments = Get.arguments;
    if (arguments is! Map) return;

    final sessionDurationSeconds = _parseInt(
      arguments['session_duration_seconds'],
    );
    if (sessionDurationSeconds != null && sessionDurationSeconds > 0) {
      sessionRemainingSeconds.value = sessionDurationSeconds;
      _hasSessionDuration = true;
    }

    final incomingTitle = arguments['title']?.toString().trim() ?? '';
    if (incomingTitle.isNotEmpty) {
      title.value = incomingTitle;
    }

    final durationsArg = arguments['workout_durations'];
    if (durationsArg is Map) {
      _workoutDurationMap = {
        for (final e in durationsArg.entries)
          (int.tryParse(e.key.toString()) ?? 0):
              (int.tryParse(e.value.toString()) ?? 0),
      };
    }

    final workouts = arguments['workouts'];
    if (workouts is List) {
      final workoutMaps = workouts
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);

      _workoutDistanceMap = {
        for (final item in workoutMaps)
          _parseInt(item['id']) ?? 0:
              double.tryParse(item['distance']?.toString() ?? '') ?? 0,
      };
      _workoutSpeedMap = {
        for (final item in workoutMaps)
          _parseInt(item['id']) ?? 0:
              double.tryParse(item['speed']?.toString() ?? '') ?? 0,
      };
      _workoutInclineMap = {
        for (final item in workoutMaps)
          _parseInt(item['id']) ?? 0:
              double.tryParse(item['incline']?.toString() ?? '') ?? 0,
      };

      final parsedExercises = workoutMaps
          .asMap()
          .entries
          .map((entry) {
            final item = entry.value;
            final workoutId = _parseInt(item['id']);
            final sessionWorkoutId = _parseInt(item['session_workout_id']);
            final order = _parseInt(item['order']) ?? (entry.key + 1);

            debugPrint(
              'AI applyArguments parsed workout item: '
              'sessionWorkoutId=$sessionWorkoutId, '
              'workoutId=$workoutId, '
              'order=$order, '
              'name=${_stringValue(item['name'], fallback: 'Exercise')}',
            );

            return AiExerciseSessionItem(
              sessionWorkoutId: sessionWorkoutId,
              workoutId: workoutId,
              order: order,
              name: _stringValue(item['name'], fallback: 'Exercise'),
              tags: _stringValue(item['tags']),
              details: _stringValue(item['details']),
              seconds: _durationToSeconds(_stringValue(item['duration'])),
              note: _stringValue(item['note']),
              isCardio:
                  _stringValue(item['workout_type']).toLowerCase() == 'cardio',
              actualCaloriesBurned:
                  double.tryParse(
                    item['actual_calories_burned']?.toString() ?? '',
                  ) ??
                  0,
              distance: _workoutDistanceMap[workoutId] ?? 0,
              speed: _workoutSpeedMap[workoutId] ?? 0,
              incline: _workoutInclineMap[workoutId] ?? 0,
            );
          })
          .toList(growable: false);

      if (parsedExercises.isNotEmpty) {
        exercises.assignAll(parsedExercises);
        _elapsedCurrentExerciseSeconds = 0;
        remainingSeconds.value = parsedExercises.first.seconds;
        if (!_hasSessionDuration) {
          sessionRemainingSeconds.value = parsedExercises.fold<int>(
            0,
            (sum, exercise) => sum + exercise.seconds,
          );
          if (sessionRemainingSeconds.value <= 0) {
            sessionRemainingSeconds.value = remainingSeconds.value;
          }
        }
      }
    }
  }

  Future<void> _loadActiveSession({int? expectedContentId}) async {
    isLoading.value = true;
    errorMessage.value = '';
    debugPrint(
      'AI loadActiveSession started: expectedContentId=$expectedContentId',
    );

    try {
      final session = await _sessionApiService.getActiveSession();
      if (expectedContentId != null &&
          expectedContentId > 0 &&
          !_matchesContent(session, expectedContentId)) {
        debugPrint(
          'Ignoring active session because content does not match: '
          'sessionId=${session.id}, expectedContentId=$expectedContentId',
        );
        return;
      }
      debugPrint(
        'Applying active session: '
        'sessionId=${session.id}, workouts=${session.workouts.length}',
      );
      _applySession(session, source: 'Active Session');
    } on AuthException catch (error) {
      debugPrint(
        'AI loadActiveSession auth error: '
        'statusCode=${error.statusCode}, '
        'message=${error.message}',
      );
      if (exercises.isEmpty && error.statusCode != 404) {
        errorMessage.value = error.message;
      }
    } catch (error) {
      debugPrint('AI loadActiveSession failed: error=$error');
      if (exercises.isEmpty) {
        errorMessage.value = 'Something went wrong. Please try again.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadSessionById(int id, {int? expectedContentId}) async {
    isLoading.value = true;
    errorMessage.value = '';
    debugPrint(
      'AI loadSessionById started: sessionId=$id, expectedContentId=$expectedContentId',
    );

    try {
      final session = await _sessionApiService.getSessionById(id);
      if (expectedContentId != null &&
          expectedContentId > 0 &&
          !_matchesContent(session, expectedContentId)) {
        debugPrint(
          'Ignoring session by id because content does not match: '
          'sessionId=${session.id}, expectedContentId=$expectedContentId',
        );
        return;
      }
      debugPrint(
        'Applying session by id: '
        'sessionId=${session.id}, workouts=${session.workouts.length}',
      );
      _applySession(session, source: 'Session Details');
    } on AuthException catch (error) {
      debugPrint(
        'AI loadSessionById auth error: '
        'sessionId=$id, '
        'statusCode=${error.statusCode}, '
        'message=${error.message}',
      );
      errorMessage.value = error.message;
    } catch (error) {
      debugPrint('AI loadSessionById failed: sessionId=$id, error=$error');
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void _applySession(
    ActiveWorkoutSession session, {
    int? preferredSessionWorkoutId,
    String? source,
  }) {
    debugPrint(
      'AI applySession: '
      'sessionId=${session.id}, '
      'status=${session.status}, '
      'currentWorkoutOrder=${session.currentWorkoutOrder}, '
      'preferredSessionWorkoutId=$preferredSessionWorkoutId, '
      'workouts=${session.workouts.length}',
    );
    activeSessionId.value = session.id;
    sessionData.value = session;
    if (source != null && source.trim().isNotEmpty) {
      sessionLoadSource.value = source.trim();
    }
    _hasCompletedSession = session.status.toLowerCase() == 'completed';
    _activeUserWeightKg =
        session.userWeightKg == null || session.userWeightKg! <= 0
        ? 1
        : session.userWeightKg!;
    if (!_hasSessionDuration && session.durationMinutes > 0) {
      sessionRemainingSeconds.value = session.durationMinutes * 60;
      _hasSessionDuration = true;
    }

    final sortedWorkouts = [...session.workouts]
      ..sort((a, b) => a.order.compareTo(b.order));
    debugPrint(
      'AI applySession workout ids from session payload: '
      '${sortedWorkouts.map((item) => 'sessionWorkoutId=${item.id}/workoutId=${item.workout.id}/order=${item.order}').join(', ')}',
    );

    final parsedExercises = sortedWorkouts
        .map(
          (item) => AiExerciseSessionItem(
            sessionWorkoutId: item.id,
            workoutId: item.workout.id,
            order: item.order,
            name: _stringValue(item.workout.name, fallback: 'Exercise'),
            tags: _stringValue(_sessionWorkoutTags(item)),
            details: _stringValue(_sessionWorkoutDetails(item)),
            seconds: _sessionWorkoutSeconds(item),
            note: _stringValue(item.note),
            isCardio: item.workout.workoutType.toLowerCase() == 'cardio',
            hasExistingCardioLog: item.cardioLog != null,
            actualCaloriesBurned: item.actualCaloriesBurned > 0
                ? item.actualCaloriesBurned
                : (item.cardioLog?.caloriesBurned ?? 0),
            distance: _workoutDistanceMap[item.workout.id] ?? 0,
            speed: _workoutSpeedMap[item.workout.id] ?? 0,
            incline: _workoutInclineMap[item.workout.id] ?? 0,
          ),
        )
        .toList(growable: false);

    if (parsedExercises.isEmpty) return;

    final sessionTitle = sortedWorkouts
        .map((item) => _stringValue(item.content.title).trim())
        .firstWhere(
          (value) => value.isNotEmpty,
          orElse: () => _stringValue(title.value, fallback: 'Workout Session'),
        );
    if (sessionTitle.isNotEmpty) {
      title.value = sessionTitle;
    }

    exercises.assignAll(parsedExercises);
    completedIndexes.assignAll(
      sortedWorkouts
          .asMap()
          .entries
          .where((entry) => entry.value.isCompleted)
          .map((entry) => entry.key)
          .toList(growable: false),
    );

    final allCompletedFromServer =
        session.status.toLowerCase() == 'completed' ||
        sortedWorkouts.every((item) => item.isCompleted);
    if (allCompletedFromServer) {
      currentIndex.value = parsedExercises.length - 1;
      remainingSeconds.value = 0;
      sessionRemainingSeconds.value = 0;
      debugPrint(
        'AI applySession detected completed session: '
        'sessionId=${session.id}, '
        'completedIndexes=${completedIndexes.join(",")}',
      );
      return;
    }

    final preferredIndex = preferredSessionWorkoutId == null
        ? -1
        : parsedExercises.indexWhere(
            (item) => item.sessionWorkoutId == preferredSessionWorkoutId,
          );
    final serverIndex = (session.currentWorkoutOrder - 1).clamp(
      0,
      parsedExercises.length - 1,
    );
    final firstIncompleteIndex = sortedWorkouts.indexWhere(
      (item) => !item.isCompleted,
    );
    final preferredIncompleteIndex =
        preferredIndex >= 0 && !sortedWorkouts[preferredIndex].isCompleted
        ? preferredIndex
        : -1;
    final serverPointsToIncomplete =
        serverIndex >= 0 &&
        serverIndex < sortedWorkouts.length &&
        !sortedWorkouts[serverIndex].isCompleted;
    final nextIndex = preferredIncompleteIndex >= 0
        ? preferredIncompleteIndex
        : serverPointsToIncomplete
        ? serverIndex
        : (firstIncompleteIndex >= 0 ? firstIncompleteIndex : serverIndex);
    currentIndex.value = nextIndex;
    _elapsedCurrentExerciseSeconds = 0;
    remainingSeconds.value = currentExercise.seconds;
    if (!_hasSessionDuration) {
      sessionRemainingSeconds.value = session.durationMinutes > 0
          ? session.durationMinutes * 60
          : parsedExercises.fold<int>(
              0,
              (sum, exercise) => sum + exercise.seconds,
            );
      if (sessionRemainingSeconds.value <= 0) {
        sessionRemainingSeconds.value = currentExercise.seconds;
      }
    }
    debugPrint(
      'AI applySession selected current exercise: '
      'sessionId=${session.id}, '
      'currentIndex=${currentIndex.value}, '
      'sessionWorkoutId=${currentExercise.sessionWorkoutId}, '
      'name=${currentExercise.name}, '
      'seconds=${currentExercise.seconds}, '
      'completedIndexes=${completedIndexes.join(",")}',
    );
  }

  void _loadStaticExercises() {
    if (exercises.isNotEmpty) return;

    const staticExercises = <AiExerciseSessionItem>[
      AiExerciseSessionItem(
        order: 1,
        name: 'Squat Jump',
        tags: 'Legs . Power',
        seconds: 45,
      ),
      AiExerciseSessionItem(
        order: 2,
        name: 'Push-Up',
        tags: 'Chest . Triceps',
        seconds: 45,
      ),
      AiExerciseSessionItem(
        order: 3,
        name: 'Mountain Climber',
        tags: 'Core . Cardio',
        seconds: 45,
      ),
      AiExerciseSessionItem(
        order: 4,
        name: 'Glute Bridge',
        tags: 'Glutes . Hamstrings',
        seconds: 45,
      ),
      AiExerciseSessionItem(
        order: 5,
        name: 'Plank Hold',
        tags: 'Core . Abs',
        seconds: 45,
      ),
    ];

    exercises.assignAll(staticExercises);
    _elapsedCurrentExerciseSeconds = 0;
    remainingSeconds.value = currentExercise.seconds;
    if (!_hasSessionDuration) {
      sessionRemainingSeconds.value = staticExercises.fold<int>(
        0,
        (sum, exercise) => sum + exercise.seconds,
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSessionSeconds++;
      _elapsedCurrentExerciseSeconds++;
      if (sessionRemainingSeconds.value > 0) {
        sessionRemainingSeconds.value--;
      }
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      }
    });
  }

  Future<void> _ensureCurrentCardioLog() async {
    if (!hasExercises) return;

    final current = currentExercise;
    if (!current.isCardio ||
        current.hasExistingCardioLog ||
        current.sessionWorkoutId == null ||
        current.sessionWorkoutId! <= 0) {
      return;
    }

    debugPrint(
      'AI ensureCurrentCardioLog using session-loaded workout id: '
      'sessionWorkoutId=${current.sessionWorkoutId}, '
      'workoutId=${current.workoutId}, '
      'order=${current.order}, '
      'name=${current.name}',
    );
    await _createCardioLogForCurrentExercise(trigger: 'session_start');
  }

  Future<void> _createCardioLogForCurrentExercise({
    required String trigger,
  }) async {
    if (!hasExercises) return;

    final current = currentExercise;
    final sessionWorkoutId = current.sessionWorkoutId;
    if (sessionWorkoutId == null || sessionWorkoutId <= 0) {
      debugPrint(
        'Create cardio log skipped: '
        'trigger=$trigger, sessionWorkoutId=$sessionWorkoutId',
      );
      return;
    }

    final rawElapsedSeconds = _elapsedCurrentExerciseSeconds <= 0
        ? current.seconds
        : _elapsedCurrentExerciseSeconds;
    final cardioMinutes = (rawElapsedSeconds / 60).ceil().clamp(1, 1440);
    debugPrint(
      'POST /sessions/cardio-log prepared from session workout ids: '
      'trigger=$trigger, '
      'sessionWorkoutId=$sessionWorkoutId, '
      'workoutId=${current.workoutId}, '
      'order=${current.order}, '
      'timeMinutes=$cardioMinutes, '
      'distance=${current.distance}, '
      'speed=${current.speed}, '
      'incline=${current.incline}, '
      'userWeightKg=$_activeUserWeightKg',
    );

    try {
      final cardioLog = await _sessionApiService.createCardioLog(
        CreateCardioLogRequest(
          sessionWorkoutId: sessionWorkoutId,
          timeMinutes: cardioMinutes,
          distance: current.distance,
          speed: current.speed,
          incline: current.incline,
          userWeightKg: _activeUserWeightKg,
        ),
      );
      debugPrint(
        'POST /sessions/cardio-log success: '
        'trigger=$trigger, '
        'sessionWorkoutId=$sessionWorkoutId, '
        'cardioLogId=${cardioLog.id}, '
        'timeMinutes=${cardioLog.timeMinutes}, '
        'caloriesBurned=${cardioLog.caloriesBurned}',
      );
      _markCurrentExerciseHasCardioLog(
        caloriesBurned: cardioLog.caloriesBurned,
      );
    } on AuthException catch (error) {
      debugPrint(
        'POST /sessions/cardio-log auth error: '
        'trigger=$trigger, '
        'sessionWorkoutId=$sessionWorkoutId, '
        'message=${error.message}, '
        'statusCode=${error.statusCode}',
      );
    } catch (error) {
      debugPrint(
        'POST /sessions/cardio-log failed: '
        'trigger=$trigger, '
        'sessionWorkoutId=$sessionWorkoutId, '
        'error=$error',
      );
    }
  }

  void _markCurrentExerciseHasCardioLog({double? caloriesBurned}) {
    if (!hasExercises) return;

    final index = currentIndex.value;
    exercises[index] = exercises[index].copyWith(
      hasExistingCardioLog: true,
      actualCaloriesBurned:
          caloriesBurned ?? exercises[index].actualCaloriesBurned,
    );
    exercises.refresh();
  }

  void _applyCompletedWorkoutResult(ActiveSessionWorkout workout) {
    if (!hasExercises) return;

    final index = currentIndex.value;
    if (index < 0 || index >= exercises.length) return;

    exercises[index] = exercises[index].copyWith(
      hasExistingCardioLog: workout.cardioLog != null,
      actualCaloriesBurned: workout.actualCaloriesBurned > 0
          ? workout.actualCaloriesBurned
          : (workout.cardioLog?.caloriesBurned ?? 0),
    );
    exercises.refresh();
  }

  Future<bool> _refreshSessionAfterAdvance() async {
    final sessionId = activeSessionId.value;
    if (sessionId == null || sessionId <= 0) {
      debugPrint('AI refreshSessionAfterAdvance skipped: sessionId=$sessionId');
      return false;
    }

    try {
      debugPrint('AI refreshSessionAfterAdvance started: sessionId=$sessionId');
      final session = await _sessionApiService.getSessionById(sessionId);
      _applySession(session);
      debugPrint(
        'AI refreshSessionAfterAdvance success: '
        'sessionId=$sessionId, '
        'status=${session.status}, '
        'currentWorkoutOrder=${session.currentWorkoutOrder}',
      );
      return true;
    } on AuthException catch (error) {
      debugPrint(
        'Refresh session after advance auth error: '
        'sessionId=$sessionId, '
        'message=${error.message}, '
        'statusCode=${error.statusCode}',
      );
      return false;
    } catch (error) {
      debugPrint(
        'Refresh session after advance failed: '
        'sessionId=$sessionId, error=$error',
      );
      return false;
    }
  }

  Future<bool> _recoverCurrentExerciseFromSession() async {
    final sessionId = activeSessionId.value ?? sessionData.value?.id;
    if (sessionId == null || sessionId <= 0) {
      debugPrint(
        'AI recoverCurrentExerciseFromSession skipped: invalid sessionId=$sessionId',
      );
      return false;
    }

    try {
      debugPrint(
        'AI recoverCurrentExerciseFromSession started: sessionId=$sessionId',
      );
      final session = await _sessionApiService.getSessionById(sessionId);
      _applySession(session, source: 'Session Recovery');
      final recoveredId = currentExercise.sessionWorkoutId;
      debugPrint(
        'AI recoverCurrentExerciseFromSession result: '
        'sessionId=$sessionId, '
        'currentIndex=${currentIndex.value}, '
        'sessionWorkoutId=$recoveredId',
      );
      return recoveredId != null && recoveredId > 0;
    } on AuthException catch (error) {
      debugPrint(
        'AI recoverCurrentExerciseFromSession auth error: '
        'sessionId=$sessionId, '
        'message=${error.message}, '
        'statusCode=${error.statusCode}',
      );
      return false;
    } catch (error) {
      debugPrint(
        'AI recoverCurrentExerciseFromSession failed: '
        'sessionId=$sessionId, error=$error',
      );
      return false;
    }
  }

  int _durationToSeconds(String value) {
    final parts = value.split(':');
    if (parts.length != 3) return 45;

    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    final seconds = int.tryParse(parts[2]) ?? 0;
    final total = (hours * 3600) + (minutes * 60) + seconds;

    return total > 0 ? total : 45;
  }

  int get _sessionDurationMinutes {
    return (_elapsedSessionSeconds ~/ 60).clamp(0, 1440);
  }

  int? _parseInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '');
  }

  String _stringValue(dynamic value, {String fallback = ''}) {
    final text = value?.toString();
    if (text == null) return fallback;
    if (text.toLowerCase() == 'null') return fallback;
    return text;
  }

  ActiveWorkoutSession? _parseActiveWorkoutSession(dynamic value) {
    if (value is ActiveWorkoutSession) {
      return value;
    }

    if (value is Map) {
      final json = Map<String, dynamic>.from(value);
      final nestedSession = json['session'];
      if (nestedSession is Map) {
        return ActiveWorkoutSession.fromJson(
          Map<String, dynamic>.from(nestedSession),
        );
      }
      return ActiveWorkoutSession.fromJson(json);
    }

    return null;
  }

  ActiveSessionWorkout? _parseActiveSessionWorkout(dynamic value) {
    if (value is ActiveSessionWorkout) {
      return value;
    }

    if (value is Map) {
      final json = Map<String, dynamic>.from(value);
      return ActiveSessionWorkout.fromJson(json);
    }

    return null;
  }

  bool _matchesContent(ActiveWorkoutSession session, int contentId) {
    return session.workouts.any((item) => item.content.id == contentId);
  }

  String _sessionWorkoutTags(ActiveSessionWorkout item) {
    final parts = <String>[
      if (item.workout.workoutType.trim().isNotEmpty)
        _titleCase(item.workout.workoutType),
      if (item.workout.metValue > 0)
        '${_formatNumber(item.workout.metValue)} MET',
    ];

    return parts.join(' . ');
  }

  String _sessionWorkoutDetails(ActiveSessionWorkout item) {
    final parts = <String>[
      if (item.workout.sets.trim().isNotEmpty) '${item.workout.sets} sets',
      if (item.workout.reps.trim().isNotEmpty) item.workout.reps,
      if (item.workout.rest.trim().isNotEmpty &&
          item.workout.rest.trim().toLowerCase() != 'n/a')
        item.workout.rest,
    ];

    return parts.join(' . ');
  }

  int _sessionWorkoutSeconds(ActiveSessionWorkout item) {
    final cardioSeconds = (item.cardioLog?.timeMinutes ?? 0) * 60;
    if (cardioSeconds > 0) return cardioSeconds;

    final fromMap = _workoutDurationMap[item.workout.id];
    if (fromMap != null && fromMap > 0) return fromMap;

    return 45;
  }

  void _handleCompletedSessionExit({required String message}) {
    _hasCompletedSession = true;
    activeSessionId.value = null;
    AppLoadingService.showSuccess('Workout Complete!', message);
    Get.offAllNamed(AppRoute.getBottomNavigationScreen());
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  String _titleCase(String value) {
    return value
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) {
          final lower = part.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .join(' ');
  }

  bool _isAlreadyCompletedError(AuthException error) {
    final message = error.message.toLowerCase();
    return message.contains('already') && message.contains('complete');
  }
}
