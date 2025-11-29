import 'dart:convert';

/// Main response model untuk GET /api/v1/products/{id}/modifiers
class ProductModifierResponse {
  final bool success;
  final ProductModifierData data;
  final ResponseMeta meta;

  ProductModifierResponse({
    required this.success,
    required this.data,
    required this.meta,
  });

  factory ProductModifierResponse.fromJson(String str) =>
      ProductModifierResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ProductModifierResponse.fromMap(Map<String, dynamic> json) =>
      ProductModifierResponse(
        success: json["success"] ?? false,
        data: ProductModifierData.fromMap(json["data"] ?? {}),
        meta: ResponseMeta.fromMap(json["meta"] ?? {}),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "data": data.toMap(),
        "meta": meta.toMap(),
      };
}

class ProductModifierData {
  final ProductInfo product;
  final List<ModifierGroup> modifierGroups;

  ProductModifierData({
    required this.product,
    required this.modifierGroups,
  });

  factory ProductModifierData.fromMap(Map<String, dynamic> json) =>
      ProductModifierData(
        product: ProductInfo.fromMap(json["product"] ?? {}),
        modifierGroups: json["modifier_groups"] == null
            ? []
            : List<ModifierGroup>.from(
                json["modifier_groups"].map((x) => ModifierGroup.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "product": product.toMap(),
        "modifier_groups":
            List<dynamic>.from(modifierGroups.map((x) => x.toMap())),
      };

  /// Helper method to check if product has modifiers
  bool get hasModifiers => modifierGroups.isNotEmpty;

  /// Helper method to get total modifier items count
  int get totalItemsCount {
    int count = 0;
    for (var group in modifierGroups) {
      count += group.items.length;
    }
    return count;
  }
}

class ModifierGroup {
  final String id;
  final String name;
  final String? description;
  final int minSelect;
  final int? maxSelect; // null means unlimited
  final bool isRequired;
  final int sortOrder;
  final List<ModifierItem> items;

  ModifierGroup({
    required this.id,
    required this.name,
    this.description,
    required this.minSelect,
    this.maxSelect,
    required this.isRequired,
    required this.sortOrder,
    required this.items,
  });

  factory ModifierGroup.fromMap(Map<String, dynamic> json) => ModifierGroup(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
        description: json["description"]?.toString(),
        minSelect: json["min_select"] ?? 0,
        maxSelect: json["max_select"] as int?,
        isRequired: _parseBool(json["is_required"]),
        sortOrder: json["sort_order"] ?? 0,
        items: json["items"] == null
            ? []
            : List<ModifierItem>.from(
                json["items"].map((x) => ModifierItem.fromMap(x))),
      );

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      if (value.toLowerCase() == 'true' || value == '1') return true;
      return false;
    }
    return false;
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "description": description,
        "min_select": minSelect,
        "max_select": maxSelect,
        "is_required": isRequired,
        "sort_order": sortOrder,
        "items": List<dynamic>.from(items.map((x) => x.toMap())),
      };

  /// Check if this group allows multiple selections
  bool get allowsMultipleSelections => maxSelect == null || maxSelect! > 1;

  /// Get icon based on group name
  String get icon {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('topping')) return '🍒';
    if (nameLower.contains('sauce')) return '🍯';
    if (nameLower.contains('sweet')) return '🍬';
    if (nameLower.contains('ice')) return '🧊';
    if (nameLower.contains('milk')) return '🥛';
    if (nameLower.contains('extra') || nameLower.contains('shot')) return '➕';
    if (nameLower.contains('side')) return '🍟';
    return '⚙️';
  }
}

class ModifierItem {
  final String id;
  final String name;
  final String? description;
  final double priceDelta;
  final bool isActive;
  final int sortOrder;

  ModifierItem({
    required this.id,
    required this.name,
    this.description,
    required this.priceDelta,
    required this.isActive,
    required this.sortOrder,
  });

  factory ModifierItem.fromMap(Map<String, dynamic> json) => ModifierItem(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
        description: json["description"]?.toString(),
        priceDelta: _parseDouble(json["price_delta"]),
        isActive: json["is_active"] ?? true,
        sortOrder: json["sort_order"] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "description": description,
        "price_delta": priceDelta,
        "is_active": isActive,
        "sort_order": sortOrder,
      };

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Format price delta for display
  String get formattedPriceDelta {
    if (priceDelta == 0) return '';
    final sign = priceDelta > 0 ? '+' : '';
    return '$sign Rp ${priceDelta.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  /// Get price delta as integer
  int get priceDeltaInt => priceDelta.toInt();
}

/// Reuse ProductInfo and ResponseMeta from variant response
class ProductInfo {
  final String id;
  final String name;
  final double basePrice;

  ProductInfo({
    required this.id,
    required this.name,
    required this.basePrice,
  });

  factory ProductInfo.fromMap(Map<String, dynamic> json) => ProductInfo(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
        basePrice: _parseDouble(json["base_price"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "base_price": basePrice,
      };

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class ResponseMeta {
  final String timestamp;
  final String version;

  ResponseMeta({
    required this.timestamp,
    required this.version,
  });

  factory ResponseMeta.fromMap(Map<String, dynamic> json) => ResponseMeta(
        timestamp: json["timestamp"]?.toString() ?? "",
        version: json["version"]?.toString() ?? "v1",
      );

  Map<String, dynamic> toMap() => {
        "timestamp": timestamp,
        "version": version,
      };
}

/// Model untuk selected modifier item (digunakan saat add to cart)
class SelectedModifierItem {
  final String modifierItemId;
  final String groupName;
  final String itemName;
  final double priceDelta;

  SelectedModifierItem({
    required this.modifierItemId,
    required this.groupName,
    required this.itemName,
    required this.priceDelta,
  });

  Map<String, dynamic> toMap() => {
        "modifier_item_id": modifierItemId,
        "group_name": groupName,
        "item_name": itemName,
        "price_delta": priceDelta,
      };

  factory SelectedModifierItem.fromMap(Map<String, dynamic> json) =>
      SelectedModifierItem(
        modifierItemId: json["modifier_item_id"]?.toString() ?? "",
        groupName: json["group_name"]?.toString() ?? "",
        itemName: json["item_name"]?.toString() ?? "",
        priceDelta: _parseDouble(json["price_delta"]),
      );

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SelectedModifierItem &&
        other.modifierItemId == modifierItemId &&
        other.groupName == groupName &&
        other.itemName == itemName &&
        other.priceDelta == priceDelta;
  }

  @override
  int get hashCode =>
      modifierItemId.hashCode ^
      groupName.hashCode ^
      itemName.hashCode ^
      priceDelta.hashCode;
}
