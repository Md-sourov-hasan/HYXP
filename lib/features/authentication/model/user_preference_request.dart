class UserPreferenceRequest {
  const UserPreferenceRequest({
    required this.weight,
    required this.distance,
    required this.bodyMeasurements,
  });

  final String weight;
  final String distance;
  final String bodyMeasurements;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'weight': weight,
      'distance': distance,
      'body_measurements': bodyMeasurements,
    };
  }

  Map<String, String> toFormBody() {
    return <String, String>{
      'weight': weight,
      'distance': distance,
      'body_measurements': bodyMeasurements,
    };
  }
}
