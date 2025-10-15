import 'dart:convert';

class ProductVariant {
  final String? id; // UUID from server
  final String name;
  final int priceAdjustment;

  ProductVariant({
    this.id,
    required this.name,
    required this.priceAdjustment,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'priceAdjustment': priceAdjustment,
    };
  }

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      id: map['id']?.toString(),
      name: map['name'] ?? '',
      priceAdjustment: map['priceAdjustment']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductVariant.fromJson(String source) =>
      ProductVariant.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductVariant &&
        other.id == id &&
        other.name == name &&
        other.priceAdjustment == priceAdjustment;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ priceAdjustment.hashCode;

  @override
  String toString() => '$name (+$priceAdjustment)';
}
