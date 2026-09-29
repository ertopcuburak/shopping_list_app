import 'package:uuid/uuid.dart';
import 'item_category.dart';

/// Alışveriş listesindeki tek bir ürünü temsil eder.
class ShoppingItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final ItemCategory category;
  final String? note;
  final bool isCompleted;
  final DateTime createdAt;

  const ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    this.note,
    required this.isCompleted,
    required this.createdAt,
  });

  /// Yeni bir ürün oluşturur; id ve createdAt otomatik atanır.
  factory ShoppingItem.create({
    required String name,
    required double quantity,
    required String unit,
    required ItemCategory category,
    String? note,
  }) {
    return ShoppingItem(
      id: const Uuid().v4(),
      name: name,
      quantity: quantity,
      unit: unit,
      category: category,
      note: note,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
  }

  /// Belirli alanları değiştirerek yeni bir kopya döner.
  ShoppingItem copyWith({
    String? name,
    double? quantity,
    String? unit,
    ItemCategory? category,
    String? note,
    bool? isCompleted,
    // note alanını null'a sıfırlamak için özel flag
    bool clearNote = false,
  }) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      note: clearNote ? null : (note ?? this.note),
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }

  /// JSON haritasına dönüştürür (persistence için).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category.key,
      'note': note,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// JSON haritasından [ShoppingItem] oluşturur.
  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      category: ItemCategory.fromKey(json['category'] as String),
      note: json['note'] as String?,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ShoppingItem && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ShoppingItem(id: $id, name: $name, quantity: $quantity $unit, '
      'category: ${category.label}, isCompleted: $isCompleted)';
}
