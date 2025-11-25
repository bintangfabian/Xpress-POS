import 'dart:convert';

/// Main response model untuk GET /api/v1/products/{id}/variants
class ProductVariantResponse {
  final bool success;
  final ProductVariantData data;
  final ResponseMeta meta;

  ProductVariantResponse({
    required this.success,
    required this.data,
    required this.meta,
  });

  factory ProductVariantResponse.fromJson(String str) =>
      ProductVariantResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ProductVariantResponse.fromMap(Map<String, dynamic> json) =>
      ProductVariantResponse(
        success: json["success"] ?? false,
        data: ProductVariantData.fromMap(json["data"] ?? {}),
        meta: ResponseMeta.fromMap(json["meta"] ?? {}),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "data": data.toMap(),
        "meta": meta.toMap(),
      };
}

class ProductVariantData {
  final ProductInfo product;
  final List<VariantGroup> variantGroups;

  ProductVariantData({
    required this.product,
    required this.variantGroups,
  });

  factory ProductVariantData.fromMap(Map<String, dynamic> json) =>
      ProductVariantData(
        product: ProductInfo.fromMap(json["product"] ?? {}),
        variantGroups: json["variant_groups"] == null
            ? []
            : List<VariantGroup>.from(
                json["variant_groups"].map((x) => VariantGroup.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "product": product.toMap(),
        "variant_groups":
            List<dynamic>.from(variantGroups.map((x) => x.toMap())),
      };

  /// Helper method to check if product has variants
  bool get hasVariants => variantGroups.isNotEmpty;

  /// Helper method to get total variant options count
  int get totalOptionsCount {
    int count = 0;
    for (var group in variantGroups) {
      count += group.options.length;
    }
    return count;
  }
}

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

class VariantGroup {
  final String groupName;
  final String groupType;
  final bool isRequired;
  final int maxSelections;
  final List<VariantOption> options;

  VariantGroup({
    required this.groupName,
    required this.groupType,
    required this.isRequired,
    required this.maxSelections,
    required this.options,
  });

  factory VariantGroup.fromMap(Map<String, dynamic> json) => VariantGroup(
        groupName: json["group_name"]?.toString() ?? "",
        groupType: json["group_type"]?.toString() ?? "custom",
        isRequired: json["is_required"] ?? false,
        maxSelections: json["max_selections"] ?? 1,
        options: json["options"] == null
            ? []
            : List<VariantOption>.from(
                json["options"].map((x) => VariantOption.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "group_name": groupName,
        "group_type": groupType,
        "is_required": isRequired,
        "max_selections": maxSelections,
        "options": List<dynamic>.from(options.map((x) => x.toMap())),
      };

  /// Check if this group allows multiple selections
  bool get allowsMultipleSelections => maxSelections > 1;

  /// Get icon based on group type
  String get icon {
    switch (groupType) {
      case 'size':
        return '📏';
      case 'milk':
        return '🥛';
      case 'sweetness':
        return '🍯';
      case 'temperature':
        return '🌡️';
      case 'spice_level':
        return '🌶️';
      case 'addon':
        return '➕';
      default:
        return '⚙️';
    }
  }
}

class VariantOption {
  final String id;
  final String value;
  final double priceAdjustment;
  final bool isDefault;
  final String displayName;

  VariantOption({
    required this.id,
    required this.value,
    required this.priceAdjustment,
    required this.isDefault,
    required this.displayName,
  });

  factory VariantOption.fromMap(Map<String, dynamic> json) => VariantOption(
        id: json["id"]?.toString() ?? "",
        value: json["value"]?.toString() ?? "",
        priceAdjustment: _parseDouble(json["price_adjustment"]),
        isDefault: json["is_default"] ?? false,
        displayName: json["display_name"]?.toString() ?? "",
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "value": value,
        "price_adjustment": priceAdjustment,
        "is_default": isDefault,
        "display_name": displayName,
      };

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Format price adjustment for display
  String get formattedPriceAdjustment {
    if (priceAdjustment == 0) return '';
    final sign = priceAdjustment > 0 ? '+' : '';
    return '$sign Rp ${priceAdjustment.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  /// Get price adjustment as integer
  int get priceAdjustmentInt => priceAdjustment.toInt();
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

/// Model untuk selected variant (digunakan saat add to cart)
class SelectedVariantOption {
  final String variantId;
  final String groupName;
  final String optionValue;
  final double priceAdjustment;

  SelectedVariantOption({
    required this.variantId,
    required this.groupName,
    required this.optionValue,
    required this.priceAdjustment,
  });

  Map<String, dynamic> toMap() => {
        "variant_id": variantId,
        "group_name": groupName,
        "option_value": optionValue,
        "price_adjustment": priceAdjustment,
      };

  /// Convert to backend format (untuk product_options di OrderItem)
  Map<String, dynamic> toBackendFormat() => {
        "id": variantId,
        "name": groupName,
        "value": optionValue,
        "price_adjustment": priceAdjustment,
      };

  factory SelectedVariantOption.fromMap(Map<String, dynamic> json) =>
      SelectedVariantOption(
        variantId: json["variant_id"]?.toString() ?? "",
        groupName: json["group_name"]?.toString() ?? "",
        optionValue: json["option_value"]?.toString() ?? "",
        priceAdjustment: _parseDouble(json["price_adjustment"]),
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

    return other is SelectedVariantOption &&
        other.variantId == variantId &&
        other.groupName == groupName &&
        other.optionValue == optionValue &&
        other.priceAdjustment == priceAdjustment;
  }

  @override
  int get hashCode =>
      variantId.hashCode ^
      groupName.hashCode ^
      optionValue.hashCode ^
      priceAdjustment.hashCode;
}
