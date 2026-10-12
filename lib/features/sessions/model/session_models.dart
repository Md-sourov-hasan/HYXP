class CreateSessionRequest {
  const CreateSessionRequest({
    required this.date,
    required this.durationMinutes,
  });

  final String date;
  final int durationMinutes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'date': date, 'duration_minutes': durationMinutes};
  }
}

class CompleteSessionWorkoutRequest {
  const CompleteSessionWorkoutRequest({
    required this.note,
    required this.markSessionCompleteIfFinished,
  });

  final String note;
  final bool markSessionCompleteIfFinished;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'note': note,
      'mark_session_complete_if_finished': markSessionCompleteIfFinished,
    };
  }
}

class CompleteSessionRequest {
  const CompleteSessionRequest({
    required this.durationMinutes,
    required this.note,
  });

  final int durationMinutes;
  final String note;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'duration_minutes': durationMinutes, 'note': note};
  }
}

class CreateCardioLogRequest {
  const CreateCardioLogRequest({
    required this.sessionWorkoutId,
    required this.timeMinutes,
    required this.distance,
    required this.speed,
    required this.incline,
    required this.userWeightKg,
  });

  final int sessionWorkoutId;
  final int timeMinutes;
  final double distance;
  final double speed;
  final double incline;
  final double userWeightKg;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'session_workout_id': sessionWorkoutId,
      'time_minutes': timeMinutes,
      'distance': distance,
      'speed': speed,
      'incline': incline,
      'user_weight_kg': userWeightKg,
    };
  }
}

class CreateSetLogRequest {
  const CreateSetLogRequest({
    required this.sessionWorkoutId,
    required this.weight,
    required this.reps,
    required this.order,
    required this.durationSeconds,
    required this.isCompleted,
  });

  final int sessionWorkoutId;
  final double weight;
  final int reps;
  final int order;
  final int durationSeconds;
  final bool isCompleted;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'session_workout_id': sessionWorkoutId,
      'weight': weight,
      'reps': reps,
      'order': order,
      'duration_seconds': durationSeconds,
      'is_completed': isCompleted,
    };
  }
}

class WorkoutSummary {
  const WorkoutSummary({required this.id, required this.name});

  final int id;
  final String name;

  factory WorkoutSummary.fromJson(Map<String, dynamic>? json) {
    return WorkoutSummary(
      id: int.tryParse(json?['id']?.toString() ?? '') ?? 0,
      name: json?['name']?.toString() ?? '',
    );
  }
}

class SetLog {
  const SetLog({
    required this.id,
    required this.weight,
    required this.reps,
    required this.order,
    required this.durationSeconds,
    required this.isCompleted,
    required this.volume,
    required this.oneRm,
  });

  final int id;
  final double weight;
  final int reps;
  final int order;
  final int durationSeconds;
  final bool isCompleted;
  final double volume;
  final double oneRm;

  factory SetLog.fromJson(Map<String, dynamic> json) {
    return SetLog(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      weight: double.tryParse(json['weight']?.toString() ?? '') ?? 0,
      reps: int.tryParse(json['reps']?.toString() ?? '') ?? 0,
      order: int.tryParse(json['order']?.toString() ?? '') ?? 0,
      durationSeconds:
          int.tryParse(json['duration_seconds']?.toString() ?? '') ?? 0,
      isCompleted: json['is_completed'] == true,
      volume: double.tryParse(json['volume']?.toString() ?? '') ?? 0,
      oneRm: double.tryParse(json['one_rm']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'weight': weight,
      'reps': reps,
      'order': order,
      'duration_seconds': durationSeconds,
      'is_completed': isCompleted,
      'volume': volume,
      'one_rm': oneRm,
    };
  }
}

class CardioLog {
  const CardioLog({
    required this.id,
    required this.timeMinutes,
    required this.distance,
    required this.speed,
    required this.incline,
    required this.caloriesBurned,
    required this.userWeightKg,
  });

  final int id;
  final int timeMinutes;
  final double distance;
  final double speed;
  final double incline;
  final double caloriesBurned;
  final double userWeightKg;

