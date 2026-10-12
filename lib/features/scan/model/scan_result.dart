class EquipmentScanResult {
  const EquipmentScanResult({
    required this.success,
    required this.equipmentDetected,
    required this.primaryEquipment,
    required this.primaryEquipmentId,
    required this.recommendedWorkoutIds,
    required this.errorMessage,
  });

  final bool success;
  final List<String> equipmentDetected;
  final String primaryEquipment;
  final int? primaryEquipmentId;
  final List<int> recommendedWorkoutIds;
  final String errorMessage;

  bool get hasMatch =>
      success &&
      (primaryEquipmentId != null || primaryEquipment.trim().isNotEmpty);

  factory EquipmentScanResult.fromJson(Map<String, dynamic> json) {
    final detectedJson = json['equipment_detected'];
    final recommendedJson = json['recommended_workouts'];

    return EquipmentScanResult(
      success: json['success'] == true,
      equipmentDetected: detectedJson is List
          ? detectedJson
                .map((item) => item?.toString().trim() ?? '')
                .where((item) => item.isNotEmpty)
                .toList(growable: false)
          : const [],
      primaryEquipment: json['primary_equipment']?.toString().trim() ?? '',
      primaryEquipmentId: int.tryParse(
        json['primary_equipment_id']?.toString() ?? '',
      ),
      recommendedWorkoutIds: recommendedJson is List
          ? recommendedJson
                .map((item) {
                  if (item is Map<String, dynamic>) {
                    return int.tryParse(item['id']?.toString() ?? '');
                  }
                  return int.tryParse(item?.toString() ?? '');
                })
                .whereType<int>()
                .toList(growable: false)
          : const [],
      errorMessage: json['error_message']?.toString().trim() ?? '',
    );
  }
}

class EquipmentVerificationResult {
  const EquipmentVerificationResult({
    required this.success,
    required this.isMatch,
    required this.message,
    required this.confidence,
  });

  final bool success;
  final bool isMatch;
  final String message;
  final double confidence;

  factory EquipmentVerificationResult.fromJson(Map<String, dynamic> json) {
    return EquipmentVerificationResult(
      success: json['success'] == true,
      isMatch: json['is_match'] == true,
      message: json['message']?.toString().trim() ?? '',
      confidence: double.tryParse(json['confidence']?.toString() ?? '') ?? 0,
    );
  }
}
