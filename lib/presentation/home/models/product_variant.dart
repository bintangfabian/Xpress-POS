import 'dart:convert';

class ProductVariant {
  final String name;
  final int priceAdjustment;

  ProductVariant({
    required this.name,
    required this.priceAdjustment,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'priceAdjustment': priceAdjustment,
    };
  }

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
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
        other.name == name &&
        other.priceAdjustment == priceAdjustment;
  }

  @override
  int get hashCode => name.hashCode ^ priceAdjustment.hashCode;

  @override
  String toString() => '$name (+$priceAdjustment)';
}
