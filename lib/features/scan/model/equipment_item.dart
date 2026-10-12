import 'package:hawiisaac/features/scan/model/equipment_reference.dart';

class EquipmentItem {
  const EquipmentItem({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.image,
    required this.createdAt,
  });

  final int id;
  final EquipmentReference category;
  final String name;
  final String description;
  final String image;
  final DateTime? createdAt;

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    return EquipmentItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      category: EquipmentReference.fromJson(
        json['category'] is Map<String, dynamic>
            ? json['category'] as Map<String, dynamic>
            : null,
      ),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
