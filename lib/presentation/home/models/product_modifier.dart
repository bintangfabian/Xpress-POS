import 'dart:convert';

class ProductModifier {
  final String? id; // UUID from server (modifier_item_id)
  final String name; // Item name for display
  final String? groupName; // Group name (Toppings, Sauces, etc)
  final double priceDelta;

  ProductModifier({
    this.id,
    required this.name,
    this.groupName,
    required this.priceDelta,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'groupName': groupName,
      'priceDelta': priceDelta,
    };
  }

  factory ProductModifier.fromMap(Map<String, dynamic> map) {
    return ProductModifier(
      id: map['id']?.toString(),
      name: map['name'] ?? '',
      groupName: map['groupName']?.toString(),
      priceDelta: (map['priceDelta'] ?? 0).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductModifier.fromJson(String source) =>
      ProductModifier.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductModifier &&
        other.id == id &&
        other.name == name &&
        other.groupName == groupName &&
        other.priceDelta == priceDelta;
  }

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ groupName.hashCode ^ priceDelta.hashCode;

  @override
  String toString() => '$name (+${priceDelta.toInt()})';
}