  factory CardioLog.fromJson(Map<String, dynamic> json) {
    return CardioLog(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      timeMinutes: int.tryParse(json['time_minutes']?.toString() ?? '') ?? 0,
      distance: double.tryParse(json['distance']?.toString() ?? '') ?? 0,
      speed: double.tryParse(json['speed']?.toString() ?? '') ?? 0,
      incline: double.tryParse(json['incline']?.toString() ?? '') ?? 0,
      caloriesBurned:
          double.tryParse(json['calories_burned']?.toString() ?? '') ?? 0,
      userWeightKg:
          double.tryParse(json['user_weight_kg']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'time_minutes': timeMinutes,
      'distance': distance,
      'speed': speed,
      'incline': incline,
      'calories_burned': caloriesBurned,
      'user_weight_kg': userWeightKg,
    };
  }
}

class WorkoutLog {
  const WorkoutLog({
    required this.id,
    required this.workout,
    required this.note,
    required this.setLogs,
    required this.cardioLog,
  });

  final int id;
  final WorkoutSummary workout;
  final String note;
  final List<SetLog> setLogs;
  final CardioLog? cardioLog;

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    final setLogsJson = json['set_logs'];
    final cardioJson = json['cardio_log'];

    return WorkoutLog(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      workout: WorkoutSummary.fromJson(
        json['workout'] is Map<String, dynamic>
            ? json['workout'] as Map<String, dynamic>
            : null,
      ),
      note: json['note']?.toString() ?? '',
      setLogs: setLogsJson is List
          ? setLogsJson
                .whereType<Map<String, dynamic>>()
                .map(SetLog.fromJson)
                .toList()
          : const [],
      cardioLog: cardioJson is Map<String, dynamic>
          ? CardioLog.fromJson(cardioJson)
          : null,
    );
  }
}

class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.userId,
    required this.date,
    required this.durationMinutes,
    required this.createdAt,
    required this.workoutLogs,
  });

  final int id;
  final String userId;
  final DateTime? date;
  final int durationMinutes;
  final DateTime? createdAt;
  final List<WorkoutLog> workoutLogs;

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    final workoutLogsJson = json['workout_logs'];

    return WorkoutSession(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: json['user_id']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
      durationMinutes:
          int.tryParse(json['duration_minutes']?.toString() ?? '') ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      workoutLogs: workoutLogsJson is List
          ? workoutLogsJson
                .whereType<Map<String, dynamic>>()
                .map(WorkoutLog.fromJson)
                .toList()
          : const [],
    );
  }
}

class ActiveSessionContentSummary {
  const ActiveSessionContentSummary({required this.id, required this.title});

  final int id;
  final String title;

  factory ActiveSessionContentSummary.fromJson(Map<String, dynamic>? json) {
    return ActiveSessionContentSummary(
      id: int.tryParse(json?['id']?.toString() ?? '') ?? 0,
      title: json?['title']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'title': title};
  }
}

class ActiveSessionWorkoutSummary {
  const ActiveSessionWorkoutSummary({
    required this.id,
    required this.name,
    required this.workoutType,
    required this.metValue,
    required this.sets,
    required this.reps,
    required this.rest,
  });

  final int id;
  final String name;
  final String workoutType;
  final double metValue;
  final String sets;
  final String reps;
  final String rest;

  factory ActiveSessionWorkoutSummary.fromJson(Map<String, dynamic>? json) {
    return ActiveSessionWorkoutSummary(
      id: int.tryParse(json?['id']?.toString() ?? '') ?? 0,
      name: json?['name']?.toString() ?? '',
      workoutType: json?['workout_type']?.toString() ?? '',
      metValue: double.tryParse(json?['met_value']?.toString() ?? '') ?? 0,
      sets: json?['sets']?.toString() ?? '',
      reps: json?['reps']?.toString() ?? '',
      rest: json?['rest']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'workout_type': workoutType,
      'met_value': metValue,
      'sets': sets,
      'reps': reps,
      'rest': rest,
    };
  }
}

class ActiveSessionWorkout {
  const ActiveSessionWorkout({
    required this.id,
    required this.order,
    required this.workout,
    required this.content,
    required this.note,
    required this.isCompleted,
    required this.estimatedCaloriesBurned,
    required this.actualCaloriesBurned,
    required this.setLogs,
    required this.cardioLog,
  });

  final int id;
  final int order;
  final ActiveSessionWorkoutSummary workout;
  final ActiveSessionContentSummary content;
  final String note;
  final bool isCompleted;
  final double estimatedCaloriesBurned;
  final double actualCaloriesBurned;
  final List<SetLog> setLogs;
  final CardioLog? cardioLog;

