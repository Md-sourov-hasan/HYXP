class EquipmentCategory {
  const EquipmentCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String description;
  final DateTime? createdAt;

  factory EquipmentCategory.fromJson(Map<String, dynamic> json) {
    return EquipmentCategory(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
