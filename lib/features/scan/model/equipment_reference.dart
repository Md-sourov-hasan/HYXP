class EquipmentReference {
  const EquipmentReference({
    required this.id,
    required this.name,
    this.description = '',
  });

  final int id;
  final String name;
  final String description;

  factory EquipmentReference.fromJson(Map<String, dynamic>? json) {
    return EquipmentReference(
      id: int.tryParse(json?['id']?.toString() ?? '') ?? 0,
      name: json?['name']?.toString() ?? '',
      description: json?['description']?.toString() ?? '',
    );
  }
}
