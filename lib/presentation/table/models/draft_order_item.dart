import 'dart:convert';

import 'package:xpress/data/models/response/product_response_model.dart';

class DraftOrderItem {
  final Product product;
  int quantity;
  DraftOrderItem({
    required this.product,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  // id INTEGER PRIMARY KEY AUTOINCREMENT,
  //     id_order INTEGER,
  //     id_product INTEGER,
  //     quantity INTEGER,
  //     price INTEGER

  Map<String, dynamic> toMapForLocal(int orderId) {
    return {
      'id_draft_order': orderId,
      'id_product': product.productId,
      'quantity': quantity,
      'price': product.price,
    };
  }

  static OrderItemModel fromMapLocal(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['id_product']?.toInt() ?? 0,
      quantity: map['quantity']?.toInt() ?? 0,
      totalPrice: map['price']?.toInt() ?? 0 * (map['quantity']?.toInt() ?? 0),
    );
  }

  factory DraftOrderItem.fromMap(Map<String, dynamic> map) {
    return DraftOrderItem(
      product: Product.fromMap(map['product']),
      quantity: map['quantity']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory DraftOrderItem.fromJson(String source) =>
      DraftOrderItem.fromMap(json.decode(source));
}

class OrderItemModel {
  final int productId;
  final int quantity;
  final int totalPrice;

  OrderItemModel({
    required this.productId,
    required this.quantity,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(String str) =>
      OrderItemModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OrderItemModel.fromMap(Map<String, dynamic> json) => OrderItemModel(
        productId: json["product_id"],
        quantity: json["quantity"],
        totalPrice: json["total_price"],
      );

  Map<String, dynamic> toMap() => {
        "product_id": productId,
        "quantity": quantity,
        "total_price": totalPrice,
      };
}
