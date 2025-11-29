class OrderItemModifier {
  String? id;
  String? orderItemId;
  String? modifierItemId;
  int? quantity;
  double? priceDelta;
  DateTime? createdAt;
  DateTime? updatedAt;
  ModifierItem? modifierItem;

  OrderItemModifier({
    this.id,
    this.orderItemId,
    this.modifierItemId,
    this.quantity,
    this.priceDelta,
    this.createdAt,
    this.updatedAt,
    this.modifierItem,
  });

  factory OrderItemModifier.fromMap(Map<String, dynamic> json) {
    return OrderItemModifier(
      id: json["id"]?.toString(),
      orderItemId: json["order_item_id"]?.toString(),
      modifierItemId: json["modifier_item_id"]?.toString(),
      quantity: json["quantity"],
      priceDelta: json["price_delta"] != null
          ? (json["price_delta"] is double
              ? json["price_delta"]
              : (json["price_delta"] as num).toDouble())
          : null,
      createdAt: json["created_at"] == null
          ? null
          : DateTime.parse(json["created_at"]),
      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.parse(json["updated_at"]),
      modifierItem: json["modifier_item"] == null
          ? null
          : ModifierItem.fromMap(json["modifier_item"]),
    );
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "order_item_id": orderItemId,
        "modifier_item_id": modifierItemId,
        "quantity": quantity,
        "price_delta": priceDelta,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "modifier_item": modifierItem?.toMap(),
      };
}

class ModifierItem {
  String? id;
  String? name;
  String? description;
  double? priceDelta;
  bool? isActive;

  ModifierItem({
    this.id,
    this.name,
    this.description,
    this.priceDelta,
    this.isActive,
  });

  factory ModifierItem.fromMap(Map<String, dynamic> json) {
    return ModifierItem(
      id: json["id"]?.toString(),
      name: json["name"]?.toString(),
      description: json["description"]?.toString(),
      priceDelta: json["price_delta"] != null
          ? (json["price_delta"] is double
              ? json["price_delta"]
              : (json["price_delta"] as num).toDouble())
          : null,
      isActive: json["is_active"],
    );
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "description": description,
        "price_delta": priceDelta,
        "is_active": isActive,
      };
}