  factory ActiveSessionWorkout.fromJson(Map<String, dynamic> json) {
    final setLogsJson = json['set_logs'];
    final cardioJson = json['cardio_log'];

    return ActiveSessionWorkout(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      order: int.tryParse(json['order']?.toString() ?? '') ?? 0,
      workout: ActiveSessionWorkoutSummary.fromJson(
        json['workout'] is Map<String, dynamic>
            ? json['workout'] as Map<String, dynamic>
            : null,
      ),
      content: ActiveSessionContentSummary.fromJson(
        json['content'] is Map<String, dynamic>
            ? json['content'] as Map<String, dynamic>
            : null,
      ),
      note: json['note']?.toString() ?? '',
      isCompleted: json['is_completed'] == true,
      estimatedCaloriesBurned:
          double.tryParse(
            json['estimated_calories_burned']?.toString() ?? '',
          ) ??
          0,
      actualCaloriesBurned:
          double.tryParse(json['actual_calories_burned']?.toString() ?? '') ??
          0,
      setLogs: setLogsJson is List
          ? setLogsJson
                .whereType<Map<String, dynamic>>()
                .map(SetLog.fromJson)
                .toList(growable: false)
          : const [],
      cardioLog: cardioJson is Map<String, dynamic>
          ? CardioLog.fromJson(cardioJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'order': order,
      'workout': workout.toJson(),
      'content': content.toJson(),
      'note': note,
      'is_completed': isCompleted,
      'estimated_calories_burned': estimatedCaloriesBurned,
      'actual_calories_burned': actualCaloriesBurned,
      'set_logs': setLogs.map((item) => item.toJson()).toList(growable: false),
      'cardio_log': cardioLog?.toJson(),
    };
  }
}

class ActiveWorkoutSession {
  const ActiveWorkoutSession({
    required this.id,
    required this.userId,
    required this.date,
    required this.durationMinutes,
    required this.note,
    required this.userWeightKg,
    required this.status,
    required this.currentWorkoutOrder,
    required this.totalCaloriesBurned,
    required this.createdAt,
    required this.updatedAt,
    required this.completedAt,
    required this.workouts,
  });

  final int id;
  final String userId;
  final DateTime? date;
  final int durationMinutes;
  final String note;
  final double? userWeightKg;
  final String status;
  final int currentWorkoutOrder;
  final double totalCaloriesBurned;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final List<ActiveSessionWorkout> workouts;

  factory ActiveWorkoutSession.fromJson(Map<String, dynamic> json) {
    final workoutsJson = json['workouts'];

    return ActiveWorkoutSession(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: json['user_id']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
      durationMinutes:
          int.tryParse(json['duration_minutes']?.toString() ?? '') ?? 0,
      note: json['note']?.toString() ?? '',
      userWeightKg: double.tryParse(json['user_weight_kg']?.toString() ?? ''),
      status: json['status']?.toString() ?? '',
      currentWorkoutOrder:
          int.tryParse(json['current_workout_order']?.toString() ?? '') ?? 1,
      totalCaloriesBurned:
          double.tryParse(json['total_calories_burned']?.toString() ?? '') ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      completedAt: DateTime.tryParse(json['completed_at']?.toString() ?? ''),
      workouts: workoutsJson is List
          ? workoutsJson
                .whereType<Map<String, dynamic>>()
                .map(ActiveSessionWorkout.fromJson)
                .toList(growable: false)
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'date': date?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'note': note,
      'user_weight_kg': userWeightKg,
      'status': status,
      'current_workout_order': currentWorkoutOrder,
      'total_calories_burned': totalCaloriesBurned,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'workouts': workouts.map((item) => item.toJson()).toList(growable: false),
    };
  }
}

class ContentStartLogResponse {
  const ContentStartLogResponse({
    required this.session,
    required this.firstSessionWorkout,
  });

  final ActiveWorkoutSession session;
  final ActiveSessionWorkout firstSessionWorkout;

  factory ContentStartLogResponse.fromJson(Map<String, dynamic> json) {
    return ContentStartLogResponse(
      session: ActiveWorkoutSession.fromJson(
        json['session'] is Map<String, dynamic>
            ? json['session'] as Map<String, dynamic>
            : <String, dynamic>{},
      ),
      firstSessionWorkout: ActiveSessionWorkout.fromJson(
        json['first_session_workout'] is Map<String, dynamic>
            ? json['first_session_workout'] as Map<String, dynamic>
            : <String, dynamic>{},
      ),
    );
  }
}

class WorkoutStartLogResponse {
  const WorkoutStartLogResponse({
    required this.session,
    required this.firstSessionWorkout,
  });

