import 'dart:convert';
import 'dart:developer';

import 'package:xpress/data/models/response/product_response_model.dart';
import 'package:xpress/presentation/home/models/product_variant.dart';

class ProductQuantity {
  final Product product;
  int quantity;
  final List<ProductVariant>? variants;
  ProductQuantity({
    required this.product,
    required this.quantity,
    this.variants,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductQuantity &&
        other.product == product &&
        other.quantity == quantity &&
        _listEquals(other.variants, variants);
  }

  @override
  int get hashCode =>
      product.hashCode ^
      quantity.hashCode ^
      (variants?.map((v) => v.toString()).join('|').hashCode ?? 0);

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

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
      'variants': variants?.map((v) => v.toMap()).toList(),
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
  /// Backend expects: product_id, quantity, product_options (array of UUIDs), notes
  Map<String, dynamic> toOrderItemMap() {
    final remoteProductId = product.productId ?? product.id;

    log('🔄 toOrderItemMap() - ${product.name}');
    log('  Product ID (local): ${product.id}');
    log('  Product ID (remote): $remoteProductId');
    log('  Quantity: $quantity');
    log('  Variants count: ${variants?.length ?? 0}');

    // Convert variants to product_options format
    // Backend expects ARRAY OF UUIDs, not objects!
    // Backend will query variant details from database
    final productOptions =
        variants?.where((v) => v.id != null && v.id!.isNotEmpty).map((v) {
              log('    Variant UUID: ${v.id} (${v.name})');
              return v.id!; // ✅ Only send UUID string
            }).toList() ??
            [];

    final result = {
      'product_id': remoteProductId is int
          ? remoteProductId
          : int.tryParse(remoteProductId.toString()) ?? 0,
      'quantity': quantity,
      'product_options': productOptions,
      'notes': '', // Optional notes field
    };

    log('  product_options (UUIDs): $productOptions');
    log('  Final result: $result');

    return result;
  }

  /// Calculate total price including variant adjustments
  double get totalPrice {
    final basePrice = double.tryParse(product.price ?? '0') ?? 0.0;
    final variantAdjustment = variants?.fold<double>(
          0.0,
          (sum, v) => sum + v.priceAdjustment,
        ) ??
        0.0;
    return (basePrice + variantAdjustment) * quantity;
  }

  /// Get unit price (base price + variant adjustments)
  double get unitPrice {
    final basePrice = double.tryParse(product.price ?? '0') ?? 0.0;
    final variantAdjustment = variants?.fold<double>(
          0.0,
          (sum, v) => sum + v.priceAdjustment,
        ) ??
        0.0;
    return basePrice + variantAdjustment;
  }

  /// Get variant summary string for display
  String get variantSummary {
    if (variants == null || variants!.isEmpty) {
      return '';
    }
    return variants!.map((v) => v.name).join(', ');
  }

  /// Check if this product has variants
  bool get hasVariants => variants != null && variants!.isNotEmpty;

  factory ProductQuantity.fromMap(Map<String, dynamic> map) {
    return ProductQuantity(
      product: Product.fromMap(map['product']),
      quantity: map['quantity']?.toInt() ?? 0,
      variants: (map['variants'] as List?)
          ?.map((e) => e is Map<String, dynamic>
              ? ProductVariant.fromMap(e)
              : ProductVariant(name: e.toString(), priceAdjustment: 0))
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
