import 'package:hawiisaac/features/scan/model/equipment_reference.dart';
import 'package:hawiisaac/features/scan/model/muscle_group.dart';

class WorkoutItem {
  const WorkoutItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.equipment,
    required this.muscleGroups,
    required this.tags,
    required this.workoutType,
    required this.metValue,
    required this.sets,
    required this.reps,
    required this.rest,
    required this.time,
    required this.duration,
    required this.distance,
    required this.speed,
    required this.incline,
    required this.uses,
    required this.banner,
    required this.video,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String description;
  final EquipmentReference category;
  final EquipmentReference equipment;
  final List<MuscleGroup> muscleGroups;
  final String tags;
  final String workoutType;
  final double metValue;
  final String sets;
  final String reps;
  final String rest;
  final String time;
  final String duration;
  final double distance;
  final double speed;
  final double incline;
  final List<String> uses;
  final String banner;
  final String video;
  final DateTime? createdAt;

  String get meta {
    final parts = <String>[
      if (equipment.name.isNotEmpty) equipment.name,
      if (sets.isNotEmpty) '$sets sets',
      if (reps.isNotEmpty) '$reps reps',
      if (rest.isNotEmpty) rest,
      if (duration.isNotEmpty) duration,
    ];

    return parts.join(' . ');
  }

  factory WorkoutItem.fromJson(Map<String, dynamic> json) {
    final muscleGroupJson = json['muscle_groups'];
    final usesJson = json['uses'];

    return WorkoutItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: EquipmentReference.fromJson(
        json['category'] is Map<String, dynamic>
            ? json['category'] as Map<String, dynamic>
            : null,
      ),
      equipment: EquipmentReference.fromJson(
        json['equipment'] is Map<String, dynamic>
            ? json['equipment'] as Map<String, dynamic>
            : null,
      ),
      muscleGroups: muscleGroupJson is List
          ? muscleGroupJson
                .whereType<Map<String, dynamic>>()
                .map(MuscleGroup.fromJson)
                .toList()
          : const [],
      tags: json['tags']?.toString() ?? '',
      workoutType: json['workout_type']?.toString() ?? '',
      metValue: double.tryParse(json['met_value']?.toString() ?? '') ?? 0,
      sets: json['sets']?.toString() ?? '',
      reps: json['reps']?.toString() ?? '',
      rest: json['rest']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      distance: double.tryParse(json['distance']?.toString() ?? '') ?? 0,
      speed: double.tryParse(json['speed']?.toString() ?? '') ?? 0,
      incline: double.tryParse(json['incline']?.toString() ?? '') ?? 0,
      uses: usesJson is List
          ? usesJson.map((use) => use.toString()).toList()
          : const [],
      banner: json['banner']?.toString() ?? '',
      video: json['video']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
