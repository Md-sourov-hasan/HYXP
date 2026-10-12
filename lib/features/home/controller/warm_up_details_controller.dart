import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/home/model/content_item.dart';
import 'package:hawiisaac/features/home/services/content_api_service.dart';
import 'package:hawiisaac/features/scan/model/workout_item.dart';
import 'package:hawiisaac/features/scan/services/equipment_api_service.dart';
import 'package:hawiisaac/features/sessions/model/session_models.dart';
import 'package:hawiisaac/features/sessions/services/session_api_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class WarmUpExerciseItem {
  final String name;
  final String tags;
  final String metric;
  final String details;
  final bool isFree;

  const WarmUpExerciseItem({
    required this.name,
    required this.tags,
    required this.metric,
    this.details = '',
    this.isFree = false,
  });
}

class WarmUpDetailStat {
  final String value;
  final String label;

  const WarmUpDetailStat({required this.value, required this.label});
}

class WarmUpDetailsController extends GetxController {
  final EquipmentApiService _equipmentApiService = EquipmentApiService();
  final ContentApiService _contentApiService = ContentApiService();
  final SessionApiService _sessionApiService = SessionApiService();

  final Rxn<Map<String, String>> workout = Rxn<Map<String, String>>();
  final Rxn<WorkoutItem> workoutDetail = Rxn<WorkoutItem>();
  final Rxn<ContentItem> contentDetail = Rxn<ContentItem>();
  final RxBool isLoading = false.obs;
  final RxBool isStartingExercise = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Map) {
      workout.value = args.map((k, v) => MapEntry(k.toString(), v.toString()));
    }

    final contentId = int.tryParse(workout.value?['content_id'] ?? '');
    if (contentId != null && contentId > 0) {
      debugPrint(
        'WarmUpDetails init: loading content detail for id=$contentId',
      );
      fetchContentDetail(contentId);
      return;
    }

    final id = int.tryParse(workout.value?['id'] ?? '');
    if (id != null && id > 0) {
      debugPrint('WarmUpDetails init: loading workout detail for id=$id');
      fetchWorkoutDetail(id);
    }
  }

  String get appBarTitle => 'Body warm-up';

  String get coverImageUrl =>
      contentDetail.value?.image ??
      workoutDetail.value?.banner ??
      workout.value?['image'] ??
      '';

  String get contentFeedLabel => contentDetail.value?.feedLabel ?? '';

  String get contentTypeLabel {
    final value = contentDetail.value?.contentType.trim() ?? '';
    if (value.isEmpty) return '';
    return _titleCase(value);
  }

  bool get hasContentVideo {
    final value =
        contentDetail.value?.video.trim() ?? workout.value?['video'] ?? '';
    return value.isNotEmpty;
  }

  String get totalContentDurationLabel {
    final seconds = totalContentDurationSeconds;
    if (seconds <= 0) return '-';

    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    final parts = <String>[
      if (hours > 0) '${hours}h',
      if (minutes > 0) '${minutes}m',
      if (remainingSeconds > 0 && hours == 0) '${remainingSeconds}s',
    ];
    return parts.join(' ');
  }

  bool get isContentDetail => _resolvedContentId != null;

  int? get _resolvedContentId {
    final loadedContentId = contentDetail.value?.id;
    if (loadedContentId != null && loadedContentId > 0) {
      return loadedContentId;
    }

    final argumentContentId = int.tryParse(workout.value?['content_id'] ?? '');
    if (argumentContentId != null && argumentContentId > 0) {
      return argumentContentId;
    }

    return null;
  }

  String get sectionTitle => isContentDetail ? 'Workouts' : "Today's Exercise";

  String get workoutTitle {
    final title =
        contentDetail.value?.title ??
        workoutDetail.value?.name ??
        workout.value?['title'];
    if (title == null || title.trim().isEmpty) return 'Bodyweight Burn';
    return title;
  }

  String get workoutMeta {
    final content = contentDetail.value;
    if (content != null) {
      final parts = <String>[
        if (content.feedLabel.isNotEmpty) content.feedLabel,
        if (content.contentType.trim().isNotEmpty)
          _titleCase(content.contentType),
        if (content.workouts.isNotEmpty) '${content.workouts.length} exercises',
        content.isFree ? 'Free' : 'Premium',
      ];

      if (parts.isNotEmpty) {
        return parts.join(' . ');
      }
    }

    final meta =
        workoutDetail.value?.meta.trim() ?? workout.value?['meta']?.trim();
    if (meta == null || meta.isEmpty) return 'No equipment . Chest . Beginner';

    // If meta comes like "6 min, Beginner", normalize a bit for UI.
    return meta.replaceAll(',', ' .');
  }

  String get overviewText {
    final content = contentDetail.value;
    if (content == null) return '';

    final parts = <String>[
      if (content.summary.trim().isNotEmpty) content.summary.trim(),
      if (content.body.trim().isNotEmpty) content.body.trim(),
    ];

    return parts.join('\n\n');
  }

  List<WarmUpExerciseItem> get todayExercises {
    final content = contentDetail.value;
    if (content != null && content.workouts.isNotEmpty) {
      return content.workouts
          .map(
            (item) => WarmUpExerciseItem(
              name: item.name,
              tags: _workoutTags(item),
              metric: _workoutMetric(item),
              details: _workoutDetails(item),
              isFree: item.isFree,
            ),
          )
          .toList(growable: false);
    }

    final detail = workoutDetail.value;
    if (detail != null && detail.uses.isNotEmpty) {
      return detail.uses
          .asMap()
          .entries
          .map((entry) {
            return WarmUpExerciseItem(
              name: _titleCase(entry.value),
              tags: detail.tags.isNotEmpty
                  ? detail.tags.replaceAll(',', ' .')
                  : detail.equipment.name,
              metric: detail.rest.isNotEmpty ? detail.rest : detail.reps,
              isFree: true,
            );
          })
          .toList(growable: false);
    }

    final fallbackTitle = workout.value?['title'] ?? workoutTitle;
    return <WarmUpExerciseItem>[
      WarmUpExerciseItem(
        name: fallbackTitle,
        tags:
            workout.value?['description']?.replaceAll(',', ' .') ??
            workout.value?['tags']?.replaceAll(',', ' .') ??
            workoutMeta,
        metric: isContentDetail
            ? ''
            : workout.value?['rest'] ?? workout.value?['reps'] ?? '-',
        isFree: true,
      ),
    ];
  }

  int get exercisesCount => todayExercises.length;

  List<WarmUpDetailStat> get contentStats {
    final content = contentDetail.value;
    if (content == null) return const [];

    return <WarmUpDetailStat>[
      WarmUpDetailStat(
        value: content.workouts.length.toString(),
        label: 'Exercises',
      ),
      WarmUpDetailStat(value: totalContentDurationLabel, label: 'Total Time'),
      WarmUpDetailStat(value: content.bookmarkCount.toString(), label: 'Saves'),
      WarmUpDetailStat(value: content.viewCount.toString(), label: 'Views'),
    ];
  }

  int get totalContentDurationSeconds {
    final content = contentDetail.value;
    if (content == null || content.workouts.isEmpty) return 0;
    return content.workouts.fold<int>(
      0,
      (sum, w) => sum + _durationStringToSeconds(w.duration),
    );
  }

  int _durationStringToSeconds(String value) {
    final parts = value.split(':');
    if (parts.length != 3) return 0;
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    final seconds = int.tryParse(parts[2]) ?? 0;
    return (hours * 3600) + (minutes * 60) + seconds;
  }

  String get setsValue =>
      workoutDetail.value?.sets ?? workout.value?['sets'] ?? '-';

  String get repsValue =>
      workoutDetail.value?.reps ?? workout.value?['reps'] ?? '-';

  String get restValue =>
      workoutDetail.value?.rest ?? workout.value?['rest'] ?? '-';

  Future<void> fetchContentDetail(int id) async {
    isLoading.value = true;
    errorMessage.value = '';
    debugPrint('WarmUpDetails fetchContentDetail started: id=$id');

    try {
      contentDetail.value = await _contentApiService.getContentById(id);
      final content = contentDetail.value;
      debugPrint(
        'WarmUpDetails fetchContentDetail success: '
        'id=${content?.id}, '
        'title=${content?.title}, '
        'feedType=${content?.feedType}, '
        'workouts=${content?.workouts.length}, '
        'image=${content?.image}',
      );
    } on AuthException catch (error) {
      errorMessage.value = error.message;
      debugPrint(
        'WarmUpDetails fetchContentDetail auth error: '
        'id=$id, message=${error.message}, statusCode=${error.statusCode}',
      );
      _showError(error.message);
    } catch (error, stackTrace) {
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('WarmUpDetails fetchContentDetail unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      _showError(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWorkoutDetail(int id) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final detail = await _equipmentApiService.getWorkoutById(id);
      workoutDetail.value = detail;
      workout.value = _workoutToMap(detail);
    } on AuthException catch (error) {
      errorMessage.value = error.message;
      _showError(error.message);
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
      _showError(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onStartExercise() async {
    final contentId = _resolvedContentId;
    if (contentId != null && contentId > 0) {
      final content = contentDetail.value;
      if (isStartingExercise.value) return;
      isStartingExercise.value = true;
      debugPrint('Starting content log for contentId=$contentId');

      try {
        final response = await _contentApiService.startContentLog(contentId);
        debugPrint(
          'Start content log response: '
          'sessionId=${response.session.id}, '
          'currentWorkoutOrder=${response.session.currentWorkoutOrder}, '
          'firstWorkoutId=${response.firstSessionWorkout.id}, '
          'totalSessionWorkouts=${response.session.workouts.length}',
        );
        final contentWorkoutsById = <int, ContentWorkout>{
          for (final workout in content?.workouts ?? const <ContentWorkout>[])
            workout.id: workout,
        };
        final computedDuration = response.session.workouts.fold<int>(
          0,
          (sum, item) =>
              sum +
              (_durationStringToSeconds(
                contentWorkoutsById[item.workout.id]?.duration ?? '',
              )),
        );
        final workoutDurations = <int, int>{
          for (final item in response.session.workouts)
            if (_durationStringToSeconds(
                  contentWorkoutsById[item.workout.id]?.duration ?? '',
                ) >
                0)
              item.workout.id: _durationStringToSeconds(
                contentWorkoutsById[item.workout.id]?.duration ?? '',
              ),
        };
        final workoutPayloads = response.session.workouts
            .map((item) {
              final contentWorkout = contentWorkoutsById[item.workout.id];
              final fallbackWorkout = ContentWorkout(
                id: item.workout.id,
                name: item.workout.name,
                workoutType: item.workout.workoutType,
                metValue: item.workout.metValue,
                time: '',
                duration: '',
                distance: 0,
                speed: 0,
                incline: 0,
                isFree: true,
              );
              final sourceWorkout = contentWorkout ?? fallbackWorkout;

              debugPrint(
                'Start content log workout mapped: '
                'sessionWorkoutId=${item.id}, '
                'order=${item.order}, '
                'workoutId=${item.workout.id}, '
                'name=${item.workout.name}, '
                'sets=${item.workout.sets}, '
                'reps=${item.workout.reps}, '
                'rest=${item.workout.rest}',
              );

              return <String, dynamic>{
                'session_workout_id': item.id,
                'order': item.order,
                'id': item.workout.id,
                'name': item.workout.name,
                'tags': _workoutTags(sourceWorkout),
                'details': _sessionWorkoutDetails(item),
                'duration':
                    contentWorkout?.duration ?? contentWorkout?.time ?? '',
                'workout_type': item.workout.workoutType,
                'distance': contentWorkout?.distance ?? 0,
                'speed': contentWorkout?.speed ?? 0,
                'incline': contentWorkout?.incline ?? 0,
                'note': item.note,
                'actual_calories_burned': item.actualCaloriesBurned,
              };
            })
            .toList(growable: false);
        Get.toNamed(
          AppRoute.getAiExerciseSessionScreen(),
          arguments: <String, dynamic>{
            'session_id': response.session.id,
            'content_id': contentId,
            'prefer_active_session': true,
            'session_duration_seconds': computedDuration > 0
                ? computedDuration
                : response.session.durationMinutes * 60,
            'workout_durations': workoutDurations,
            'workouts': workoutPayloads,
            'session': response.session.toJson(),
            'first_session_workout': response.firstSessionWorkout.toJson(),
            'first_session_workout_id': response.firstSessionWorkout.id,
            'title': response.firstSessionWorkout.content.title.isNotEmpty
                ? response.firstSessionWorkout.content.title
                : workoutTitle,
          },
        );
      } on AuthException catch (error) {
        debugPrint(
          'Start content log auth error: '
          'contentId=$contentId, '
          'message=${error.message}, '
          'statusCode=${error.statusCode}',
        );
        AppLoadingService.showError('Start Failed', error.message);
      } catch (_) {
        debugPrint('Start content log failed: contentId=$contentId');
        AppLoadingService.showError(
          'Start Failed',
          'Something went wrong. Please try again.',
        );
      } finally {
        isStartingExercise.value = false;
      }
      return;
    }

    final workoutId =
        workoutDetail.value?.id ?? int.tryParse(workout.value?['id'] ?? '');
    if (workoutId == null || workoutId <= 0) {
      AppLoadingService.showError(
        'Start Failed',
        'Workout information is missing.',
      );
      return;
    }

    if (isStartingExercise.value) return;
    isStartingExercise.value = true;
    debugPrint('Starting workout log for workoutId=$workoutId');

    try {
      final response = await _sessionApiService.startWorkoutLog(workoutId);
      debugPrint(
        'Start workout log response: '
        'sessionId=${response.session.id}, '
        'currentWorkoutOrder=${response.session.currentWorkoutOrder}, '
        'firstWorkoutId=${response.firstSessionWorkout.id}',
      );
      Get.toNamed(
        AppRoute.getLoggingScreen(),
        arguments: <String, dynamic>{
          'session_id': response.session.id,
          'session_workout_id': response.firstSessionWorkout.id,
          'title': response.firstSessionWorkout.workout.name.isNotEmpty
              ? response.firstSessionWorkout.workout.name
              : workoutTitle,
          'sets': response.firstSessionWorkout.workout.sets.isNotEmpty
              ? response.firstSessionWorkout.workout.sets
              : setsValue,
          'reps': response.firstSessionWorkout.workout.reps.isNotEmpty
              ? response.firstSessionWorkout.workout.reps
              : repsValue,
          'rest': response.firstSessionWorkout.workout.rest.isNotEmpty
              ? response.firstSessionWorkout.workout.rest
              : restValue,
          'time': workoutDetail.value?.time ?? workout.value?['time'] ?? '',
          'duration':
              workoutDetail.value?.duration ?? workout.value?['duration'] ?? '',
          'distance':
              workoutDetail.value?.distance.toString() ??
              workout.value?['distance'] ??
              '',
          'speed':
              workoutDetail.value?.speed.toString() ??
              workout.value?['speed'] ??
              '',
          'incline':
              workoutDetail.value?.incline.toString() ??
              workout.value?['incline'] ??
              '',
          'tags': workoutDetail.value?.tags ?? workout.value?['tags'] ?? '',
          'is_cardio':
              response.firstSessionWorkout.workout.workoutType.toLowerCase() ==
                  'cardio' ||
              (workoutDetail.value?.time.isNotEmpty ?? false) ||
              (workoutDetail.value?.duration.isNotEmpty ?? false) ||
              ((workoutDetail.value?.distance ?? 0) > 0) ||
              ((workoutDetail.value?.speed ?? 0) > 0) ||
              ((workoutDetail.value?.incline ?? 0) > 0),
          'session': response.session.toJson(),
          'first_session_workout': response.firstSessionWorkout.toJson(),
        },
      );
    } on AuthException catch (error) {
      debugPrint(
        'Start workout log auth error: '
        'workoutId=$workoutId, '
        'message=${error.message}, '
        'statusCode=${error.statusCode}',
      );
      AppLoadingService.showError('Start Failed', error.message);
    } catch (_) {
      debugPrint('Start workout log failed: workoutId=$workoutId');
      AppLoadingService.showError(
        'Start Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isStartingExercise.value = false;
    }
  }

  Map<String, String> _workoutToMap(WorkoutItem detail) {
    return <String, String>{
      'id': detail.id.toString(),
      'title': detail.name,
      'description': detail.description,
      'meta': detail.meta,
      'image': detail.banner,
      'category': detail.category.name,
      'equipment': detail.equipment.name,
      'tags': detail.tags,
      'sets': detail.sets,
      'reps': detail.reps,
      'rest': detail.rest,
      'time': detail.time,
      'duration': detail.duration,
      'distance': detail.distance.toString(),
      'speed': detail.speed.toString(),
      'incline': detail.incline.toString(),
      'video': detail.video,
    };
  }

  void _showError(String message) {
    AppLoadingService.showError('Workout Failed', message);
  }

  String _workoutTags(ContentWorkout workout) {
    final parts = <String>[
      if (workout.workoutType.trim().isNotEmpty)
        _titleCase(workout.workoutType),
      if (workout.metValue > 0) '${_formatNumber(workout.metValue)} MET',
    ];

    return parts.join(' . ');
  }

  String _workoutMetric(ContentWorkout workout) {
    final time = _formatDuration(workout.time);
    if (time.isNotEmpty) return time;

    final duration = _formatDuration(workout.duration);
    if (duration.isNotEmpty) return duration;

    if (workout.distance > 0) {
      return '${_formatNumber(workout.distance)} km';
    }

    return '';
  }

  String _workoutDetails(ContentWorkout workout) {
    final parts = <String>[
      if (workout.speed > 0) '${_formatNumber(workout.speed)} km/h',
      if (workout.incline > 0) 'Incline ${_formatNumber(workout.incline)}',
    ];

    return parts.join(' . ');
  }

  String _sessionWorkoutDetails(ActiveSessionWorkout item) {
    final parts = <String>[
      if (item.workout.sets.trim().isNotEmpty &&
          item.workout.sets.trim().toLowerCase() != 'n/a')
        '${item.workout.sets} sets',
      if (item.workout.reps.trim().isNotEmpty &&
          item.workout.reps.trim().toLowerCase() != 'n/a')
        item.workout.reps,
      if (item.workout.rest.trim().isNotEmpty &&
          item.workout.rest.trim().toLowerCase() != 'n/a')
        item.workout.rest,
    ];

    return parts.join(' . ');
  }

  String _formatDuration(String value) {
    final parts = value.split(':');
    if (parts.length != 3) return value;

    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    final seconds = int.tryParse(parts[2]) ?? 0;

    final formattedParts = <String>[
      if (hours > 0) '${hours}h',
      if (minutes > 0) '${minutes}m',
      if (seconds > 0 && hours == 0) '${seconds}s',
    ];

    return formattedParts.join(' ');
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
}