  final ActiveWorkoutSession session;
  final ActiveSessionWorkout firstSessionWorkout;

  factory WorkoutStartLogResponse.fromJson(Map<String, dynamic> json) {
    return WorkoutStartLogResponse(
      session: ActiveWorkoutSession.fromJson(
        json['session'] is Map<String, dynamic>
            ? json['session'] as Map<String, dynamic>
            : <String, dynamic>{},
      ),
      firstSessionWorkout: ActiveSessionWorkout.fromJson(
        json['first_session_workout'] is Map<String, dynamic>
            ? json['first_session_workout'] as Map<String, dynamic>
            : <String, dynamic>{},
      ),
    );
  }
}

class ProgressSummary {
  const ProgressSummary({
    required this.totalWorkouts,
    required this.totalSets,
    required this.totalVolume,
    required this.avgDuration,
  });

  final int totalWorkouts;
  final int totalSets;
  final double totalVolume;
  final int avgDuration;

  factory ProgressSummary.fromJson(Map<String, dynamic> json) {
    return ProgressSummary(
      totalWorkouts:
          int.tryParse(json['total_workouts']?.toString() ?? '') ?? 0,
      totalSets: int.tryParse(json['total_sets']?.toString() ?? '') ?? 0,
      totalVolume: double.tryParse(json['total_volume']?.toString() ?? '') ?? 0,
      avgDuration: int.tryParse(json['avg_duration']?.toString() ?? '') ?? 0,
    );
  }
}

class ProgressHighlights {
  const ProgressHighlights({
    required this.daysStreak,
    required this.workoutsThisWeek,
    required this.caloriesBurned,
  });

  final int daysStreak;
  final int workoutsThisWeek;
  final double caloriesBurned;

  factory ProgressHighlights.fromJson(Map<String, dynamic> json) {
    return ProgressHighlights(
      daysStreak: int.tryParse(json['days_streak']?.toString() ?? '') ?? 0,
      workoutsThisWeek:
          int.tryParse(json['workouts_this_week']?.toString() ?? '') ?? 0,
      caloriesBurned:
          double.tryParse(json['calories_burned']?.toString() ?? '') ?? 0,
    );
  }
}

class ProgressRecentActivity {
  const ProgressRecentActivity({
    required this.sessionId,
    required this.title,
    required this.date,
    required this.dayLabel,
    required this.durationMinutes,
    required this.setCount,
  });

  final int sessionId;
  final String title;
  final DateTime? date;
  final String dayLabel;
  final int durationMinutes;
  final int setCount;

  factory ProgressRecentActivity.fromJson(Map<String, dynamic> json) {
    return ProgressRecentActivity(
      sessionId: int.tryParse(json['session_id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
      dayLabel: json['day_label']?.toString() ?? '',
      durationMinutes:
          int.tryParse(json['duration_minutes']?.toString() ?? '') ?? 0,
      setCount: int.tryParse(json['set_count']?.toString() ?? '') ?? 0,
    );
  }
}

class ProgressChartPoint {
  const ProgressChartPoint({required this.date, required this.volume});

  final DateTime? date;
  final double volume;

  factory ProgressChartPoint.fromJson(Map<String, dynamic> json) {
    return ProgressChartPoint(
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
      volume: double.tryParse(json['volume']?.toString() ?? '') ?? 0,
    );
  }
}

class ProgressBest {
  const ProgressBest({
    required this.workoutId,
    required this.workoutName,
    required this.equipmentName,
    required this.date,
    required this.bestOneRm,
    required this.previousBestOneRm,
    required this.improvement,
  });

  final int workoutId;
  final String workoutName;
  final String equipmentName;
  final DateTime? date;
  final double bestOneRm;
  final double previousBestOneRm;
  final double improvement;

  factory ProgressBest.fromJson(Map<String, dynamic> json) {
    return ProgressBest(
      workoutId: int.tryParse(json['workout_id']?.toString() ?? '') ?? 0,
      workoutName: json['workout_name']?.toString() ?? '',
      equipmentName: json['equipment_name']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
      bestOneRm: double.tryParse(json['best_1rm']?.toString() ?? '') ?? 0,
      previousBestOneRm:
          double.tryParse(json['previous_best_1rm']?.toString() ?? '') ?? 0,
      improvement: double.tryParse(json['improvement']?.toString() ?? '') ?? 0,
    );
  }
}
