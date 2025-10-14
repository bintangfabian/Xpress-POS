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
    log("toServerMap: ${product.id}");

    return {
      'id_order': orderId ?? 0,
      'id_product': product.id,
      'quantity': quantity,
      'price': product.price,
    };
  }

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
