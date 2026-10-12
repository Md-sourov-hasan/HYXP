class UserPreference {
  const UserPreference({
    required this.weight,
    required this.distance,
    required this.bodyMeasurements,
    this.id = 0,
    this.userId = '',
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String userId;
  final String weight;
  final String distance;
  final String bodyMeasurements;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get measurements => bodyMeasurements;

  factory UserPreference.fromJson(Map<String, dynamic> json) {
    final bodyMeas = json['body_measurements']?.toString() ??
        json['measurements']?.toString() ??
        '';

    return UserPreference(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: json['user_id']?.toString() ?? '',
      weight: json['weight']?.toString() ?? '',
      distance: json['distance']?.toString() ?? '',
      bodyMeasurements: bodyMeas,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}
