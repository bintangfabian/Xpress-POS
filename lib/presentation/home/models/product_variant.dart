import 'dart:convert';

class ProductVariant {
  final String? id; // UUID from server
  final String name; // For display (can be value or group name)
  final String? groupName; // Group name (Size, Topping, etc)
  final String? value; // Option value (Large, Ice Cream, etc)
  final int priceAdjustment;

  ProductVariant({
    this.id,
    required this.name,
    this.groupName,
    this.value,
    required this.priceAdjustment,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'groupName': groupName,
      'value': value,
      'priceAdjustment': priceAdjustment,
    };
  }

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      id: map['id']?.toString(),
      name: map['name'] ?? '',
      groupName: map['groupName']?.toString(),
      value: map['value']?.toString(),
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
        other.groupName == groupName &&
        other.value == value &&
        other.priceAdjustment == priceAdjustment;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      groupName.hashCode ^
      value.hashCode ^
      priceAdjustment.hashCode;

  @override
  String toString() => '$name (+$priceAdjustment)';
}
