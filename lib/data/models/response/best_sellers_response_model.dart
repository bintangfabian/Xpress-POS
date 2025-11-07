import 'dart:convert';

class BestSellersResponseModel {
  final bool success;
  final String? message;
  final BestSellersData? data;

  BestSellersResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  factory BestSellersResponseModel.fromJson(String str) =>
      BestSellersResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BestSellersResponseModel.fromMap(Map<String, dynamic> json) =>
      BestSellersResponseModel(
        success: json["success"] ?? false,
        message: json["message"],
        data:
            json["data"] == null ? null : BestSellersData.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
        "data": data?.toMap(),
      };
}

class BestSellersData {
  final List<BestSellingProduct> products;
  final List<BestSellingCategory> categories;

  BestSellersData({
    required this.products,
    required this.categories,
  });

  factory BestSellersData.fromMap(Map<String, dynamic> json) => BestSellersData(
        products: json["products"] == null
            ? []
            : List<BestSellingProduct>.from(
                json["products"].map((x) => BestSellingProduct.fromMap(x))),
        categories: json["categories"] == null
            ? []
            : List<BestSellingCategory>.from(
                json["categories"].map((x) => BestSellingCategory.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "products": List<dynamic>.from(products.map((x) => x.toMap())),
        "categories": List<dynamic>.from(categories.map((x) => x.toMap())),
      };
}

class BestSellingProduct {
  final int? productId;
  final String productName;
  final String? sku;
  final String? categoryName;
  final int totalQuantitySold;
  final int totalRevenue;
  final int orderCount;
  final String? image;

  BestSellingProduct({
    this.productId,
    required this.productName,
    this.sku,
    this.categoryName,
    required this.totalQuantitySold,
    required this.totalRevenue,
    required this.orderCount,
    this.image,
  });

  factory BestSellingProduct.fromMap(Map<String, dynamic> json) =>
      BestSellingProduct(
        productId: json["product_id"],
        productName: json["product_name"]?.toString() ?? '',
        sku: json["sku"]?.toString(),
        categoryName: json["category_name"]?.toString(),
        totalQuantitySold: _parseInt(json["total_quantity_sold"]),
        totalRevenue: _parseInt(json["total_revenue"]),
        orderCount: _parseInt(json["order_count"]),
        image: json["image"]?.toString(),
      );

  Map<String, dynamic> toMap() => {
        "product_id": productId,
        "product_name": productName,
        "sku": sku,
        "category_name": categoryName,
        "total_quantity_sold": totalQuantitySold,
        "total_revenue": totalRevenue,
        "order_count": orderCount,
        "image": image,
      };

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    return 0;
  }
}

class BestSellingCategory {
  final int? categoryId;
  final String categoryName;
  final int totalQuantitySold;
  final int totalRevenue;
  final int orderCount;

  BestSellingCategory({
    this.categoryId,
    required this.categoryName,
    required this.totalQuantitySold,
    required this.totalRevenue,
    required this.orderCount,
  });

  factory BestSellingCategory.fromMap(Map<String, dynamic> json) =>
      BestSellingCategory(
        categoryId: json["category_id"],
        categoryName: json["category_name"]?.toString() ?? '',
        totalQuantitySold:
            BestSellingProduct._parseInt(json["total_quantity_sold"]),
        totalRevenue: BestSellingProduct._parseInt(json["total_revenue"]),
        orderCount: BestSellingProduct._parseInt(json["order_count"]),
      );

  Map<String, dynamic> toMap() => {
        "category_id": categoryId,
        "category_name": categoryName,
        "total_quantity_sold": totalQuantitySold,
        "total_revenue": totalRevenue,
        "order_count": orderCount,
      };
}
