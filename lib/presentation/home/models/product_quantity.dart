import 'dart:convert';
import 'dart:developer';

import 'package:xpress/data/models/response/product_response_model.dart';
import 'package:xpress/presentation/home/models/product_variant.dart';
import 'package:xpress/presentation/home/models/product_modifier.dart';

class ProductQuantity {
  final Product product;
  int quantity;
  final List<ProductVariant>? variants;
  final List<ProductModifier>? modifiers;
  ProductQuantity({
    required this.product,
    required this.quantity,
    this.variants,
    this.modifiers,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductQuantity &&
        other.product == product &&
        other.quantity == quantity &&
        _listEquals(other.variants, variants) &&
        _listEqualsModifiers(other.modifiers, modifiers);
  }

  @override
  int get hashCode =>
      product.hashCode ^
      quantity.hashCode ^
      (variants?.map((v) => v.toString()).join('|').hashCode ?? 0) ^
      (modifiers?.map((m) => m.toString()).join('|').hashCode ?? 0);

  bool _listEquals(List<ProductVariant>? a, List<ProductVariant>? b) {
    if (identical(a, b)) return true;
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _listEqualsModifiers(
      List<ProductModifier>? a, List<ProductModifier>? b) {
    if (identical(a, b)) return true;
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
      'variants': variants?.map((v) => v.toMap()).toList(),
      'modifiers': modifiers?.map((m) => m.toMap()).toList(),
    };
  }

  Map<String, dynamic> toLocalMap(int orderId) {
    log("OrderProductId: ${product.id}");

    return {
      'id_order': orderId,
      'id_product': product.productId,
      'quantity': quantity,
      'price': product.price,
    };
  }

  Map<String, dynamic> toServerMap(int? orderId) {
    final remoteProductId = product.productId ?? product.id;
    log("toServerMap: localId=${product.id} remoteId=$remoteProductId");

    return {
      'id_order': orderId ?? 0,
      'id_product': remoteProductId,
      'quantity': quantity,
      'price': product.price,
    };
  }

  /// Convert to API format for order items (new format)
  /// Backend expects: product_id, quantity, product_options (array of UUIDs), modifier_item_ids (array of UUIDs), notes
  Map<String, dynamic> toOrderItemMap() {
    final remoteProductId = product.productId ?? product.id;

    log('🔄 toOrderItemMap() - ${product.name}');
    log('  Product ID (local): ${product.id}');
    log('  Product ID (remote): $remoteProductId');
    log('  Quantity: $quantity');
    log('  Variants count: ${variants?.length ?? 0}');
    log('  Modifiers count: ${modifiers?.length ?? 0}');

    // Convert variants to product_options format
    // Backend expects ARRAY OF UUIDs, not objects!
    // Backend will query variant details from database
    final productOptions =
        variants?.where((v) => v.id != null && v.id!.isNotEmpty).map((v) {
              log('    Variant UUID: ${v.id} (${v.name})');
              return v.id!; // ✅ Only send UUID string
            }).toList() ??
            [];

    // Convert modifiers to modifier_item_ids format
    // Backend expects ARRAY OF UUIDs for modifier_item_ids
    final modifierItemIds =
        modifiers?.where((m) => m.id != null && m.id!.isNotEmpty).map((m) {
              log('    Modifier UUID: ${m.id} (${m.name})');
              return m.id!; // ✅ Only send UUID string
            }).toList() ??
            [];

    final result = {
      'product_id': remoteProductId is int
          ? remoteProductId
          : int.tryParse(remoteProductId.toString()) ?? 0,
      'quantity': quantity,
      'product_options': productOptions,
      'modifier_item_ids': modifierItemIds,
      'notes': '', // Optional notes field
    };

    log('  product_options (UUIDs): $productOptions');
    log('  modifier_item_ids (UUIDs): $modifierItemIds');
    log('  Final result: $result');

    return result;
  }

  /// Calculate total price including variant and modifier adjustments
  double get totalPrice {
    final basePrice = double.tryParse(product.price ?? '0') ?? 0.0;
    final variantAdjustment = variants?.fold<double>(
          0.0,
          (sum, v) => sum + v.priceAdjustment,
        ) ??
        0.0;
    final modifierAdjustment = modifiers?.fold<double>(
          0.0,
          (sum, m) => sum + m.priceDelta,
        ) ??
        0.0;
    return (basePrice + variantAdjustment + modifierAdjustment) * quantity;
  }

  /// Get unit price (base price + variant + modifier adjustments)
  double get unitPrice {
    final basePrice = double.tryParse(product.price ?? '0') ?? 0.0;
    final variantAdjustment = variants?.fold<double>(
          0.0,
          (sum, v) => sum + v.priceAdjustment,
        ) ??
        0.0;
    final modifierAdjustment = modifiers?.fold<double>(
          0.0,
          (sum, m) => sum + m.priceDelta,
        ) ??
        0.0;
    return basePrice + variantAdjustment + modifierAdjustment;
  }

  /// Get variant summary string for display
  String get variantSummary {
    if (variants == null || variants!.isEmpty) {
      return '';
    }
    return variants!.map((v) => v.name).join(', ');
  }

  /// Get modifier summary string for display
  String get modifierSummary {
    if (modifiers == null || modifiers!.isEmpty) {
      return '';
    }
    return modifiers!.map((m) => m.name).join(', ');
  }

  /// Check if this product has variants
  bool get hasVariants => variants != null && variants!.isNotEmpty;

  /// Check if this product has modifiers
  bool get hasModifiers => modifiers != null && modifiers!.isNotEmpty;

  factory ProductQuantity.fromMap(Map<String, dynamic> map) {
    return ProductQuantity(
      product: Product.fromMap(map['product']),
      quantity: map['quantity']?.toInt() ?? 0,
      variants: (map['variants'] as List?)
          ?.map((e) => e is Map<String, dynamic>
              ? ProductVariant.fromMap(e)
              : ProductVariant(name: e.toString(), priceAdjustment: 0))
          .toList(),
      modifiers: (map['modifiers'] as List?)
          ?.map((e) => e is Map<String, dynamic>
              ? ProductModifier.fromMap(e)
              : ProductModifier(name: e.toString(), priceDelta: 0))
          .toList(),
    );
  }

  factory ProductQuantity.fromLocalMap(Map<String, dynamic> map) {
    log("ProductQuantity: $map");
    return ProductQuantity(
      product: Product.fromOrderMap(map),
      quantity: map['quantity']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductQuantity.fromJson(String source) =>
      ProductQuantity.fromMap(json.decode(source));
}
